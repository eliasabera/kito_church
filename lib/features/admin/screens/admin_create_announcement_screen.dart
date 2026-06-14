import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/admin/widgets/admin_announcements_hero.dart';
import 'package:kitoapp/features/admin/widgets/create_announcement_sheet.dart';
import 'package:kitoapp/features/admin/widgets/managed_announcement_tile.dart';
import 'package:kitoapp/features/announcements/models/announcement_item.dart';
import 'package:kitoapp/features/announcements/services/announcements_store.dart';
import 'package:kitoapp/features/announcements/widgets/announcement_filter_bar.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/announcements_store_provider.dart';
import 'package:kitoapp/shared/widgets/app_scaffold.dart';
import 'package:kitoapp/shared/widgets/app_toast.dart';

class AdminCreateAnnouncementContent extends StatefulWidget {
  const AdminCreateAnnouncementContent({super.key});

  @override
  State<AdminCreateAnnouncementContent> createState() =>
      _AdminCreateAnnouncementContentState();
}

class _AdminCreateAnnouncementContentState
    extends State<AdminCreateAnnouncementContent> {
  String? _filter;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnnouncementsStoreProvider.of(context).loadFromSupabase();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(String id) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAnnouncement),
        content: Text(l10n.deleteAnnouncementConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await AnnouncementsStoreProvider.of(context).deleteAnnouncement(id);
    if (!mounted) return;
    AppToast.showSuccess(context, l10n.announcementDeleted);
  }

  Future<void> _confirmDeleteCategory(
    AnnouncementCategoryItem category,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCategory),
        content: Text(l10n.deleteCategoryConfirm(category.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final store = AnnouncementsStoreProvider.of(context);
    final result = await store.deleteCategory(category.id);
    if (!mounted) return;

    final message = switch (result) {
      CategoryDeleteResult.success => l10n.categoryDeleted,
      CategoryDeleteResult.lastCategory => l10n.categoryDeleteLastOne,
      CategoryDeleteResult.inUse => l10n.categoryDeleteInUse,
      CategoryDeleteResult.failed => l10n.categoryDeleteFailed,
    };

    if (result == CategoryDeleteResult.success) {
      AppToast.showSuccess(context, message);
      if (_filter == category.id) {
        setState(() => _filter = null);
      }
    } else {
      AppToast.showError(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = AnnouncementsStoreProvider.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        if (store.isLoading && store.allItems.isEmpty) {
          return const ColoredBox(
            color: AppColors.background,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final items = store.adminItemsFor(categoryId: _filter, query: _query);

        return ColoredBox(
          color: AppColors.primary.withValues(alpha: 0.03),
          child: Stack(
            fit: StackFit.expand,
            children: [
              RefreshIndicator(
                onRefresh: () => store.loadFromSupabase(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Column(
                        children: [
                          const AdminAnnouncementsHero(),
                          const SizedBox(height: 18),
                          AdminAnnouncementsSummaryCard(
                            summary: store.adminSummary,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _searchController,
                            onChanged: (value) =>
                                setState(() => _query = value),
                            decoration: InputDecoration(
                              hintText: l10n.searchAnnouncements,
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
                    child: AnnouncementFilterBar(
                      categories: store.categories,
                      value: _filter,
                      onChanged: (value) => setState(() => _filter = value),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Text(
                        l10n.customCategories,
                        style: TextStyle(
                          color: AppColors.text.withValues(alpha: 0.55),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Row(
                        children: [
                          for (final category in store.categories)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InputChip(
                                label: Text(category.name),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () =>
                                    _confirmDeleteCategory(category),
                                backgroundColor:
                                    AppColors.primary.withValues(alpha: 0.08),
                                labelStyle: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                deleteIconColor:
                                    AppColors.primary.withValues(alpha: 0.7),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Text(
                        l10n.publishedAnnouncements,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  if (items.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          l10n.noAnnouncements,
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
                            final item = items[index];
                            return ManagedAnnouncementTile(
                              item: item,
                              categoryName:
                                  store.categoryNameFor(item.categoryId),
                              onEdit: () =>
                                  showEditAnnouncementSheet(context, existing: item),
                              onDelete: () => _confirmDelete(item.id),
                            );
                          },
                          childCount: items.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: FilledButton.icon(
                  onPressed: () => showCreateAnnouncementSheet(context),
                  icon: const Icon(Icons.campaign_outlined),
                  label: Text(l10n.createAnnouncement),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AdminCreateAnnouncementScreen extends StatelessWidget {
  const AdminCreateAnnouncementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.createAnnouncement,
      body: const AdminCreateAnnouncementContent(),
    );
  }
}
