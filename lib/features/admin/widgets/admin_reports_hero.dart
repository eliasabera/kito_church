import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/l10n/app_localizations.dart';

class AdminReportsHero extends StatelessWidget {
  const AdminReportsHero({super.key});

  static const _imageUrl =
      'https://images.unsplash.com/photo-1438232992991-995b7058bbb3?w=900&q=80';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            _imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const _Fallback(),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const _Fallback();
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppColors.primary.withValues(alpha: 0.5),
                  const Color(0xFF003D6B).withValues(alpha: 0.94),
                ],
              ),
            ),
          ),
          Positioned(
            top: -20,
            right: -10,
            child: Icon(
              Icons.insights_outlined,
              size: 120,
              color: AppColors.background.withValues(alpha: 0.06),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.background.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.summarize_outlined,
                        size: 14,
                        color: AppColors.background.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.reports,
                        style: TextStyle(
                          color: AppColors.background.withValues(alpha: 0.95),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  l10n.platformInsights,
                  style: const TextStyle(
                    color: AppColors.background,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.reportsHeroSubtitle,
                  style: TextStyle(
                    color: AppColors.background.withValues(alpha: 0.88),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF003D6B)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.bar_chart_rounded,
          size: 64,
          color: AppColors.background.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}
