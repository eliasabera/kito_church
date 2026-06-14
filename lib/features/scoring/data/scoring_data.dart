import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/shared/models/scoring_config.dart';

class ScoringData {
  ScoringData._();

  static const categories = [
    ScoringCategory.attendance,
    ScoringCategory.quiz,
    ScoringCategory.assignment,
  ];

  static const initialWeights = {
    ScoringCategory.attendance: 40.0,
    ScoringCategory.quiz: 35.0,
    ScoringCategory.assignment: 25.0,
  };

  static ScoringConfig get initialConfig {
    return ScoringConfig(
      weights: initialWeights.entries
          .map(
            (entry) => ScoringWeight(
              category: entry.key,
              weightPercent: entry.value,
            ),
          )
          .toList(),
    );
  }
}
