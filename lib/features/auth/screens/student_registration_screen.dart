import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/auth/widgets/auth_header.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/models/compassion_id.dart';
import 'package:kitoapp/shared/services/compassion_id_service.dart';
import 'package:kitoapp/shared/widgets/locale_notifier_provider.dart';

class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  State<StudentRegistrationScreen> createState() =>
      _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  final _compassionIdService = CompassionIdService();
  final _dobController = TextEditingController();

  List<CompassionId> _compassionIds = [];
  CompassionId? _selectedCompassionId;
  DateTime? _dateOfBirth;
  bool _isLoadingIds = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadCompassionIds();
  }

  @override
  void dispose() {
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _loadCompassionIds() async {
    try {
      final ids = await _compassionIdService.fetchAvailableIds();
      if (!mounted) return;
      setState(() {
        _compassionIds = ids;
        _isLoadingIds = false;
        _loadError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingIds = false;
        _loadError = AppLocalizations.of(context).noCompassionIdsAvailable;
      });
    }
  }

  Future<void> _pickDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      initialDate: _dateOfBirth ?? DateTime(2010),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.background,
              onSurface: AppColors.text,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
        _dobController.text = _formatDate(picked);
      });
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);

    if (_selectedCompassionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.pleaseSelectCompassionId,
            style: const TextStyle(color: AppColors.background),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    await _compassionIdService.assignId(_selectedCompassionId!.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.pendingApproval,
          style: const TextStyle(color: AppColors.background),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeNotifier = LocaleNotifierProvider.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AuthHeader(
              title: l10n.appTitle,
              subtitle: l10n.appTagline,
              onToggleLanguage: localeNotifier.toggleLocale,
              onBack: () => context.pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.studentRegistration,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.pendingApproval,
                      style: TextStyle(
                        color: AppColors.text.withValues(alpha: 0.7),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildCompassionIdField(l10n),
                    const SizedBox(height: 16),
                    TextFormField(
                      style: const TextStyle(color: AppColors.text),
                      decoration: InputDecoration(
                        labelText: l10n.fullName,
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      readOnly: true,
                      onTap: _pickDateOfBirth,
                      controller: _dobController,
                      style: const TextStyle(color: AppColors.text),
                      decoration: InputDecoration(
                        labelText: l10n.dateOfBirth,
                        prefixIcon: const Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.primary,
                        ),
                        suffixIcon: const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      style: const TextStyle(color: AppColors.text),
                      decoration: InputDecoration(
                        labelText: l10n.grade,
                        prefixIcon: const Icon(
                          Icons.class_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: AppColors.text),
                      decoration: InputDecoration(
                        labelText: '${l10n.phoneNumber} (${l10n.optional})',
                        prefixIcon: const Icon(
                          Icons.phone_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: _isLoadingIds || _compassionIds.isEmpty
                          ? null
                          : _submit,
                      child: Text(l10n.submit),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => context.pop(),
                      child: Text(l10n.cancel),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompassionIdField(AppLocalizations l10n) {
    if (_isLoadingIds) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.compassionProjectId,
          prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const SizedBox(
          height: 24,
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      );
    }

    if (_loadError != null || _compassionIds.isEmpty) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.compassionProjectId,
          prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.primary),
          errorText: l10n.noCompassionIdsAvailable,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const SizedBox(height: 24),
      );
    }

    return DropdownButtonFormField<CompassionId>(
      initialValue: _selectedCompassionId,
      style: const TextStyle(color: AppColors.text),
      decoration: InputDecoration(
        labelText: l10n.selectCompassionId,
        prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.primary),
      ),
      hint: Text(
        l10n.selectCompassionId,
        style: TextStyle(color: AppColors.text.withValues(alpha: 0.6)),
      ),
      items: _compassionIds
          .map(
            (id) => DropdownMenuItem(
              value: id,
              child: Text(
                id.projectId,
                style: const TextStyle(color: AppColors.text),
              ),
            ),
          )
          .toList(),
      onChanged: (value) => setState(() => _selectedCompassionId = value),
    );
  }
}
