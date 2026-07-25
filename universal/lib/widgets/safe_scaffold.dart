import 'package:flutter/material.dart';

/// Shared screen scaffold: wraps [Scaffold] with its [body] pre-wrapped
/// in [SafeArea] and its [floatingActionButton] padded clear of the
/// bottom system inset, so screens get this for free instead of
/// relying on everyone remembering it.
class SafeScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;

  const SafeScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final fab = floatingActionButton;
    // Scaffold clears MediaQuery's padding for the floatingActionButton slot
    // (it assumes its own fixed margin is enough), so a SafeArea nested
    // inside the FAB would see zero bottom padding. Capture the real inset
    // here, above the Scaffold, and pad the FAB with it directly instead.
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      appBar: appBar,
      floatingActionButton: fab == null
          ? null
          : Padding(padding: EdgeInsets.only(bottom: bottomInset), child: fab),
      body: SafeArea(child: body),
    );
  }
}
