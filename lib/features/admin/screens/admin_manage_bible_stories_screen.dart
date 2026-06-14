import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/admin/widgets/add_edit_bible_story_sheet.dart';
import 'package:kitoapp/features/admin/widgets/admin_bible_stories_hero.dart';
import 'package:kitoapp/features/admin/widgets/managed_bible_story_tile.dart';
import 'package:kitoapp/features/bible_stories/models/bible_story.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/app_scaffold.dart';
import 'package:kitoapp/shared/widgets/bible_stories_store_provider.dart';

class AdminManageBibleStoriesContent extends StatefulWidget {
  const AdminManageBibleStoriesContent({super.key});

  @override
  State<AdminManageBibleStoriesContent> createState() =>
      _AdminManageBibleStoriesContentState();
}

class _AdminManageBibleStoriesContentState
    extends State<AdminManageBibleStoriesContent> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BibleStoriesStoreProvider.of(context).load();
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
        title: Text(l10n.deleteStory),
        content: Text(l10n.deleteStoryConfirm),
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

    final success = await BibleStoriesStoreProvider.of(context).deleteStory(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? l10n.storyDeleted : l10n.reportGenerateFailed),
      ),
    );
  }

  void _openAddSheet() {
    final store = BibleStoriesStoreProvider.of(context);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    showAddEditBibleStorySheet(
      context,
      onSave: ({
        required title,
        required summary,
        localImagePath,
        pickedImage,
        imageUrl,
      }) async {
        final success = await store.addStory(
          title: title,
          summary: summary,
          localImagePath: localImagePath,
          pickedImage: pickedImage,
          imageUrl: imageUrl,
        );
        if (success) {
          messenger.showSnackBar(SnackBar(content: Text(l10n.storyAdded)));
        }
        return success;
      },
    );
  }

  void _openEditSheet(BibleStory story) {
    final store = BibleStoriesStoreProvider.of(context);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    showAddEditBibleStorySheet(
      context,
      existing: story,
      onSave: ({
        required title,
        required summary,
        localImagePath,
        pickedImage,
        imageUrl,
      }) async {
        final success = await store.updateStory(
          id: story.id,
          title: title,
          summary: summary,
          localImagePath: localImagePath,
          pickedImage: pickedImage,
          imageUrl: imageUrl,
        );
        if (success) {
          messenger.showSnackBar(SnackBar(content: Text(l10n.storyUpdated)));
        }
        return success;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = BibleStoriesStoreProvider.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        if (store.isLoading && store.allStories.isEmpty) {
          return const ColoredBox(
            color: AppColors.background,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final stories = store.filteredStories(query: _query);

        return ColoredBox(
          color: AppColors.primary.withValues(alpha: 0.03),
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: store.load,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Column(
                          children: [
                            const AdminBibleStoriesHero(),
                            const SizedBox(height: 18),
                            AdminBibleStoriesSummaryCard(
                              summary: store.summary,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _searchController,
                              onChanged: (value) =>
                                  setState(() => _query = value),
                              decoration: InputDecoration(
                                hintText: l10n.searchStories,
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
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          l10n.allStories,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    if (stories.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            l10n.noStories,
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
                              final story = stories[index];
                              return ManagedBibleStoryTile(
                                story: story,
                                onEdit: () => _openEditSheet(story),
                                onTogglePublished: () async {
                                  final success =
                                      await store.togglePublished(story.id);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? (story.published
                                                ? l10n.storyHidden
                                                : l10n.storyPublished)
                                            : l10n.reportGenerateFailed,
                                      ),
                                    ),
                                  );
                                },
                                onDelete: () => _confirmDelete(story.id),
                              );
                            },
                            childCount: stories.length,
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
                  onPressed: _openAddSheet,
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addBibleStory),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AdminManageBibleStoriesScreen extends StatelessWidget {
  const AdminManageBibleStoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.manageBibleStories,
      body: const AdminManageBibleStoriesContent(),
    );
  }
}
