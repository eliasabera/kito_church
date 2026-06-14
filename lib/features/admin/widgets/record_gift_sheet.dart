import 'package:flutter/material.dart';
import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/admin/models/student_sponsorship_link.dart';
import 'package:kitoapp/l10n/app_localizations.dart';

Future<void> showRecordGiftSheet(
  BuildContext context, {
  required List<StudentSponsorshipLink> sponsoredStudents,
  required void Function(
    String studentId,
    String title,
    String description,
    GiftType type,
  ) onSave,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _RecordGiftSheet(
      sponsoredStudents: sponsoredStudents,
      onSave: (studentId, title, description, type) {
        Navigator.of(sheetContext, rootNavigator: true).pop();
        onSave(studentId, title, description, type);
      },
    ),
  );
}

class _RecordGiftSheet extends StatefulWidget {
  const _RecordGiftSheet({
    required this.sponsoredStudents,
    required this.onSave,
  });

  final List<StudentSponsorshipLink> sponsoredStudents;
  final void Function(
    String studentId,
    String title,
    String description,
    GiftType type,
  ) onSave;

  @override
  State<_RecordGiftSheet> createState() => _RecordGiftSheetState();
}

class _RecordGiftSheetState extends State<_RecordGiftSheet> {
  String? _studentId;
  GiftType _type = GiftType.physical;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
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
                l10n.recordGift,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.recordGiftHint,
                style: TextStyle(
                  color: AppColors.text.withValues(alpha: 0.55),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _studentId,
                decoration: InputDecoration(
                  labelText: l10n.selectStudent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: widget.sponsoredStudents
                    .map(
                      (link) => DropdownMenuItem(
                        value: link.studentId,
                        child: Text(
                          '${link.studentName} (${link.sponsorName})',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _studentId = value),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.giftTitle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.giftDescription,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.giftType,
                style: TextStyle(
                  color: AppColors.text.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<GiftType>(
                segments: [
                  ButtonSegment(
                    value: GiftType.physical,
                    label: Text(l10n.physicalGift),
                    icon: const Icon(Icons.inventory_2_outlined, size: 16),
                  ),
                  ButtonSegment(
                    value: GiftType.digital,
                    label: Text(l10n.digitalGift),
                    icon: const Icon(Icons.mail_outline, size: 16),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (value) =>
                    setState(() => _type = value.first),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _studentId == null ||
                        _titleController.text.trim().isEmpty ||
                        _descriptionController.text.trim().isEmpty
                    ? null
                    : () {
                        widget.onSave(
                          _studentId!,
                          _titleController.text.trim(),
                          _descriptionController.text.trim(),
                          _type,
                        );
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
