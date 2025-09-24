import 'package:flutter/material.dart';
import '../widgets/calendar_date_card.dart';
import '../widgets/date_info_card.dart';
import '../widgets/quick_actions_card.dart';
import '../widgets/create_training_split_dialog.dart';
import '../widgets/add_event_dialog.dart';
import '../services/training_split_service.dart';
import '../models/training_split.dart';
import '../models/calendar_event.dart';
import '../utils/date_formatter.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, this.showAppBar = false});

  final bool showAppBar;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  final TrainingSplitService _trainingSplitService = TrainingSplitService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScreenTitle(context),
            CalendarDateCard(
              selectedDate: _selectedDate,
              onDateChanged: _updateSelectedDate,
              onDayTap: _showAddEventDialog,
              trainingSplitService: _trainingSplitService,
            ),
            const SizedBox(height: 24),
            DateInfoCard(
              selectedDate: _selectedDate,
              events: _trainingSplitService.getEventsForDate(_selectedDate),
            ),
            const SizedBox(height: 24),
            QuickActionsCard(
              onTodayPressed: _selectToday,
              onTomorrowPressed: _selectTomorrow,
              onCreateSplitPressed: _showCreateSplitDialog,
            ),
          ],
        ),
      ),
    );
  }

  AppBar? _buildAppBar(BuildContext context) {
    if (!widget.showAppBar) return null;
    
    final theme = Theme.of(context);
    return AppBar(
      title: const Text('Calendar'),
      backgroundColor: theme.colorScheme.surface,
    );
  }

  Widget _buildScreenTitle(BuildContext context) {
    if (widget.showAppBar) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Text(
        'Calendar',
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _updateSelectedDate(DateTime date) {
    if (DateFormatter.isValidDate(date)) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _selectToday() {
    setState(() {
      _selectedDate = DateTime.now();
    });
  }

  void _selectTomorrow() {
    setState(() {
      _selectedDate = DateTime.now().add(const Duration(days: 1));
    });
  }

  void _showCreateSplitDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateTrainingSplitDialog(
        onSplitCreated: _handleSplitCreated,
      ),
    );
  }

  void _showAddEventDialog(DateTime date) {
    showDialog(
      context: context,
      builder: (context) => AddEventDialog(
        selectedDate: date,
        onEventCreated: _handleEventCreated,
      ),
    );
  }

  void _handleSplitCreated(TrainingSplit split) {
    _trainingSplitService.addTrainingSplit(split);
    final events = _trainingSplitService.generateCalendarEvents(split);
    _trainingSplitService.addEvents(events);
    
    setState(() {
      // Trigger rebuild to show new events
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Training split "${split.name}" created successfully!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _handleEventCreated(CalendarEvent event) {
    _trainingSplitService.addEvents([event]);
    
    setState(() {
      // Trigger rebuild to show new event
      // Update selected date to the event date to show it immediately
      _selectedDate = event.date;
    });
    
    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${event.title} added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}