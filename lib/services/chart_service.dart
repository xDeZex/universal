import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import '../models/weight_entry.dart';
import '../models/exercise_history.dart';
import '../utils/chart_constants.dart';
import '../utils/time_interval.dart';

class ChartData {
  final List<FlSpot> weightSpots;
  final List<FlSpot> volumeSpots;
  final List<WeightEntry> entries;
  final double minX;
  final double maxX;
  final double minWeightY;
  final double maxWeightY;
  final double minVolumeY;
  final double maxVolumeY;
  final double weightInterval;
  final double volumeInterval;
  final double bottomInterval;

  const ChartData({
    required this.weightSpots,
    required this.volumeSpots,
    required this.entries,
    required this.minX,
    required this.maxX,
    required this.minWeightY,
    required this.maxWeightY,
    required this.minVolumeY,
    required this.maxVolumeY,
    required this.weightInterval,
    required this.volumeInterval,
    required this.bottomInterval,
  });

  // Legacy getters for backward compatibility
  List<FlSpot> get spots => weightSpots;
  double get minY => minWeightY;
  double get maxY => maxWeightY;
  double get horizontalInterval => weightInterval;
}

class ChartService {
  static ChartData prepareChartData(ExerciseHistory exerciseHistory, TimeInterval timeInterval) {
    final filteredEntries = _filterEntriesByTimeInterval(exerciseHistory.weightHistory, timeInterval);
    final entries = List<WeightEntry>.from(filteredEntries)..sort((a, b) => a.date.compareTo(b.date));

    if (entries.isEmpty) {
      return _createEmptyChartData();
    }

    final chartSpots = _createChartSpots(entries);
    
    if (chartSpots.weights.isEmpty && chartSpots.volumes.isEmpty) {
      return _createChartDataWithEntries(entries);
    }

    final weightRange = _calculateWeightRange(chartSpots.weights);
    final volumeRange = _calculateVolumeRange(chartSpots.volumes);
    final bottomInterval = _calculateBottomInterval(entries.length);

    return ChartData(
      weightSpots: chartSpots.weightSpots,
      volumeSpots: chartSpots.volumeSpots,
      entries: entries,
      minX: 0,
      maxX: entries.length > 1 ? (entries.length - 1).toDouble() : 1,
      minWeightY: weightRange.min,
      maxWeightY: weightRange.max,
      minVolumeY: volumeRange.min,
      maxVolumeY: volumeRange.max,
      weightInterval: weightRange.interval,
      volumeInterval: volumeRange.interval,
      bottomInterval: bottomInterval,
    );
  }

  static List<WeightEntry> _filterEntriesByTimeInterval(List<WeightEntry> entries, TimeInterval timeInterval) {
    final now = DateTime.now();
    final cutoffDate = timeInterval == TimeInterval.all 
      ? DateTime(1970)
      : now.subtract(Duration(days: timeInterval.days));
    
    return entries.where((entry) => entry.date.isAfter(cutoffDate)).toList();
  }

  static ChartData _createEmptyChartData() {
    return const ChartData(
      weightSpots: [],
      volumeSpots: [],
      entries: [],
      minX: 0,
      maxX: 1,
      minWeightY: ChartConstants.defaultMinWeightY,
      maxWeightY: ChartConstants.defaultMaxWeightY,
      minVolumeY: ChartConstants.defaultMinVolumeY,
      maxVolumeY: ChartConstants.defaultMaxVolumeY,
      weightInterval: ChartConstants.defaultWeightInterval,
      volumeInterval: ChartConstants.defaultVolumeInterval,
      bottomInterval: ChartConstants.defaultBottomInterval,
    );
  }

  static ChartData _createChartDataWithEntries(List<WeightEntry> entries) {
    return ChartData(
      weightSpots: const [],
      volumeSpots: const [],
      entries: entries,
      minX: 0,
      maxX: entries.length.toDouble(),
      minWeightY: ChartConstants.defaultMinWeightY,
      maxWeightY: ChartConstants.defaultMaxWeightY,
      minVolumeY: ChartConstants.defaultMinVolumeY,
      maxVolumeY: ChartConstants.defaultMaxVolumeY,
      weightInterval: ChartConstants.defaultWeightInterval,
      volumeInterval: ChartConstants.defaultVolumeInterval,
      bottomInterval: ChartConstants.defaultBottomInterval,
    );
  }

  static _ChartSpots _createChartSpots(List<WeightEntry> entries) {
    final weightSpots = <FlSpot>[];
    final volumeSpots = <FlSpot>[];
    final weights = <double>[];
    final volumes = <double>[];

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final weight = _extractNumericWeight(entry.weight);
      
      if (weight != null) {
        weightSpots.add(FlSpot(i.toDouble(), weight));
        weights.add(weight);
      }
      
      final volume = _calculateVolume(entry);
      
      if (entry.sets != null && entry.reps != null) {
        volumeSpots.add(FlSpot(i.toDouble(), volume));
        volumes.add(volume);
      } else {
        volumeSpots.add(FlSpot(i.toDouble(), 1.0));
        volumes.add(1.0);
      }
    }

