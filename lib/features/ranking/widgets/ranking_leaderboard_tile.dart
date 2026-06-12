import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/ranking/models/ranking_entry.dart';

class RankingLeaderboardTile extends StatelessWidget {
  const RankingLeaderboardTile({super.key, required this.entry});

  final RankingEntry entry;

  @override
  Widget build(BuildContext context) {
    final isTopThree = entry.rank <= 3;
    final isMe = entry.isCurrentStudent;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMe
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.12),
          width: isMe ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          _RankBadge(rank: entry.rank, highlight: isTopThree || isMe),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.name,
              style: TextStyle(
                color: AppColors.text,
                fontSize: 14,
                fontWeight: isMe ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            entry.score.toStringAsFixed(0),
            style: TextStyle(
              color: isMe ? AppColors.primary : AppColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank, required this.highlight});

  final int rank;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: Text(
        '#$rank',
        style: TextStyle(
          color: highlight ? AppColors.background : AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
