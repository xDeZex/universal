class ChartConstants {
  // Chart dimensions
  static const double chartHeight = 200.0;
  static const double reservedSizeStandard = 50.0;
  static const double reservedSizeBottom = 30.0;
  
  // Chart styling
  static const double lineWidth = 3.0;
  static const double dotRadius = 5.0;
  static const double dotStrokeWidth = 2.0;
  static const double gridLineStrokeWidth = 1.0;
  static const double legendLineWidth = 12.0;
  static const double legendLineHeight = 3.0;
  static const double legendBorderRadius = 1.5;
  
  // Spacing and padding
  static const double cardBottomMargin = 16.0;
  static const double cardPadding = 16.0;
  static const double sectionSpacing = 16.0;
  static const double smallSpacing = 8.0;
  static const double tinySpacing = 4.0;
  static const double mediumSpacing = 12.0;
  static const double legendSpacing = 24.0;
  static const double legendItemSpacing = 6.0;
  static const double rightTitleLeftPadding = 12.0;
  static const double bottomTitleTopPadding = 8.0;
  
  // Chart calculations
  static const double weightPaddingRatio = 0.1;
  static const double volumePaddingRatio = 0.15;
  static const double defaultWeightPadding = 5.0;
  static const double defaultVolumePadding = 2.0;
  static const int targetIntervals = 5;
  static const int maxTicks = 8;
  static const double intervalToleranceRatio = 0.1;
  static const double edgeFilterRatio = 0.1;
  static const double volumeIntervalToleranceRatio = 0.3;
  
  // Alpha values
  static const double gridAlpha = 0.3;
  static const double belowBarAlpha = 0.1;
  
  // Font sizes
  static const double titleFontSize = 20.0;
  static const double subtitleFontSize = 14.0;
  static const double latestWeightFontSize = 24.0;
  static const double latestLabelFontSize = 12.0;
  static const double axisTitleFontSize = 10.0;
  static const double legendFontSize = 12.0;
  static const double statValueFontSize = 14.0;
  static const double statLabelFontSize = 10.0;
  static const double statIconSize = 16.0;
  
  // Default chart values
  static const double defaultMinWeightY = 0.0;
  static const double defaultMaxWeightY = 100.0;
  static const double defaultMinVolumeY = 0.0;
  static const double defaultMaxVolumeY = 50.0;
  static const double defaultWeightInterval = 10.0;
  static const double defaultVolumeInterval = 10.0;
  static const double defaultBottomInterval = 1.0;
  
  // Volume interval thresholds
  static const double volumeRangeSmall = 3.0;
  static const double volumeRangeMediumSmall = 8.0;
  static const double volumeRangeMedium = 15.0;
  static const double volumeIntervalSmall = 1.0;
  static const double volumeIntervalMediumSmall = 2.0;
  static const double volumeIntervalMedium = 5.0;
  static const double volumeIntervalMinimum = 2.0;
  
  // Chart filtering
  static const int bottomIntervalThreshold = 10;
  static const int bottomIntervalDivisor = 5;
}