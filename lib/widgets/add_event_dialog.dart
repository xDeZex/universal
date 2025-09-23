import 'package:flutter/material.dart';
import '../models/calendar_event.dart';

class AddEventDialog extends StatefulWidget {
  const AddEventDialog({
    super.key,
    required this.selectedDate,
    required this.onEventCreated,
  });

  final DateTime selectedDate;
  final ValueChanged<CalendarEvent> onEventCreated;

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeController = TextEditingController();
  CalendarEventType _selectedType = CalendarEventType.general;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Text('Add Event for ${_formatDate(widget.selectedDate)}'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Event title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Event Title',
                  hintText: 'e.g., Lunch with Mom, Team Meeting',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an event title';
                  }
                  return null;
                },
                autofocus: true,
              ),
              const SizedBox(height: 16),
              
              // Event type
              DropdownButtonFormField<CalendarEventType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Event Type',
                  border: OutlineInputBorder(),
                ),
                items: CalendarEventType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(
                          _getTypeIcon(type),
                          color: _getTypeColor(theme, type),
                        ),
                        const SizedBox(width: 8),
                        Text(_getTypeDisplayName(type)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (CalendarEventType? value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Time (optional)
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Time (Optional)',
                  hintText: 'e.g., 2:30 PM, 14:30',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
              ),
              const SizedBox(height: 16),
              
              // Description (optional)
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add any notes about this event',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _createEvent,
          child: const Text('Add Event'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getTypeDisplayName(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.workout:
        return 'Workout';
      case CalendarEventType.restDay:
        return 'Rest Day';
      case CalendarEventType.general:
        return 'General';
    }
  }

  IconData _getTypeIcon(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.workout:
        return Icons.fitness_center;
      case CalendarEventType.restDay:
        return Icons.hotel;
      case CalendarEventType.general:
        return Icons.event;
    }
  }

  Color _getTypeColor(ThemeData theme, CalendarEventType type) {
    switch (type) {
      case CalendarEventType.workout:
        return theme.colorScheme.primary;
      case CalendarEventType.restDay:
        return theme.colorScheme.secondary;
      case CalendarEventType.general:
        return theme.colorScheme.tertiary;
    }
  }

  void _createEvent() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final event = CalendarEvent(
      id: _generateEventId(),
      title: _titleController.text.trim(),
      date: widget.selectedDate,
      trainingSplitId: 'user_created', // Special ID for user-created events
      type: _selectedType,
      description: _descriptionController.text.trim().isNotEmpty 
          ? _descriptionController.text.trim() 
          : null,
      time: _timeController.text.trim().isNotEmpty 
          ? _timeController.text.trim() 
          : null,
      isCompleted: false,
    );

    widget.onEventCreated(event);
    Navigator.of(context).pop();
  }

  String _generateEventId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'event_$timestamp';
  }
}