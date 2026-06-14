import 'package:flutter/material.dart';
import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/admin/models/student_sponsorship_link.dart';
import 'package:kitoapp/features/admin/widgets/admin_sponsorship_hero.dart';
import 'package:kitoapp/features/admin/widgets/admin_sponsorship_summary_card.dart';
import 'package:kitoapp/features/admin/widgets/assign_sponsor_sheet.dart';
import 'package:kitoapp/features/admin/widgets/sponsorship_actions_sheet.dart';
import 'package:kitoapp/features/admin/widgets/sponsorship_filter_bar.dart';
import 'package:kitoapp/features/admin/widgets/student_sponsorship_tile.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/app_scaffold.dart';
import 'package:kitoapp/shared/widgets/compassion_management_store_provider.dart';

class AdminManageSponsorshipContent extends StatefulWidget {
  const AdminManageSponsorshipContent({super.key});

  @override
  State<AdminManageSponsorshipContent> createState() =>
      _AdminManageSponsorshipContentState();
}

class _AdminManageSponsorshipContentState
    extends State<AdminManageSponsorshipContent> {
  SponsorshipFilter _filter = SponsorshipFilter.all;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CompassionManagementStoreProvider.of(context).loadSponsorshipData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAssignSponsor({
    required String studentId,
    required String studentName,
  }) {
    final store = CompassionManagementStoreProvider.of(context);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    showAssignSponsorSheet(
      context,
      studentName: studentName,
      sponsors: store.selectableSponsorsForStudent(studentId),
      onSelected: (sponsor) async {
        final success = await store.assignSponsor(
          studentId: studentId,
          studentName: studentName,
          sponsorId: sponsor.id,
        );
        if (!context.mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              success ? l10n.sponsorAssigned : l10n.reportGenerateFailed,
            ),
          ),
        );
      },
    );
  }

  void _openActions({
    required String studentId,
    required String studentName,
    required StudentSponsorshipLink? link,
  }) {
    final store = CompassionManagementStoreProvider.of(context);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    showSponsorshipActionsSheet(
      context,
      studentId: studentId,
      studentName: studentName,
      link: link,
      onAssignOrChange: () => _openAssignSponsor(
        studentId: studentId,
        studentName: studentName,
      ),
      onRemove: () async {
        final success = await store.removeSponsorLink(studentId);
        if (!context.mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              success ? l10n.sponsorLinkRemoved : l10n.reportGenerateFailed,
            ),
          ),
        );
      },
    );
  }

  void _openAddSponsor() {
    final store = CompassionManagementStoreProvider.of(context);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    showAddSponsorSheet(
      context,
      onSave: (name, country, email) async {
        final success = await store.addSponsor(
          name: name,
          country: country,
          email: email,
        );
        if (!context.mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              success ? l10n.sponsorAdded : l10n.reportGenerateFailed,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = CompassionManagementStoreProvider.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        if (store.sponsorshipLoading &&
            store.students.isEmpty &&
            store.sponsors.isEmpty) {
          return const ColoredBox(
            color: AppColors.background,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final entries = store.studentsWithLinks(
          filter: _filter,
          query: _query,
        );

        return ColoredBox(
          color: AppColors.primary.withValues(alpha: 0.03),
          child: Stack(
            fit: StackFit.expand,
            children: [
              RefreshIndicator(
                onRefresh: store.loadSponsorshipData,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Column(
                          children: [
                            const AdminSponsorshipHero(),
                            const SizedBox(height: 18),
                            AdminSponsorshipSummaryCard(
                              summary: store.sponsorshipSummary,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _searchController,
                              onChanged: (value) =>
                                  setState(() => _query = value),
                              decoration: InputDecoration(
                                hintText: l10n.searchStudentsOrSponsors,
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: AppColors.primary,
                                ),
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SponsorshipFilterBar(
                        value: _filter,
                        onChanged: (value) =>
                            setState(() => _filter = value),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Text(
                          l10n.studentSponsorLinks,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    if (entries.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            l10n.noStudentsFound,
                            style: TextStyle(
                              color:
                                  AppColors.text.withValues(alpha: 0.45),
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final entry = entries[index];
                              return StudentSponsorshipTile(
                                studentName: entry.name,
                                university: entry.university,
                                link: entry.link,
                                onTap: () => _openActions(
                                  studentId: entry.id,
                                  studentName: entry.name,
                                  link: entry.link,
                                ),
                              );
                            },
                            childCount: entries.length,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton.extended(
                  onPressed: _openAddSponsor,
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  icon: const Icon(Icons.person_add_outlined),
                  label: Text(l10n.addSponsor),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AdminManageSponsorshipScreen extends StatelessWidget {
  const AdminManageSponsorshipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.manageSponsorship,
      body: const AdminManageSponsorshipContent(),
    );
  }
}
