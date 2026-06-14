import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/core/router/app_router.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/auth/services/auth_session.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/notifications_store_provider.dart';

class NotificationBellButton extends StatelessWidget {
  const NotificationBellButton({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    if (role != UserRole.student && role != UserRole.admin) {
      return const SizedBox.shrink();
    }

    final store = NotificationsStoreProvider.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final userId = AuthSession.userId;
        final count = role == UserRole.student
            ? (userId != null ? store.unreadCountForStudent(userId) : 0)
            : store.unreadCountForAdmin();

        final route = role == UserRole.student
            ? StudentRoutes.notifications
            : AdminRoutes.notifications;

        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: IconButton(
            tooltip: AppLocalizations.of(context).notifications,
            onPressed: () => context.push(route),
            icon: Badge(
              isLabelVisible: count > 0,
              label: Text('$count'),
              child: const Icon(
                Icons.notifications_outlined,
                color: AppColors.primary,
              ),
            ),
          ),
        );
      },
    );
  }
}
