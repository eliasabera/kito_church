import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/learning/widgets/learning_path_road.dart';
import 'package:kitoapp/features/learning/widgets/learning_stats_bar.dart';
import 'package:kitoapp/shared/widgets/learning_progress_provider.dart';

class StudentLearningContent extends StatelessWidget {
  const StudentLearningContent({super.key});

  @override
  Widget build(BuildContext context) {
    final store = LearningProgressProvider.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        return ColoredBox(
          color: AppColors.primary.withValues(alpha: 0.03),
          child: Column(
            children: [
              LearningStatsBar(stats: store.stats),
              const Expanded(child: LearningPathRoad()),
            ],
          ),
        );
      },
    );
  }
}
