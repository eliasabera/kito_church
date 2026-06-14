import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/profile_store_provider.dart';

class StudentHomeHero extends StatelessWidget {
  const StudentHomeHero({super.key});

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 17) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profileStore = ProfileStoreProvider.of(context);

    return ListenableBuilder(
      listenable: profileStore,
      builder: (context, _) {
        final fullName = profileStore.profile?.fullName;
        final firstName = fullName?.split(' ').first;
        final greetingLine = firstName == null || firstName.isEmpty
            ? _greeting(l10n)
            : '${_greeting(l10n)}, $firstName';

        return Container(
          height: 200,
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
                'https://images.unsplash.com/photo-1438232992991-995b7058bbb3?w=900&q=80',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const _HeroFallback(),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const _HeroFallback();
                },
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.55),
                      const Color(0xFF003D6B).withValues(alpha: 0.92),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: -30,
                right: -20,
                child: Icon(
                  Icons.auto_stories_outlined,
                  size: 140,
                  color: AppColors.background.withValues(alpha: 0.06),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
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
                            Icons.church_outlined,
                            size: 14,
                            color: AppColors.background.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.sundaySchool,
                            style: TextStyle(
                              color:
                                  AppColors.background.withValues(alpha: 0.95),
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
                      greetingLine,
                      style: const TextStyle(
                        color: AppColors.background,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.homeHeroSubtitle,
                      style: TextStyle(
                        color: AppColors.background.withValues(alpha: 0.88),
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroFallback extends StatelessWidget {
  const _HeroFallback();

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
          Icons.menu_book_rounded,
          size: 72,
          color: AppColors.background.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}
