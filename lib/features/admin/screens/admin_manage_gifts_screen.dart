import 'package:flutter/material.dart';
import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/admin/widgets/admin_gift_filter_bar.dart';
import 'package:kitoapp/features/admin/widgets/admin_gifts_hero.dart';
import 'package:kitoapp/features/admin/widgets/admin_gifts_summary_card.dart';
import 'package:kitoapp/features/admin/widgets/managed_gift_tile.dart';
import 'package:kitoapp/features/admin/widgets/record_gift_sheet.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/app_scaffold.dart';
import 'package:kitoapp/shared/widgets/compassion_management_store_provider.dart';

class AdminManageGiftsContent extends StatefulWidget {
  const AdminManageGiftsContent({super.key});

  @override
  State<AdminManageGiftsContent> createState() =>
      _AdminManageGiftsContentState();
}

class _AdminManageGiftsContentState extends State<AdminManageGiftsContent> {
  AdminGiftFilter _filter = AdminGiftFilter.all;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CompassionManagementStoreProvider.of(context).loadGiftData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openRecordGift() {
    final store = CompassionManagementStoreProvider.of(context);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (store.links.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.noSponsoredStudentsForGifts)),
      );
      return;
    }

    showRecordGiftSheet(
      context,
      sponsoredStudents: store.links,
      onSave: (studentId, title, description, type) async {
        final success = await store.addGift(
          studentId: studentId,
          title: title,
          description: description,
          type: type,
        );
        if (success) {
          messenger.showSnackBar(SnackBar(content: Text(l10n.giftRecorded)));
        } else {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.reportGenerateFailed)),
          );
        }
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
        if (store.giftsLoading && store.gifts.isEmpty) {
          return const ColoredBox(
            color: AppColors.background,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final gifts = store.filteredGifts(filter: _filter, query: _query);

        return ColoredBox(
          color: AppColors.primary.withValues(alpha: 0.03),
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: store.loadGiftData,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Column(
                          children: [
                            const AdminGiftsHero(),
                            const SizedBox(height: 18),
                            AdminGiftsSummaryCard(
                              summary: store.giftSummary,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _searchController,
                              onChanged: (value) =>
                                  setState(() => _query = value),
                              decoration: InputDecoration(
                                hintText: l10n.searchGifts,
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
                      child: AdminGiftFilterBar(
                        value: _filter,
                        onChanged: (value) =>
                            setState(() => _filter = value),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Text(
                          l10n.giftNotifications,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    if (gifts.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            l10n.noGifts,
                            style: TextStyle(
                              color: AppColors.text.withValues(alpha: 0.45),
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
                              final gift = gifts[index];
                              return ManagedGiftTile(
                                gift: gift,
                                onAnnounce: () async {
                                  final success =
                                      await store.announceGift(gift.id);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? l10n.giftAnnounced
                                            : l10n.reportGenerateFailed,
                                      ),
                                    ),
                                  );
                                },
                                onUpdateStatus: (status) async {
                                  await store.updateGiftStatus(
                                    gift.id,
                                    status,
                                  );
                                },
                              );
                            },
                            childCount: gifts.length,
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
                  onPressed: _openRecordGift,
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  icon: const Icon(Icons.add_box_outlined),
                  label: Text(l10n.recordGift),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AdminManageGiftsScreen extends StatelessWidget {
  const AdminManageGiftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.manageGifts,
      body: const AdminManageGiftsContent(),
    );
  }
}
