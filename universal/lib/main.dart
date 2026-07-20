import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'prototype/row_card_variant.dart';
import 'screens/app_shell.dart';
import 'services/update_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const UniversalApp());
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
        // PROTOTYPE — wayfinder #212: floating switcher persists across
        // every pushed route. Strip along with row_card_variant.dart.
        builder: (context, child) => Stack(
          children: [
            if (child != null) child,
            const RowCardVariantSwitcher(),
          ],
        ),
      ),
    );
  }
}
