import 'package:flutter/material.dart';
import '../widgets/calendar_date_card.dart';
import '../widgets/create_training_split_dialog.dart';
import '../services/training_split_service.dart';
import '../models/training_split.dart';
import '../utils/date_formatter.dart';
import 'day_detail_screen.dart';

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
  void initState() {
    super.initState();
    _initializeService();
  }

  void _initializeService() async {
    await _trainingSplitService.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.showAppBar)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              child: _buildScreenTitle(context),
            ),
          Expanded(
            child: CalendarDateCard(
              selectedDate: _selectedDate,
              onDateChanged: _updateSelectedDate,
              onDayTap: _showDayDetail,
              trainingSplitService: _trainingSplitService,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateSplitDialog,
        tooltip: 'Create Training Split',
        child: const Icon(Icons.add),
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
    return Text(
      'Calendar',
      style: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
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


  void _showCreateSplitDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateTrainingSplitDialog(
        onSplitCreated: _handleSplitCreated,
      ),
    );
  }


  void _showDayDetail(DateTime date) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DayDetailScreen(
          selectedDate: date,
          trainingSplitService: _trainingSplitService,
        ),
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

}