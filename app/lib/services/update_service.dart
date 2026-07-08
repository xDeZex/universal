import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ota_update/ota_update.dart';

/// The GitHub Releases API endpoint checked for the latest App build.
const String _releasesUrl =
    'https://api.github.com/repos/xDeZex/universal/releases/latest';

/// Executes an OTA download+install, matching [OtaUpdate.execute]'s
/// signature so tests can inject a fake stream instead of a platform channel.
typedef OtaExecutor = Stream<OtaEvent> Function(
  String url, {
  String? sha256checksum,
});

enum UpdateStatus { checking, upToDate, updateAvailable, error }

/// Compares the running app's Build Tag against GitHub's latest release
/// Build Tag to detect whether a newer App build exists.
class UpdateService extends ChangeNotifier {
  UpdateService({
    http.Client? httpClient,
    String? buildTag,
    OtaExecutor? otaExecutor,
  })  : _httpClient = httpClient ?? http.Client(),
        _buildTag = buildTag ??
            const String.fromEnvironment('BUILD_TAG', defaultValue: 'dev'),
        _otaExecutor = otaExecutor ??
            ((url, {sha256checksum}) => OtaUpdate().execute(
                  url,
                  sha256checksum: sha256checksum,
                ));

  final http.Client _httpClient;
  final String _buildTag;
  final OtaExecutor _otaExecutor;

  UpdateStatus _status = UpdateStatus.checking;
  UpdateStatus get status => _status;

  String? _apkUrl;
  String? get apkUrl => _apkUrl;

  String? _sha256Url;
  String? get sha256Url => _sha256Url;

  String? _downloadProgress;
  String? get downloadProgress => _downloadProgress;

  Future<void> checkForUpdate() async {
    _status = UpdateStatus.checking;
    notifyListeners();

    try {
      final response = await _httpClient.get(Uri.parse(_releasesUrl));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        _status = UpdateStatus.error;
        notifyListeners();
        return;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final tagName = json['tag_name'] as String;

      if (tagName == _buildTag) {
        _status = UpdateStatus.upToDate;
      } else {
        _status = UpdateStatus.updateAvailable;
        final assets = json['assets'] as List<dynamic>? ?? [];
        _apkUrl = _findAssetUrl(assets, '.apk');
        _sha256Url = _findAssetUrl(assets, '.sha256');
      }
    } catch (_) {
      _status = UpdateStatus.error;
    }

    notifyListeners();
  }

  /// Downloads the update APK, verifies it against the published `.sha256`
  /// asset, and fires the Android install intent once verified.
  Future<void> downloadAndInstall() async {
    final apkUrl = _apkUrl;
    final sha256Url = _sha256Url;
    if (apkUrl == null || sha256Url == null) return;

    try {
      final checksumResponse = await _httpClient.get(Uri.parse(sha256Url));

      if (checksumResponse.statusCode < 200 ||
          checksumResponse.statusCode >= 300) {
        _finishDownload(status: UpdateStatus.error);
        return;
      }

      final checksum = _parseChecksum(checksumResponse.body);

      await for (final event
          in _otaExecutor(apkUrl, sha256checksum: checksum)) {
        if (event.status == OtaStatus.DOWNLOADING) {
          _downloadProgress = event.value;
          notifyListeners();
        } else if (event.status == OtaStatus.INSTALLING ||
            event.status == OtaStatus.INSTALLATION_DONE) {
          _finishDownload(status: UpdateStatus.upToDate);
          return;
        } else {
          _finishDownload(status: UpdateStatus.error);
          return;
        }
      }
    } catch (_) {
      _finishDownload(status: UpdateStatus.error);
    }
  }

  void _finishDownload({required UpdateStatus status}) {
    _downloadProgress = null;
    _status = status;
    notifyListeners();
  }

  /// The `.sha256` asset holds `sha256sum` output: `<hash>  <filename>`.
  String _parseChecksum(String body) => body.trim().split(RegExp(r'\s+')).first;

  String? _findAssetUrl(List<dynamic> assets, String suffix) {
    for (final asset in assets) {
      final name = asset['name'] as String?;
      if (name != null && name.endsWith(suffix)) {
        return asset['browser_download_url'] as String?;
      }
    }
    return null;
  }
}
