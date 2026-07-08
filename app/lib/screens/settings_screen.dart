import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/update_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<UpdateService>().checkForUpdate(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final updateService = context.watch<UpdateService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(child: _buildStatus(updateService)),
    );
  }

  Widget _buildStatus(UpdateService updateService) {
    switch (updateService.status) {
      case UpdateStatus.checking:
        return const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Checking for updates...'),
          ],
        );
      case UpdateStatus.upToDate:
        return const Text('Up to date');
      case UpdateStatus.updateAvailable:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Update available'),
            const SizedBox(height: 16),
            if (updateService.downloadProgress != null)
              Text('Downloading: ${updateService.downloadProgress}%')
            else
              ElevatedButton(
                onPressed: () => updateService.downloadAndInstall(),
                child: const Text('Download'),
              ),
          ],
        );
      case UpdateStatus.error:
        return const Text('Unable to check for updates');
    }
  }
}
