import 'package:flutter/material.dart';
import '../utils/date_formatter.dart';

class DateInfoCard extends StatelessWidget {
  const DateInfoCard({
    super.key,
    required this.selectedDate,
  });

  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection(
              title: 'Selected Date',
              content: DateFormatter.formatDate(selectedDate),
              theme: theme,
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              title: 'Day of Week',
              content: DateFormatter.formatWeekday(selectedDate),
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required String content,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}