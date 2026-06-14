import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/auth/services/auth_session.dart';
import 'package:kitoapp/features/notifications/models/app_notification.dart';
import 'package:kitoapp/features/notifications/widgets/notification_tile.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/app_scaffold.dart';
import 'package:kitoapp/shared/widgets/notifications_store_provider.dart';
import 'package:kitoapp/shared/widgets/users_management_store_provider.dart';

class NotificationsContent extends StatefulWidget {
  const NotificationsContent({super.key, required this.audience});

  final NotificationAudience audience;

  @override
  State<NotificationsContent> createState() => _NotificationsContentState();
}

class _NotificationsContentState extends State<NotificationsContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      NotificationsStoreProvider.of(context).load();
    });
  }

  String? get _studentUserId => AuthSession.userId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = NotificationsStoreProvider.of(context);
    final usersStore = UsersManagementStoreProvider.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        if (store.isLoading && store.allItems.isEmpty) {
          return const ColoredBox(
            color: AppColors.background,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final items = widget.audience == NotificationAudience.student
            ? store.forStudent(_studentUserId ?? '')
            : store.forAdmin();

        if (items.isEmpty) {
          return RefreshIndicator(
            onRefresh: store.load,
            color: AppColors.primary,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (store.error != null) ...[
                              Text(
                                store.error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            Text(
                              l10n.noNotifications,
                              style: TextStyle(
                                color: AppColors.text.withValues(alpha: 0.45),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: store.load,
          color: AppColors.primary,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: items.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      store.markAllRead(
                        audience: widget.audience,
                        userId: widget.audience == NotificationAudience.student
                            ? _studentUserId
                            : null,
                      );
                    },
                    child: Text(l10n.markAllRead),
                  ),
                );
              }

              final notification = items[index - 1];
              return NotificationTile(
                notification: notification,
                onTap: () async {
                  await store.markRead(notification.id);
                  if (!context.mounted) return;
                  if (notification.route != null) {
                    context.push(notification.route!);
                  }
                },
                onApprove: notification.type ==
                        AppNotificationType.registrationPending &&
                    notification.userId != null
                    ? () async {
                        await usersStore.approveUser(notification.userId!);
                        await store.markRead(notification.id);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.userApproved)),
                        );
                      }
                    : null,
              );
            },
          ),
        );
      },
    );
  }
}

class StudentNotificationsScreen extends StatelessWidget {
  const StudentNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.notifications,
      body: const NotificationsContent(
        audience: NotificationAudience.student,
      ),
    );
  }
}

class AdminNotificationsScreen extends StatelessWidget {
  const AdminNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.notifications,
      body: const NotificationsContent(
        audience: NotificationAudience.admin,
      ),
    );
  }
}
