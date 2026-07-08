import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ota_update/ota_update.dart';
import 'package:universal/services/update_service.dart';

http.Response _releaseResponse(String tagName) {
  return http.Response(
    jsonEncode({
      'tag_name': tagName,
      'assets': [
        {
          'name': 'Universal.apk',
          'browser_download_url': 'https://example.com/Universal.apk',
        },
        {
          'name': 'Universal.apk.sha256',
          'browser_download_url': 'https://example.com/Universal.apk.sha256',
        },
      ],
    }),
    200,
  );
}

/// Builds an httpClient that serves the releases endpoint and the `.sha256`
/// asset endpoint from canned responses, keyed by request path.
http.Client _clientWithChecksum(String tagName, String checksumBody) {
  return MockClient((request) async {
    if (request.url.path.endsWith('.sha256')) {
      return http.Response(checksumBody, 200);
    }
    return _releaseResponse(tagName);
  });
}

void main() {
  group('UpdateService checkForUpdate', () {
    test('matching tag sets status to upToDate', () async {
      final client = MockClient((request) async => _releaseResponse('build-1'));
      final service = UpdateService(httpClient: client, buildTag: 'build-1');

      await service.checkForUpdate();

      expect(service.status, UpdateStatus.upToDate);
      expect(service.apkUrl, isNull);
      expect(service.sha256Url, isNull);
    });

    test('differing tag sets status to updateAvailable with asset URLs',
        () async {
      final client =
          MockClient((request) async => _releaseResponse('build-2'));
      final service = UpdateService(httpClient: client, buildTag: 'build-1');

      await service.checkForUpdate();

      expect(service.status, UpdateStatus.updateAvailable);
      expect(service.apkUrl, 'https://example.com/Universal.apk');
      expect(service.sha256Url, 'https://example.com/Universal.apk.sha256');
    });

    test('non-2xx response sets status to error without throwing', () async {
      final client =
          MockClient((request) async => http.Response('Not Found', 404));
      final service = UpdateService(httpClient: client, buildTag: 'build-1');

      await expectLater(service.checkForUpdate(), completes);

      expect(service.status, UpdateStatus.error);
    });

    test('network exception sets status to error without throwing', () async {
      final client = MockClient((request) async => throw Exception('boom'));
      final service = UpdateService(httpClient: client, buildTag: 'build-1');

      await expectLater(service.checkForUpdate(), completes);

      expect(service.status, UpdateStatus.error);
    });

    test('notifies listeners on state change', () async {
      final client = MockClient((request) async => _releaseResponse('build-1'));
      final service = UpdateService(httpClient: client, buildTag: 'build-1');

      var notifications = 0;
      service.addListener(() => notifications++);

      await service.checkForUpdate();

      expect(notifications, greaterThan(0));
    });
  });

  group('UpdateService downloadAndInstall', () {
    test('matching checksum fires install and sets status to upToDate',
        () async {
      final client = _clientWithChecksum('build-2', 'abc123  Universal.apk');
      String? passedChecksum;
      final service = UpdateService(
        httpClient: client,
        buildTag: 'build-1',
        otaExecutor: (url, {sha256checksum}) {
          passedChecksum = sha256checksum;
          return Stream.fromIterable([
            OtaEvent(OtaStatus.DOWNLOADING, '50'),
            OtaEvent(OtaStatus.INSTALLING, null),
          ]);
        },
      );
      await service.checkForUpdate();

      await service.downloadAndInstall();

      expect(passedChecksum, 'abc123');
      expect(service.status, UpdateStatus.upToDate);
      expect(service.downloadProgress, isNull);
    });

    test('mismatched checksum blocks install and sets status to error',
        () async {
      final client = _clientWithChecksum('build-2', 'abc123  Universal.apk');
      final service = UpdateService(
        httpClient: client,
        buildTag: 'build-1',
        otaExecutor: (url, {sha256checksum}) => Stream.fromIterable([
          OtaEvent(OtaStatus.DOWNLOADING, '50'),
          OtaEvent(OtaStatus.CHECKSUM_ERROR, 'Checksum verification failed'),
        ]),
      );
      await service.checkForUpdate();

      await service.downloadAndInstall();

      expect(service.status, UpdateStatus.error);
      expect(service.downloadProgress, isNull);
    });

    test('reports download progress while downloading', () async {
      final client = _clientWithChecksum('build-2', 'abc123  Universal.apk');
      final progressUpdates = <String?>[];
      final service = UpdateService(
        httpClient: client,
        buildTag: 'build-1',
        otaExecutor: (url, {sha256checksum}) => Stream.fromIterable([
          OtaEvent(OtaStatus.DOWNLOADING, '25'),
          OtaEvent(OtaStatus.DOWNLOADING, '75'),
          OtaEvent(OtaStatus.INSTALLING, null),
        ]),
      );
      await service.checkForUpdate();
      service.addListener(() => progressUpdates.add(service.downloadProgress));

      await service.downloadAndInstall();

      expect(progressUpdates, containsAllInOrder(['25', '75']));
    });
  });
}
