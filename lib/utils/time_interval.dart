enum TimeInterval {
  week(7, 'Week'),
  month(30, 'Month'),
  threeMonths(90, '3 Months'),
  sixMonths(180, '6 Months'),
  year(365, 'Year'),
  all(0, 'All Time');

  const TimeInterval(this.days, this.label);
  final int days;
  final String label;
}