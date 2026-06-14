import 'package:flutter/material.dart';
import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/admin/models/managed_user.dart';
import 'package:kitoapp/features/admin/widgets/add_edit_user_sheet.dart';
import 'package:kitoapp/features/admin/widgets/managed_user_tile.dart';
import 'package:kitoapp/features/admin/widgets/user_actions_sheet.dart';
import 'package:kitoapp/features/admin/widgets/user_management_filter_bar.dart';
import 'package:kitoapp/features/admin/widgets/user_management_summary_card.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/users_management_store_provider.dart';

class UserManagementContent extends StatefulWidget {
  const UserManagementContent({super.key});

  @override
  State<UserManagementContent> createState() => _UserManagementContentState();
}

class _UserManagementContentState extends State<UserManagementContent> {
  UserManagementFilter _filter = UserManagementFilter.all;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UsersManagementStoreProvider.of(context).load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddUser() {
    showAddEditUserSheet(context);
  }

  void _openEditUser(ManagedUser user) {
    showAddEditUserSheet(context, existing: user);
  }

  void _openActions(ManagedUser user) {
    final store = UsersManagementStoreProvider.of(context);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    showUserActionsSheet(
      context,
      user: user,
      onEdit: () => _openEditUser(user),
      onApprove: () async {
        await store.approveUser(user.id);
        if (!mounted) return;
        messenger.showSnackBar(SnackBar(content: Text(l10n.userApproved)));
      },
      onReject: () async {
        await store.rejectUser(user.id);
        if (!mounted) return;
        messenger.showSnackBar(SnackBar(content: Text(l10n.userRejected)));
      },
      onSuspend: () async {
        await store.suspendUser(user.id);
        if (!mounted) return;
        messenger.showSnackBar(SnackBar(content: Text(l10n.userSuspended)));
      },
      onReactivate: () async {
        await store.reactivateUser(user.id);
        if (!mounted) return;
        messenger.showSnackBar(SnackBar(content: Text(l10n.userReactivated)));
      },
      onDelete: () async {
        final confirmed = await confirmDeleteUser(context);
        if (confirmed != true || !mounted) return;
        await store.deleteUser(user.id);
        if (!mounted) return;
        messenger.showSnackBar(SnackBar(content: Text(l10n.userDeleted)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = UsersManagementStoreProvider.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final summary = store.summary;
        final users = store.filteredUsers(filter: _filter, query: _query);

        if (store.isLoading && users.isEmpty) {
          return const ColoredBox(
            color: AppColors.background,
            child: Center(child: CircularProgressIndicator()),
          );
        }

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
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: UserManagementSummaryCard(summary: summary),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() => _query = value),
                          style: const TextStyle(color: AppColors.text),
                          decoration: InputDecoration(
                            hintText: l10n.searchUsers,
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.primary,
                            ),
                            suffixIcon: _query.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _query = '');
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      color: AppColors.primary
                                          .withValues(alpha: 0.6),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: UserManagementFilterBar(
                        value: _filter,
                        onChanged: (value) => setState(() => _filter = value),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          l10n.allUsers,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    if (users.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 48,
                                  color: AppColors.primary
                                      .withValues(alpha: 0.25),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.noUsersFound,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.text.withValues(alpha: 0.45),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
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
                              final user = users[index];
                              return ManagedUserTile(
                                user: user,
                                onTap: () => _openActions(user),
                                onMore: () => _openActions(user),
                              );
                            },
                            childCount: users.length,
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
                  onPressed: _openAddUser,
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  icon: const Icon(Icons.person_add_outlined),
                  label: Text(l10n.addUser),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.primary.withValues(alpha: 0.03),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
        title: Text(
          l10n.manageUsers,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: const UserManagementContent(),
    );
  }
}
