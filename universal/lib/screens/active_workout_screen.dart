import 'package:flutter/material.dart';

import '../models/exercise.dart';
import '../models/workout.dart';
import '../widgets/confirm_delete_dialog.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final Workout workout;
  final List<Exercise> exercises;
  final void Function(Workout) onWorkoutChanged;
  final void Function(List<Exercise>) onExercisesChanged;
  final void Function(String workoutId) onWorkoutDiscarded;

  const ActiveWorkoutScreen({
    super.key,
    required this.workout,
    required this.exercises,
    required this.onWorkoutChanged,
    required this.onExercisesChanged,
    required this.onWorkoutDiscarded,
  });

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  late Workout _workout;
  late List<Exercise> _exercises;
  final TextEditingController _nameController = TextEditingController();
  String? _selectedEntryId;
  final Map<String, WeightUnit> _entryUnits = {};

  @override
  void initState() {
    super.initState();
    _workout = widget.workout;
    _exercises = widget.exercises;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addExerciseEntry() {
    final name = _nameController.text.trim();
    final exercise = Exercise.resolve(name, _exercises);
    if (exercise == null) return;

    final isNewExercise = !_exercises.any((e) => e.id == exercise.id);

    final entry = ExerciseEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      exerciseId: exercise.id,
    );

    setState(() {
      _workout = _workout.copyWith(
        exerciseEntries: [..._workout.exerciseEntries, entry],
      );
      if (isNewExercise) {
        _exercises = [..._exercises, exercise];
      }
      _selectedEntryId = entry.id;
    });

    widget.onWorkoutChanged(_workout);
    if (isNewExercise) {
      widget.onExercisesChanged(_exercises);
    }
    _nameController.clear();
  }

  void _addSet(String entryId, num weight, WeightUnit unit, int reps) {
    setState(() {
      _workout = _workout.addSet(
        entryId: entryId,
        weight: weight,
        unit: unit,
        reps: reps,
      );
      _entryUnits[entryId] = unit;
    });
    widget.onWorkoutChanged(_workout);
  }

  WeightUnit _unitFor(String entryId) => _entryUnits[entryId] ?? WeightUnit.kg;

  void _setEntryUnit(String entryId, WeightUnit unit) {
    setState(() {
      _entryUnits[entryId] = unit;
    });
  }

  void _editSet(
    String entryId,
    String setId,
    num weight,
    WeightUnit unit,
    int reps,
  ) {
    setState(() {
      _workout = _workout.editSet(
        entryId: entryId,
        setId: setId,
        weight: weight,
        unit: unit,
        reps: reps,
      );
    });
    widget.onWorkoutChanged(_workout);
  }

  void _deleteSet(String entryId, String setId) {
    setState(() {
      _workout = _workout.deleteSet(entryId: entryId, setId: setId);
    });
    widget.onWorkoutChanged(_workout);
  }

  void _deleteExerciseEntry(String entryId) {
    setState(() {
      _workout = _workout.deleteExerciseEntry(entryId: entryId);
      if (_selectedEntryId == entryId) {
        _selectedEntryId = null;
      }
    });
    widget.onWorkoutChanged(_workout);
  }

  void _selectEntry(String entryId) {
    setState(() {
      _selectedEntryId = entryId;
    });
  }

  List<Widget> _buildEntryRows() {
    final entries = _workout.exerciseEntries;
    final rows = <Widget>[];
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      rows.add(
        _ExerciseEntryTile(
          key: ValueKey(entry.id),
          entry: entry,
          exerciseName: Exercise.nameFor(entry.exerciseId, _exercises),
          locked: !_canAddNew,
          selected: _canAddNew && entry.id == _selectedEntryId,
          onSelect: () => _selectEntry(entry.id),
          onEditSet: (setId, weight, unit, reps) =>
              _editSet(entry.id, setId, weight, unit, reps),
          onDeleteSet: (setId) => _deleteSet(entry.id, setId),
          onDeleteEntry: () => _deleteExerciseEntry(entry.id),
        ),
      );
      if (i != entries.length - 1) {
        rows.add(const Divider(height: 1));
      }
    }
    return rows;
  }

  bool get _hasLoggedSets =>
      _workout.exerciseEntries.any((entry) => entry.sets.isNotEmpty);

  bool get _canAddNew => _workout.isInProgress;

  String _appBarTitle(BuildContext context) {
    if (_canAddNew) return 'Active Workout';
    return MaterialLocalizations.of(context).formatShortDate(_workout.endTime!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_appBarTitle(context))),
      body: SafeArea(
        child: Column(
          children: [
            if (_canAddNew)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Exercise name',
                        ),
                        onSubmitted: (_) => _addExerciseEntry(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addExerciseEntry,
                    ),
                  ],
                ),
              ),
            Expanded(child: ListView(children: _buildEntryRows())),
            if (_canAddNew && _selectedEntryId != null) ...[
              _AddSetBar(
                key: ValueKey(_selectedEntryId),
                initialUnit: _unitFor(_selectedEntryId!),
                onAddSet: (weight, unit, reps) =>
                    _addSet(_selectedEntryId!, weight, unit, reps),
                onUnitChanged: (unit) =>
                    _setEntryUnit(_selectedEntryId!, unit),
              ),
              const Divider(height: 1),
            ],
            if (_canAddNew)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        key: const ValueKey('discard-workout'),
                        onPressed: _discard,
                        child: const Text('Discard'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        key: const ValueKey('finish-workout'),
                        onPressed: _hasLoggedSets ? _finish : null,
                        child: const Text('Finish'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _finish() {
    final finished = _workout.finish();
    if (finished == null) return;

    setState(() {
      _workout = finished;
    });
    widget.onWorkoutChanged(finished);
    Navigator.pop(context);
  }

  void _discard() {
    widget.onWorkoutDiscarded(_workout.id);
    Navigator.pop(context);
  }
}

class _ExerciseEntryTile extends StatefulWidget {
  final ExerciseEntry entry;
  final String exerciseName;
  final bool locked;
  final bool selected;
  final VoidCallback onSelect;
  final void Function(String setId, num weight, WeightUnit unit, int reps)
  onEditSet;
  final void Function(String setId) onDeleteSet;
  final VoidCallback onDeleteEntry;

  const _ExerciseEntryTile({
    super.key,
    required this.entry,
    required this.exerciseName,
    required this.locked,
    required this.selected,
    required this.onSelect,
    required this.onEditSet,
    required this.onDeleteSet,
    required this.onDeleteEntry,
  });

  @override
  State<_ExerciseEntryTile> createState() => _ExerciseEntryTileState();
}

class _ExerciseEntryTileState extends State<_ExerciseEntryTile> {
  static const _setColumnWidth = 34.0;
  static const _timeColumnWidth = 64.0;

  Future<void> _openEditDialog(ExerciseSet set) async {
    final result = await showDialog<_EditSetDialogResult>(
      context: context,
      builder: (context) => _EditSetDialog(set: set),
    );
    switch (result) {
      case _EditSetSubmitted(:final weight, :final unit, :final reps):
        widget.onEditSet(set.id, weight, unit, reps);
      case _EditSetDeleted():
        widget.onDeleteSet(set.id);
      case null:
        break;
    }
  }

  Future<void> _deleteEntry() async {
    final count = widget.entry.sets.length;
    final message = count == 0
        ? 'Delete this Exercise Entry?'
        : 'Delete this Exercise Entry and all $count of its Sets?';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDeleteDialog(message: message),
    );
    if (confirmed != true) return;
    widget.onDeleteEntry();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = widget.selected ? theme.colorScheme.secondaryContainer : null;
    return Material(
      key: ValueKey('entry-${widget.entry.id}'),
      color: tint ?? Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            key: ValueKey('entry-header-${widget.entry.id}'),
            onTap: widget.locked ? null : widget.onSelect,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.exerciseName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    key: ValueKey('delete-entry-${widget.entry.id}'),
                    icon: const Icon(Icons.delete),
                    onPressed: _deleteEntry,
                  ),
                ],
              ),
            ),
          ),
          if (widget.entry.sets.isNotEmpty) _columnHeaderRow(theme),
          for (var i = 0; i < widget.entry.sets.length; i++) ...[
            const Divider(height: 1, indent: _setColumnWidth + 16),
            _setRow(theme, i, widget.entry.sets[i]),
          ],
        ],
      ),
    );
  }

  Widget _columnHeaderRow(ThemeData theme) {
    final style = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.6,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          SizedBox(width: _setColumnWidth, child: Text('SET', style: style)),
          Expanded(child: Text('WEIGHT', style: style)),
          Expanded(child: Text('REPS', style: style)),
          SizedBox(
            width: _timeColumnWidth,
            child: widget.locked
                ? Text('TIME', style: style, textAlign: TextAlign.right)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _setRow(ThemeData theme, int index, ExerciseSet set) {
    final mutedStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return InkWell(
      key: ValueKey('set-${set.id}'),
      onTap: () => _openEditDialog(set),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: _setColumnWidth,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: theme.colorScheme.surfaceContainerHigh,
                child: Text(
                  '${index + 1}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                '${set.weight} ${set.unit.name}',
                key: ValueKey('set-weight-${set.id}'),
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Expanded(
              child: Text(
                '${set.reps}',
                key: ValueKey('set-reps-${set.id}'),
                style: mutedStyle,
              ),
            ),
            SizedBox(
              width: _timeColumnWidth,
              child: widget.locked
                  ? Text(
                      TimeOfDay.fromDateTime(set.loggedAt).format(context),
                      key: ValueKey('set-time-${set.id}'),
                      textAlign: TextAlign.right,
                      style: mutedStyle?.copyWith(fontSize: 12),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

num _normalizeStepValue(num value) {
  if (value is int) return value;
  final rounded = value.roundToDouble();
  return value == rounded ? value.toInt() : value;
}

class _AddSetBar extends StatefulWidget {
  final WeightUnit initialUnit;
  final void Function(num weight, WeightUnit unit, int reps) onAddSet;
  final void Function(WeightUnit unit) onUnitChanged;

  const _AddSetBar({
    super.key,
    required this.initialUnit,
    required this.onAddSet,
    required this.onUnitChanged,
  });

  @override
  State<_AddSetBar> createState() => _AddSetBarState();
}

class _AddSetBarState extends State<_AddSetBar> {
  late WeightUnit _unit;
  num _weight = 0;
  int _reps = 0;

  @override
  void initState() {
    super.initState();
    _unit = widget.initialUnit;
  }

  num get _weightStep => _unit == WeightUnit.kg ? 2.5 : 5;

  void _setUnit(WeightUnit unit) {
    setState(() => _unit = unit);
    widget.onUnitChanged(unit);
  }

  void _submit() {
    if (_reps <= 0) return;
    widget.onAddSet(_weight, _unit, _reps);
    setState(() {
      _weight = 0;
      _reps = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('add-set-bar'),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NumberStepper(
                  keyPrefix: 'weight-stepper',
                  value: _weight,
                  step: _weightStep,
                  allowNegative: true,
                  onChanged: (value) => setState(() => _weight = value),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  key: const ValueKey('unit-kg'),
                  label: const Text('kg'),
                  showCheckmark: false,
                  selected: _unit == WeightUnit.kg,
                  onSelected: (_) => _setUnit(WeightUnit.kg),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  key: const ValueKey('unit-lbs'),
                  label: const Text('lbs'),
                  showCheckmark: false,
                  selected: _unit == WeightUnit.lbs,
                  onSelected: (_) => _setUnit(WeightUnit.lbs),
                ),
                const SizedBox(width: 8),
                _NumberStepper(
                  keyPrefix: 'reps-stepper',
                  value: _reps,
                  step: 1,
                  onChanged: (value) =>
                      setState(() => _reps = value.toInt()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const ValueKey('add-set'),
              onPressed: _reps > 0 ? _submit : null,
              child: const Text('Add Set'),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberStepper extends StatelessWidget {
  final String keyPrefix;
  final num value;
  final num step;
  final bool allowNegative;
  final void Function(num value) onChanged;

  const _NumberStepper({
    required this.keyPrefix,
    required this.value,
    required this.step,
    this.allowNegative = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          key: ValueKey('$keyPrefix-decrement'),
          icon: const Icon(Icons.remove),
          onPressed: (allowNegative || value > 0)
              ? () => onChanged(_normalizeStepValue(value - step))
              : null,
        ),
        SizedBox(
          width: 40,
          child: Text(
            '${_normalizeStepValue(value)}',
            key: ValueKey('$keyPrefix-value'),
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          key: ValueKey('$keyPrefix-increment'),
          icon: const Icon(Icons.add),
          onPressed: () => onChanged(_normalizeStepValue(value + step)),
        ),
      ],
    );
  }
}

sealed class _EditSetDialogResult {}

class _EditSetSubmitted extends _EditSetDialogResult {
  final num weight;
  final WeightUnit unit;
  final int reps;

  _EditSetSubmitted({
    required this.weight,
    required this.unit,
    required this.reps,
  });
}

class _EditSetDeleted extends _EditSetDialogResult {}

class _EditSetDialog extends StatefulWidget {
  final ExerciseSet set;

  const _EditSetDialog({required this.set});

  @override
  State<_EditSetDialog> createState() => _EditSetDialogState();
}

class _EditSetDialogState extends State<_EditSetDialog> {
  late final TextEditingController _weightController;
  late final TextEditingController _repsController;
  late WeightUnit _selectedUnit;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.set.weight.toString(),
    );
    _repsController = TextEditingController(text: widget.set.reps.toString());
    _selectedUnit = widget.set.unit;
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _submit() {
    final parsed = ExerciseSet.parseInput(
      _weightController.text,
      _repsController.text,
    );
    if (parsed == null) return;

    Navigator.pop(
      context,
      _EditSetSubmitted(
        weight: parsed.weight,
        unit: _selectedUnit,
        reps: parsed.reps,
      ),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          const ConfirmDeleteDialog(message: 'Delete this Set?'),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    Navigator.pop(context, _EditSetDeleted());
  }

  @override
  Widget build(BuildContext context) {
    final setId = widget.set.id;
    return AlertDialog(
      title: const Text('Edit Set'),
      content: Row(
        children: [
          Expanded(
            child: TextField(
              key: ValueKey('edit-weight-$setId'),
              controller: _weightController,
              decoration: const InputDecoration(hintText: 'Weight'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            key: ValueKey('edit-unit-kg-$setId'),
            label: const Text('kg'),
            selected: _selectedUnit == WeightUnit.kg,
            onSelected: (_) => setState(() => _selectedUnit = WeightUnit.kg),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            key: ValueKey('edit-unit-lbs-$setId'),
            label: const Text('lbs'),
            selected: _selectedUnit == WeightUnit.lbs,
            onSelected: (_) => setState(() => _selectedUnit = WeightUnit.lbs),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              key: ValueKey('edit-reps-$setId'),
              controller: _repsController,
              decoration: const InputDecoration(hintText: 'Reps'),
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          key: ValueKey('edit-delete-$setId'),
          onPressed: _delete,
          child: const Text('Delete'),
        ),
        TextButton(
          key: ValueKey('edit-cancel-$setId'),
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          key: ValueKey('edit-submit-$setId'),
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
