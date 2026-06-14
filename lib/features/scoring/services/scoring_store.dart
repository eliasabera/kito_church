import 'package:flutter/foundation.dart';
import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/features/scoring/data/scoring_data.dart';
import 'package:kitoapp/shared/models/scoring_config.dart';

class ScoringStore extends ChangeNotifier {
  ScoringStore()
      : _weights = Map.of(ScoringData.initialWeights);

  final Map<ScoringCategory, double> _weights;

  Map<ScoringCategory, double> get weights => Map.unmodifiable(_weights);

  double weightFor(ScoringCategory category) => _weights[category] ?? 0;

  double get totalWeight =>
      _weights.values.fold(0, (sum, value) => sum + value);

  bool get isValid => (totalWeight - 100).abs() < 0.01;

  /// Maximum weight this category can take without pushing the total over 100%.
  double maxWeightFor(ScoringCategory category) {
    final otherTotal = _weights.entries
        .where((entry) => entry.key != category)
        .fold(0.0, (sum, entry) => sum + entry.value);
    return (100 - otherTotal).clamp(0, 100);
  }

  ScoringConfig get config => ScoringConfig(
        weights: _weights.entries
            .map(
              (entry) => ScoringWeight(
                category: entry.key,
                weightPercent: entry.value,
              ),
            )
            .toList(),
      );

  void setWeight(ScoringCategory category, double value) {
    final maxAllowed = maxWeightFor(category);
    _weights[category] = value.clamp(0, maxAllowed);
    notifyListeners();
  }

  void resetToDefaults() {
    _weights
      ..clear()
      ..addAll(ScoringData.initialWeights);
    notifyListeners();
  }
}
