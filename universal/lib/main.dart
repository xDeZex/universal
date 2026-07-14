import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';
import 'package:provider/provider.dart';

import 'screens/app_shell.dart';
import 'services/update_service.dart';
import 'theme/app_theme.dart';

void main() {
  if (kDebugMode) {
    runZonedGuarded(
      () {
        WidgetsFlutterBinding.ensureInitialized();
        MCPToolkitBinding.instance
          ..initialize()
          ..initializeFlutterToolkit();
        runApp(const UniversalApp());
      },
      (error, stack) => MCPToolkitBinding.instance.handleZoneError(error, stack),
    );
  } else {
    runApp(const UniversalApp());
  }
}

class UniversalApp extends StatelessWidget {
  final UpdateService? updateService;

  const UniversalApp({super.key, this.updateService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UpdateService>(
      create: (_) {
        final service = updateService ?? UpdateService();
        service.checkForUpdate();
        return service;
      },
      child: MaterialApp(
        title: 'Universal',
        theme: AppTheme.dark,
        home: const AppShell(),
      ),
    );
  }
}
