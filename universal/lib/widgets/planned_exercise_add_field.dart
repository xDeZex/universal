import 'package:flutter/material.dart';

import '../models/exercise.dart';

class PlannedExerciseAddField extends StatefulWidget {
  final List<Exercise> exercises;
  final void Function(String name) onAdd;

  const PlannedExerciseAddField({
    super.key,
    required this.exercises,
    required this.onAdd,
  });

  @override
  State<PlannedExerciseAddField> createState() =>
      _PlannedExerciseAddFieldState();
}

class _PlannedExerciseAddFieldState extends State<PlannedExerciseAddField> {
  final TextEditingController _controller = TextEditingController();
  bool _suggestionsDismissed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Exercise> get _suggestions {
    if (_suggestionsDismissed) return const [];
    final query = _controller.text.trim().toLowerCase();
    if (query.isEmpty) return const [];
    final matches =
        widget.exercises
            .where((exercise) => exercise.name.toLowerCase().contains(query))
            .toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
    return matches;
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    widget.onAdd(name);
    setState(_controller.clear);
  }

  void _selectSuggestion(Exercise exercise) {
    setState(() {
      _controller.text = exercise.name;
      _controller.selection = TextSelection.collapsed(
        offset: exercise.name.length,
      );
      _suggestionsDismissed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _suggestions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  key: const ValueKey('add-planned-exercise-field'),
                  controller: _controller,
                  decoration: const InputDecoration(hintText: 'Exercise name'),
                  onChanged: (_) =>
                      setState(() => _suggestionsDismissed = false),
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
        ),
        if (suggestions.isNotEmpty)
          Container(
            key: const ValueKey('add-planned-exercise-suggestions'),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final exercise = suggestions[index];
                return ListTile(
                  key: ValueKey('suggestion-${exercise.id}'),
                  title: Text(exercise.name),
                  onTap: () => _selectSuggestion(exercise),
                );
              },
            ),
          ),
      ],
    );
  }
}
