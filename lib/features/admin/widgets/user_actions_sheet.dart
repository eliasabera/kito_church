import 'package:flutter/material.dart';
import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/admin/models/managed_user.dart';
import 'package:kitoapp/features/admin/widgets/add_edit_user_sheet.dart';
import 'package:kitoapp/features/admin/widgets/add_edit_user_sheet.dart'
    show managedUserStatusLabel;
import 'package:kitoapp/l10n/app_localizations.dart';

void showUserActionsSheet(
  BuildContext context, {
  required ManagedUser user,
  required VoidCallback onEdit,
  required VoidCallback onApprove,
  required VoidCallback onReject,
  required VoidCallback onSuspend,
  required VoidCallback onReactivate,
  required VoidCallback onDelete,
}) {
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _UserActionsSheet(
      user: user,
      onEdit: () {
        Navigator.of(sheetContext, rootNavigator: true).pop();
        onEdit();
      },
      onApprove: () {
        Navigator.of(sheetContext, rootNavigator: true).pop();
        onApprove();
      },
      onReject: () {
        Navigator.of(sheetContext, rootNavigator: true).pop();
        onReject();
      },
      onSuspend: () {
        Navigator.of(sheetContext, rootNavigator: true).pop();
        onSuspend();
      },
      onReactivate: () {
        Navigator.of(sheetContext, rootNavigator: true).pop();
        onReactivate();
      },
      onDelete: () {
        Navigator.of(sheetContext, rootNavigator: true).pop();
        onDelete();
      },
    ),
  );
}

class _UserActionsSheet extends StatelessWidget {
  const _UserActionsSheet({
    required this.user,
    required this.onEdit,
    required this.onApprove,
    required this.onReject,
    required this.onSuspend,
    required this.onReactivate,
    required this.onDelete,
  });

  final ManagedUser user;
  final VoidCallback onEdit;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onSuspend;
  final VoidCallback onReactivate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isPending = user.status == ManagedUserStatus.pending;
    final isSuspended = user.status == ManagedUserStatus.suspended;
    final isActive = user.status == ManagedUserStatus.active;
    final canSuspend = isActive || isPending;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      user.initials,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          managedUserStatusLabel(user.status, l10n),
                          style: TextStyle(
                            color: AppColors.primary.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _ActionTile(
              icon: Icons.edit_outlined,
              label: l10n.editUser,
              onTap: onEdit,
            ),
            if (isPending) ...[
              _ActionTile(
                icon: Icons.check_circle_outline,
                label: l10n.approve,
                onTap: onApprove,
              ),
              _ActionTile(
                icon: Icons.cancel_outlined,
                label: l10n.reject,
                onTap: onReject,
              ),
            ],
            if (canSuspend)
              _ActionTile(
                icon: Icons.pause_circle_outline,
                label: l10n.suspendUser,
                onTap: onSuspend,
              ),
            if (isSuspended)
              _ActionTile(
                icon: Icons.play_circle_outline,
                label: l10n.reactivateUser,
                onTap: onReactivate,
              ),
            _ActionTile(
              icon: Icons.delete_outline,
              label: l10n.deleteUser,
              onTap: onDelete,
              isDestructive: true,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? AppColors.primary
        : AppColors.text.withValues(alpha: 0.85);

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: isDestructive ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}

Future<bool?> confirmDeleteUser(BuildContext context) {
  final l10n = AppLocalizations.of(context);

  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.deleteUser),
      content: Text(l10n.confirmDeleteUser),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.deleteUser),
        ),
      ],
    ),
  );
}
