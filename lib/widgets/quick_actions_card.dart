import 'package:flutter/material.dart';

class QuickActionsCard extends StatelessWidget {
  static const double _cardPadding = 16.0;
  static const double _elementSpacing = 16.0;
  static const double _buttonSpacing = 8.0;
  const QuickActionsCard({
    super.key,
    required this.onTodayPressed,
    required this.onTomorrowPressed,
    this.onCreateSplitPressed,
  });

  final VoidCallback onTodayPressed;
  final VoidCallback onTomorrowPressed;
  final VoidCallback? onCreateSplitPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(_cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: _elementSpacing),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildDateButtons(),
        if (onCreateSplitPressed != null) ...[
          const SizedBox(height: _buttonSpacing),
          _buildFullWidthButton(
            onPressed: onCreateSplitPressed!,
            icon: Icons.add,
            label: 'Create Training Split',
          ),
        ],
      ],
    );
  }

  Widget _buildDateButtons() {
    return Row(
      children: [
        _buildExpandedButton(
          onPressed: onTodayPressed,
          label: 'Today',
        ),
        const SizedBox(width: _buttonSpacing),
        _buildExpandedButton(
          onPressed: onTomorrowPressed,
          label: 'Tomorrow',
        ),
      ],
    );
  }

  Widget _buildExpandedButton({
    required VoidCallback onPressed,
    required String label,
  }) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }

  Widget _buildFullWidthButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}