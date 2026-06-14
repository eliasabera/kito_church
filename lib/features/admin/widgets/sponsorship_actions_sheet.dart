import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/admin/models/student_sponsorship_link.dart';
import 'package:kitoapp/l10n/app_localizations.dart';

void showSponsorshipActionsSheet(
  BuildContext context, {
  required String studentId,
  required String studentName,
  required StudentSponsorshipLink? link,
  required VoidCallback onAssignOrChange,
  required VoidCallback onRemove,
}) {
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _SponsorshipActionsSheet(
      studentName: studentName,
      link: link,
      onAssignOrChange: () {
        Navigator.of(sheetContext, rootNavigator: true).pop();
        onAssignOrChange();
      },
      onRemove: link == null
          ? null
          : () {
              Navigator.of(sheetContext, rootNavigator: true).pop();
              onRemove();
            },
    ),
  );
}

class _SponsorshipActionsSheet extends StatelessWidget {
  const _SponsorshipActionsSheet({
    required this.studentName,
    required this.link,
    required this.onAssignOrChange,
    required this.onRemove,
  });

  final String studentName;
  final StudentSponsorshipLink? link;
  final VoidCallback onAssignOrChange;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasSponsor = link != null;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.text.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            studentName,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (hasSponsor) ...[
            const SizedBox(height: 4),
            Text(
              '${l10n.currentSponsor}: ${link!.sponsorName}',
              style: TextStyle(
                color: AppColors.text.withValues(alpha: 0.55),
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 16),
          _ActionTile(
            icon: hasSponsor ? Icons.swap_horiz : Icons.link,
            label: hasSponsor ? l10n.changeSponsor : l10n.assignSponsor,
            onTap: onAssignOrChange,
          ),
          if (onRemove != null)
            _ActionTile(
              icon: Icons.link_off,
              label: l10n.removeSponsorLink,
              isDestructive: true,
              onTap: onRemove!,
            ),
        ],
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
    final color = isDestructive ? const Color(0xFFC62828) : AppColors.primary;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? color : AppColors.text,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
