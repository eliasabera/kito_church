import 'package:kitoapp/core/enums/app_enums.dart';

class ScoringWeight {
  const ScoringWeight({
    required this.category,
    required this.weightPercent,
  });

  final ScoringCategory category;
  final double weightPercent;
}

class ScoringConfig {
  const ScoringConfig({required this.weights});

  final List<ScoringWeight> weights;

  double get totalWeight =>
      weights.fold(0, (sum, item) => sum + item.weightPercent);

  bool get isValid => (totalWeight - 100).abs() < 0.01;
}
