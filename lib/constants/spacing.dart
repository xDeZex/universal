class AppSpacing {
  AppSpacing._();

  // Standard spacing values
  static const double xs = 2.0;      // Extra small spacing (badge padding, small gaps)
  static const double sm = 4.0;      // Small spacing (tight elements, icon gaps)
  static const double md = 8.0;      // Medium spacing (button padding, moderate gaps)
  static const double lg = 12.0;     // Large spacing (card spacing, section gaps)
  static const double xl = 16.0;     // Extra large spacing (main padding, screen margins)
  static const double xxl = 24.0;    // Extra extra large spacing (major sections)

  // Specific use cases
  static const double screenPadding = xl;           // 16px - Main screen content padding
  static const double cardPadding = xl;             // 16px - Internal card padding
  static const double cardMargin = lg;              // 12px - Spacing between cards
  static const double sectionGap = lg;              // 12px - Gap between sections
  static const double formFieldGap = lg;            // 12px - Gap between form fields
  static const double buttonPadding = md;           // 8px - Internal button padding
  static const double iconGap = sm;                 // 4px - Gap next to icons
  static const double elementGap = sm;              // 4px - Small gap between related elements
  static const double badgePadding = xs;            // 2px - Badge vertical padding
  static const double sectionHeaderGap = md;       // 8px - Gap around section headers
  static const double dividerPadding = md;         // 8px - Padding around dividers
}