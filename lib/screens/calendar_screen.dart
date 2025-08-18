import 'package:flutter/material.dart';
import '../widgets/calendar_date_card.dart';
import '../widgets/date_info_card.dart';
import '../widgets/quick_actions_card.dart';
import '../utils/date_formatter.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, this.showAppBar = false});

  final bool showAppBar;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();

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
            ),
            const SizedBox(height: 24),
            DateInfoCard(selectedDate: _selectedDate),
            const SizedBox(height: 24),
            QuickActionsCard(
              onTodayPressed: _selectToday,
              onTomorrowPressed: _selectTomorrow,
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
}