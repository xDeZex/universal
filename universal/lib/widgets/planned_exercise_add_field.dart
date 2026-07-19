import 'package:flutter/material.dart';

class PlannedExerciseAddField extends StatefulWidget {
  final void Function(String name) onAdd;

  const PlannedExerciseAddField({super.key, required this.onAdd});

  @override
  State<PlannedExerciseAddField> createState() =>
      _PlannedExerciseAddFieldState();
}

class _PlannedExerciseAddFieldState extends State<PlannedExerciseAddField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    widget.onAdd(name);
    setState(_controller.clear);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: const ValueKey('add-planned-exercise-field'),
              controller: _controller,
              decoration: const InputDecoration(hintText: 'Exercise name'),
              onSubmitted: (_) => _submit(),
            ),
          ),
          IconButton(
            key: const ValueKey('add-planned-exercise-button'),
            icon: const Icon(Icons.add),
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
