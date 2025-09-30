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
  CalendarEventType _selectedType = CalendarEventType.general;
  bool _isAllDay = true;
  TimeOfDay? _startTime;
  Duration? _duration;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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

              // All day toggle
              CheckboxListTile(
                title: const Text('All day'),
                value: _isAllDay,
                onChanged: (bool? value) {
                  setState(() {
                    _isAllDay = value ?? true;
                    if (_isAllDay) {
                      _startTime = null;
                      _duration = null;
                    }
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),

              // Time selection (only shown if not all day)
              if (!_isAllDay) ...[const SizedBox(height: 16), _buildTimeSection()],
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
      startTime: _startTime,
      duration: _duration,
      isAllDay: _isAllDay,
      isCompleted: false,
    );

    widget.onEventCreated(event);
    Navigator.of(context).pop();
  }

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Start time
        InkWell(
          onTap: _selectStartTime,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Start Time',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.access_time),
            ),
            child: Text(
              _startTime != null ? _formatTimeOfDay(_startTime!) : 'Select time',
              style: TextStyle(
                color: _startTime != null ? null : Theme.of(context).hintColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Duration selection
        InkWell(
          onTap: _selectDuration,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Duration (Optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.timer),
            ),
            child: Text(
              _duration != null ? _formatDuration(_duration!) : 'No end time',
              style: TextStyle(
                color: _duration != null ? null : Theme.of(context).hintColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectDuration() async {
    final List<Duration> commonDurations = [
      const Duration(minutes: 15),
      const Duration(minutes: 30),
      const Duration(minutes: 45),
      const Duration(hours: 1),
      const Duration(hours: 1, minutes: 30),
      const Duration(hours: 2),
      const Duration(hours: 3),
      const Duration(hours: 4),
    ];

    final Duration? picked = await showDialog<Duration>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Duration'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400, // Constrain height to prevent overflow
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('No end time'),
                  onTap: () => Navigator.of(context).pop(null),
                  selected: _duration == null,
                ),
                const Divider(),
                ...commonDurations.map((duration) => ListTile(
                  title: Text(_formatDuration(duration)),
                  onTap: () => Navigator.of(context).pop(duration),
                  selected: _duration == duration,
                )),
              ],
            ),
          ),
        ),
      ),
    );

    setState(() {
      _duration = picked;
    });
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  String _generateEventId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'event_$timestamp';
  }
}