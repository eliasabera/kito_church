import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kitoapp/core/router/app_router.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/learning/models/lesson_unit.dart';
import 'package:kitoapp/features/learning/services/learning_progress_store.dart';
import 'package:kitoapp/features/learning/widgets/learning_path_node.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/learning_progress_provider.dart';

class LearningPathRoad extends StatelessWidget {
  const LearningPathRoad({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = LearningProgressProvider.of(context);
    final weeks = store.weeks;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Text(
              l10n.learningPath,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < weeks.length; i++) ...[
              _WeekSection(
                week: weeks[i],
                store: store,
                isLast: i == weeks.length - 1,
              ),
              if (i < weeks.length - 1) const SizedBox(height: 8),
            ],
          ],
        );
      },
    );
  }
}

class _WeekSection extends StatelessWidget {
  const _WeekSection({
    required this.week,
    required this.store,
    required this.isLast,
  });

  final LessonWeek week;
  final LearningProgressStore store;
  final bool isLast;

  String? _currentNodeId(List<PathNode> nodes) {
    for (final node in nodes) {
      if (!node.isLocked && !node.isCompleted) {
        return node.item.id;
      }
    }
    return null;
  }

  void _openNode(BuildContext context, PathNode node) {
    if (node.isLocked) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            node.type == PathNodeType.lesson
                ? l10n.weekLocked
                : l10n.activityLocked,
          ),
        ),
      );
      return;
    }

    final route = switch (node.type) {
      PathNodeType.lesson => StudentRoutes.lessonReader(node.item.id),
      PathNodeType.quiz => StudentRoutes.quizPractice(node.item.id),
      PathNodeType.assignment => StudentRoutes.assignmentSubmit(node.item.id),
    };
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final weekLocked = store.isWeekLocked(week.weekNumber);
    final nodes = store.pathNodesForWeek(week);
    final currentId = _currentNodeId(nodes);

    return Column(
      children: [
        _WeekBanner(
          week: week,
          locked: weekLocked,
          lessonDone: store.isLessonCompleted(week.lesson.id),
        ),
        const SizedBox(height: 20),
        for (var i = 0; i < nodes.length; i++) ...[
          _PathRow(
            alignment: _alignmentFor(i),
            child: LearningPathNode(
              node: nodes[i],
              isCurrent: nodes[i].item.id == currentId,
              onTap: () => _openNode(context, nodes[i]),
            ),
          ),
          if (i < nodes.length - 1)
            _PathConnector(
              alignment: _connectorAlignment(i),
              height: nodes[i].type == PathNodeType.lesson ? 48 : 40,
              active: nodes[i].isCompleted,
            ),
        ],
        if (!isLast) ...[
          const SizedBox(height: 12),
          _WeekDivider(locked: weekLocked),
        ],
      ],
    );
  }

  Alignment _alignmentFor(int index) {
    return switch (index % 3) {
      0 => Alignment.center,
      1 => Alignment.centerLeft,
      _ => Alignment.centerRight,
    };
  }

  Alignment _connectorAlignment(int index) {
    final from = _alignmentFor(index);
    final to = _alignmentFor(index + 1);
    if (from == Alignment.center && to == Alignment.centerLeft) {
      return Alignment.centerLeft;
    }
    if (from == Alignment.center && to == Alignment.centerRight) {
      return Alignment.centerRight;
    }
    return Alignment.center;
  }
}

class _WeekBanner extends StatelessWidget {
  const _WeekBanner({
    required this.week,
    required this.locked,
    required this.lessonDone,
  });

  final LessonWeek week;
  final bool locked;
  final bool lessonDone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final deadline = _formatDate(week.deadline);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: locked
            ? AppColors.text.withValues(alpha: 0.06)
            : lessonDone
                ? const Color(0xFF004A85)
                : AppColors.primary,
        borderRadius: BorderRadius.circular(14),
        border: locked
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.15))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: locked
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.background.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: locked
                  ? Icon(
                      Icons.lock_outline,
                      size: 18,
                      color: AppColors.text.withValues(alpha: 0.4),
                    )
                  : lessonDone
                      ? const Icon(
                          Icons.check,
                          size: 18,
                          color: AppColors.background,
                        )
                      : Text(
                          '${week.weekNumber}',
                          style: const TextStyle(
                            color: AppColors.background,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.weekNumber(week.weekNumber),
                  style: TextStyle(
                    color: locked
                        ? AppColors.text.withValues(alpha: 0.45)
                        : AppColors.background.withValues(alpha: 0.85),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  week.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: locked ? AppColors.text : AppColors.background,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!locked)
                  Text(
                    l10n.deadlineDate(deadline),
                    style: TextStyle(
                      color: AppColors.background.withValues(alpha: 0.75),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

class _PathRow extends StatelessWidget {
  const _PathRow({required this.alignment, required this.child});

  final Alignment alignment;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(alignment: alignment, child: child);
  }
}

class _PathConnector extends StatelessWidget {
  const _PathConnector({
    required this.alignment,
    required this.height,
    required this.active,
  });

  final Alignment alignment;
  final double height;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _PathLinePainter(
          color: active
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.primary.withValues(alpha: 0.15),
          alignment: alignment,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _PathLinePainter extends CustomPainter {
  _PathLinePainter({required this.color, required this.alignment});

  final Color color;
  final Alignment alignment;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final startY = 0.0;
    final endY = size.height;

    var startX = centerX;
    var endX = centerX;

    if (alignment == Alignment.centerLeft) {
      endX = size.width * 0.28;
    } else if (alignment == Alignment.centerRight) {
      endX = size.width * 0.72;
    }

    final path = Path()
      ..moveTo(startX, startY)
      ..cubicTo(startX, endY * 0.4, endX, endY * 0.6, endX, endY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PathLinePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.alignment != alignment;
  }
}

class _WeekDivider extends StatelessWidget {
  const _WeekDivider({required this.locked});

  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: AppColors.primary.withValues(alpha: locked ? 0.1 : 0.2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.more_horiz,
              size: 18,
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          Expanded(
            child: Divider(
              color: AppColors.primary.withValues(alpha: locked ? 0.1 : 0.2),
            ),
          ),
        ],
      ),
    );
  }
}