    return _ChartSpots(
      weightSpots: weightSpots,
      volumeSpots: volumeSpots,
      weights: weights,
      volumes: volumes,
    );
  }

  static double _calculateVolume(WeightEntry entry) {
    final sets = entry.sets ?? 1;
    final reps = entry.reps ?? 1;
    return (sets * reps).toDouble();
  }

  static _RangeData _calculateWeightRange(List<double> weights) {
    if (weights.isEmpty) {
      return const _RangeData(
        min: ChartConstants.defaultMinWeightY,
        max: ChartConstants.defaultMaxWeightY,
        interval: ChartConstants.defaultWeightInterval,
      );
    }

    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final weightRange = maxWeight - minWeight;
    
    final paddingAmount = weightRange > 0 ? weightRange * ChartConstants.weightPaddingRatio : ChartConstants.defaultWeightPadding;
    final minWeightY = (minWeight - paddingAmount).clamp(0.0, double.infinity);
    final maxWeightY = maxWeight + paddingAmount;
    
    final range = maxWeightY - minWeightY;
    final interval = _calculateOptimalInterval(range, minWeightY, maxWeightY);

    return _RangeData(min: minWeightY, max: maxWeightY, interval: interval);
  }

  static _RangeData _calculateVolumeRange(List<double> volumes) {
    if (volumes.isEmpty) {
      return const _RangeData(
        min: ChartConstants.defaultMinVolumeY,
        max: ChartConstants.defaultMaxVolumeY,
        interval: ChartConstants.defaultVolumeInterval,
      );
    }

    final minVolume = volumes.reduce((a, b) => a < b ? a : b);
    final maxVolume = volumes.reduce((a, b) => a > b ? a : b);
    final volumeRange = maxVolume - minVolume;
    
    final paddingAmount = volumeRange > 0 ? volumeRange * ChartConstants.volumePaddingRatio : ChartConstants.defaultVolumePadding;
    final minVolumeY = (minVolume - paddingAmount).clamp(0.0, double.infinity);
    final maxVolumeY = maxVolume + paddingAmount;
    
    final range = maxVolumeY - minVolumeY;
    final interval = _calculateVolumeInterval(range, minVolumeY, maxVolumeY);

    return _RangeData(min: minVolumeY, max: maxVolumeY, interval: interval);
  }

  static double _calculateVolumeInterval(double range, double minY, double maxY) {
    if (range <= ChartConstants.volumeRangeSmall) {
      return ChartConstants.volumeIntervalSmall;
    } else if (range <= ChartConstants.volumeRangeMediumSmall) {
      return ChartConstants.volumeIntervalMediumSmall;
    } else if (range <= ChartConstants.volumeRangeMedium) {
      return ChartConstants.volumeIntervalMedium;
    } else {
      final interval = _calculateOptimalInterval(range, minY, maxY);
      return interval.clamp(ChartConstants.volumeIntervalMinimum, double.infinity);
    }
  }

  static double _calculateBottomInterval(int entriesLength) {
    return entriesLength > ChartConstants.bottomIntervalThreshold 
      ? (entriesLength / ChartConstants.bottomIntervalDivisor).round().toDouble() 
      : ChartConstants.defaultBottomInterval;
  }

  static double _calculateOptimalInterval(double range, double minY, double maxY) {
    if (range <= 0) return ChartConstants.defaultWeightPadding;
    
    final roughInterval = range / ChartConstants.targetIntervals;
    final magnitude = _getMagnitude(roughInterval);
    final normalizedInterval = roughInterval / magnitude;
    
    double niceInterval;
    if (normalizedInterval <= 1) {
      niceInterval = magnitude;
    } else if (normalizedInterval <= 2) {
      niceInterval = magnitude * 2;
    } else if (normalizedInterval <= 5) {
      niceInterval = magnitude * 5;
    } else {
      niceInterval = magnitude * 10;
    }
    
    final numberOfTicks = (range / niceInterval).ceil();
    if (numberOfTicks > ChartConstants.maxTicks) {
      niceInterval = niceInterval * 2;
    }
    
    return niceInterval;
  }
  
  static double _getMagnitude(double value) {
    if (value <= 0) return 1.0;
    return math.pow(10, (math.log(value) / math.ln10).floor()).toDouble();
  }

  static double? _extractNumericWeight(String weight) {
    final regex = RegExp(r'(\d+(?:\.\d+)?)');
    final match = regex.firstMatch(weight);
    return match != null ? double.tryParse(match.group(1)!) : null;
  }
}

class _ChartSpots {
  final List<FlSpot> weightSpots;
  final List<FlSpot> volumeSpots;
  final List<double> weights;
  final List<double> volumes;

  _ChartSpots({
    required this.weightSpots,
    required this.volumeSpots,
    required this.weights,
    required this.volumes,
  });
}

class _RangeData {
  final double min;
  final double max;
  final double interval;

  const _RangeData({
    required this.min,
    required this.max,
    required this.interval,
  });
}