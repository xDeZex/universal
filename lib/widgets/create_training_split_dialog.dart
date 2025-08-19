import 'package:flutter/material.dart';
import '../models/training_split.dart';
import '../utils/id_generator.dart';

class CreateTrainingSplitDialog extends StatefulWidget {
  final Function(TrainingSplit) onSplitCreated;

  const CreateTrainingSplitDialog({
    super.key,
    required this.onSplitCreated,
  });

  @override
  State<CreateTrainingSplitDialog> createState() => _CreateTrainingSplitDialogState();
}

class _CreateTrainingSplitDialogState extends State<CreateTrainingSplitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final List<TextEditingController> _workoutControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _nameController.dispose();
    for (final controller in _workoutControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Create Training Split',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNameField(),
                      const SizedBox(height: 12),
                      
                      _buildWorkoutsSection(),
                      const SizedBox(height: 12),
                      
                      _buildDateSection(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: _buildActionButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Split Name',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'e.g., Push Pull Legs',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a split name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildWorkoutsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Workouts',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Flexible(
              child: TextButton.icon(
                onPressed: _addWorkoutField,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ..._buildWorkoutFields(),
      ],
    );
  }

  List<Widget> _buildWorkoutFields() {
    return _workoutControllers.asMap().entries.map((entry) {
      final index = entry.key;
      final controller = entry.value;
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Workout ${index + 1}',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter workout name';
                  }
                  
                  // Check for duplicates
                  final workoutNames = _workoutControllers
                      .map((c) => c.text.trim())
                      .where((name) => name.isNotEmpty)
                      .toList();
                  
                  final duplicateCount = workoutNames
                      .where((name) => name == value.trim())
                      .length;
                  
                  if (duplicateCount > 1) {
                    return 'Workout names must be unique';
                  }
                  
                  return null;
                },
              ),
            ),
            if (_workoutControllers.length > 2)
              IconButton(
                onPressed: () => _removeWorkoutField(index),
                icon: const Icon(Icons.remove_circle_outline),
                color: Colors.red,
              ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildDateField('Start Date', _startDate, _selectStartDate)),
            const SizedBox(width: 16),
            Expanded(child: _buildDateField('End Date', _endDate, _selectEndDate)),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              date != null 
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'Select ${label.toLowerCase()}',
              style: TextStyle(
                color: date != null ? Colors.black : Colors.grey[600],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: ElevatedButton(
            onPressed: _createSplit,
            child: const Text('Create'),
          ),
        ),
      ],
    );
  }

  void _addWorkoutField() {
    setState(() {
      _workoutControllers.add(TextEditingController());
    });
  }

  void _removeWorkoutField(int index) {
    if (_workoutControllers.length > 2) {
      setState(() {
        _workoutControllers[index].dispose();
        _workoutControllers.removeAt(index);
      });
    }
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _startDate = date;
        // Reset end date if it's before the new start date
        if (_endDate != null && _endDate!.isBefore(date)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final firstDate = _startDate ?? DateTime.now();
    
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? firstDate.add(const Duration(days: 7)),
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  void _createSplit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null) {
      _showErrorDialog('Please select a start date');
      return;
    }

    if (_endDate == null) {
      _showErrorDialog('Please select an end date');
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      _showErrorDialog('End date must be after start date');
      return;
    }

    final workoutNames = _workoutControllers
        .map((c) => c.text.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    if (workoutNames.isEmpty) {
      _showErrorDialog('Please add at least one workout');
      return;
    }

    try {
      final split = TrainingSplit(
        id: IdGenerator.generateUniqueId(),
        name: _nameController.text.trim(),
        workouts: workoutNames,
        startDate: _startDate!,
        endDate: _endDate!,
      );

      widget.onSplitCreated(split);
      Navigator.of(context).pop();
    } catch (e) {
      _showErrorDialog('Error creating training split: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}