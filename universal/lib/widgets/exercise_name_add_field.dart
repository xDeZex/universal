import 'package:flutter/material.dart';

import '../models/exercise.dart';
import '../models/sort_by_name.dart';

class ExerciseNameAddField extends StatefulWidget {
  final List<Exercise> exercises;
  final void Function(String name) onAdd;
  final String keyPrefix;

  const ExerciseNameAddField({
    super.key,
    required this.exercises,
    required this.onAdd,
    required this.keyPrefix,
  });

  @override
  State<ExerciseNameAddField> createState() => _ExerciseNameAddFieldState();
}

class _ExerciseNameAddFieldState extends State<ExerciseNameAddField> {
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
    final matches = widget.exercises.where(
      (exercise) => exercise.name.toLowerCase().contains(query),
    );
    return sortByName(matches.toList(), (exercise) => exercise.name);
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    widget.onAdd(name);
    setState(_controller.clear);
    FocusScope.of(context).unfocus();
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

  Key _key(String suffix) => ValueKey('${widget.keyPrefix}-$suffix');

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
                  key: _key('field'),
                  controller: _controller,
                  decoration: const InputDecoration(hintText: 'Exercise name'),
                  onChanged: (_) =>
                      setState(() => _suggestionsDismissed = false),
                  onSubmitted: (_) => _submit(),
                ),
              ),
              IconButton(
                key: _key('button'),
                icon: const Icon(Icons.add),
                onPressed: _submit,
              ),
            ],
          ),
        ),
        if (suggestions.isNotEmpty)
          Container(
            key: _key('suggestions'),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final exercise = suggestions[index];
                return ListTile(
                  key: _key('suggestion-${exercise.id}'),
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
