import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'prototype/input_control_variant.dart';
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
        // PROTOTYPE — wayfinder #213: floating switcher persists across
        // every pushed route. Strip along with input_control_variant.dart.
        // SafeArea's `minimum` reserves the switcher's own footprint at the
        // bottom of every screen so it never sits on top of (and blocks
        // taps on) real content — e.g. a "+ Add row" button on the last
        // card in a list. Using `minimum` rather than a flat Padding means
        // this composes with a real device's own system-inset padding
        // (gesture nav bar, etc.) via max(), instead of blindly stacking
        // on top of it.
        builder: (context, child) => ColoredBox(
          // Reserving space via SafeArea below exposes the Stack's own
          // background outside `child`'s Scaffold — colour it to match the
          // theme instead of leaving it the default (white) canvas colour.
          color: AppTheme.dark.scaffoldBackgroundColor,
          child: Stack(
            children: [
              if (child != null)
                SafeArea(
                  top: false,
                  left: false,
                  right: false,
                  minimum: const EdgeInsets.only(bottom: 72),
                  child: child,
                ),
              const InputControlVariantSwitcher(),
            ],
          ),
        ),
      ),
    );
  }
}
