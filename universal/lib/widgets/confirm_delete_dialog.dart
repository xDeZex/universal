import 'package:flutter/material.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String message;

  const ConfirmDeleteDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete'),
      content: Text(message),
      actions: [
        TextButton(
          key: const ValueKey('confirm-delete-cancel'),
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          key: const ValueKey('confirm-delete-confirm'),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
