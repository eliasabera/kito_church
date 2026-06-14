import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/auth/widgets/auth_header.dart';
import 'package:kitoapp/features/admin/services/users_management_store.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/locale_notifier_provider.dart';
import 'package:kitoapp/shared/widgets/password_text_field.dart';
import 'package:kitoapp/shared/widgets/prefixed_text_field.dart';
import 'package:kitoapp/shared/widgets/users_management_store_provider.dart';

class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  State<StudentRegistrationScreen> createState() =>
      _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  bool _isLoading = false;
  final _compassionIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _universityController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _compassionIdController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _universityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: AppColors.background),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);

    if (_compassionIdController.text.trim().isEmpty) {
      _showMessage(l10n.pleaseSelectCompassionId);
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      _showMessage(l10n.pleaseEnterFullName);
      return;
    }

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage(l10n.pleaseEnterEmail);
      return;
    }
    if (!_isValidEmail(email)) {
      _showMessage(l10n.invalidEmail);
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showMessage(l10n.pleaseEnterPassword);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage(l10n.passwordsDoNotMatch);
      return;
    }

    final store = UsersManagementStoreProvider.of(context);
    final compassionId = fullCompassionId(_compassionIdController.text);
    final phone = fullPhoneNumber(_phoneController.text);

    setState(() => _isLoading = true);
    try {
      final result = await store.registerStudent(
        fullName: _nameController.text.trim(),
        email: email,
        password: _passwordController.text,
        compassionId: compassionId,
        university: _universityController.text.trim().isEmpty
            ? null
            : _universityController.text.trim(),
        phone: phone,
      );

      if (!mounted) return;

      if (result == LoginResult.emailAlreadyRegistered) {
        _showMessage(l10n.emailAlreadyRegistered);
        return;
      }

      if (result == LoginResult.registrationFailed) {
        _showMessage(l10n.registrationFailed);
        return;
      }

      if (result != LoginResult.success) {
        _showMessage(l10n.registrationFailed);
        return;
      }

      _showMessage(l10n.registrationSubmitted);
      context.pop();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
              title: l10n.authAppTitle,
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
                      l10n.registrationPendingHint,
                      style: TextStyle(
                        color: AppColors.text.withValues(alpha: 0.7),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 28),
                    PrefixedTextField(
                      controller: _compassionIdController,
                      labelText: l10n.compassionProjectId,
                      prefixText: compassionIdPrefix,
                      icon: Icons.badge_outlined,
                      hintText: l10n.compassionIdSuffixHint,
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9-]')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
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
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      style: const TextStyle(color: AppColors.text),
                      decoration: InputDecoration(
                        labelText: l10n.email,
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    PasswordTextField(
                      controller: _passwordController,
                      labelText: l10n.password,
                    ),
                    const SizedBox(height: 16),
                    PasswordTextField(
                      controller: _confirmPasswordController,
                      labelText: l10n.confirmPassword,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _universityController,
                      style: const TextStyle(color: AppColors.text),
                      decoration: InputDecoration(
                        labelText: l10n.university,
                        prefixIcon: const Icon(
                          Icons.account_balance_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    PrefixedTextField(
                      controller: _phoneController,
                      labelText: '${l10n.phoneNumber} (${l10n.optional})',
                      prefixText: ethiopianPhonePrefix,
                      icon: Icons.phone_outlined,
                      hintText: l10n.phoneSuffixHint,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.pop(),
                            child: Text(l10n.cancel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: _isLoading ? null : _submit,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.background,
                                    ),
                                  )
                                : Text(l10n.submit),
                          ),
                        ),
                      ],
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
}
