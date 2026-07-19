import 'package:flutter/material.dart';

import '../models/routine.dart';

String _errorMessage(RoutineRenameError error) => switch (error) {
  RoutineRenameError.blank => 'Name cannot be empty',
  RoutineRenameError.duplicate => 'A Routine with this name already exists',
};

/// Shared name-entry dialog for both Create Routine and Rename Routine,
/// which validate and submit identically and differ only in copy, initial
/// text, and the collision check against existing Routines.
class RoutineNameDialog extends StatefulWidget {
  final String title;
  final String confirmLabel;
  final String initialName;
  final Key fieldKey;
  final Key cancelKey;
  final Key confirmKey;
  final RoutineRenameError? Function(String name) validate;

  const RoutineNameDialog({
    super.key,
    required this.title,
    required this.confirmLabel,
    required this.initialName,
    required this.fieldKey,
    required this.cancelKey,
    required this.confirmKey,
    required this.validate,
  });

  @override
  State<RoutineNameDialog> createState() => _RoutineNameDialogState();
}

class _RoutineNameDialogState extends State<RoutineNameDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text;
    final error = widget.validate(name);
    if (error != null) {
      setState(() {
        _errorText = _errorMessage(error);
      });
      return;
    }

    Navigator.pop(context, name.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        key: widget.fieldKey,
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(errorText: _errorText),
      ),
      actions: [
        TextButton(
          key: widget.cancelKey,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          key: widget.confirmKey,
          onPressed: _submit,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
