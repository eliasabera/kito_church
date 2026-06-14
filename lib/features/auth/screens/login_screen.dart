import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kitoapp/core/router/app_router.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/admin/services/users_management_store.dart';
import 'package:kitoapp/features/auth/services/auth_session.dart';
import 'package:kitoapp/features/auth/widgets/auth_header.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/locale_notifier_provider.dart';
import 'package:kitoapp/shared/widgets/notifications_store_provider.dart';
import 'package:kitoapp/shared/widgets/password_text_field.dart';
import 'package:kitoapp/shared/widgets/profile_store_provider.dart';
import 'package:kitoapp/shared/widgets/users_management_store_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _login() async {
    final l10n = AppLocalizations.of(context);
    final store = UsersManagementStoreProvider.of(context);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage(l10n.pleaseEnterEmail);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await store.login(email, password);
      if (!mounted) return;

      switch (response.result) {
        case LoginResult.success:
          final user = response.user;
          if (user == null) {
            _showMessage(l10n.invalidCredentials);
            return;
          }
          AuthSession.setSession(id: user.id, userRole: user.role);
          await NotificationsStoreProvider.of(context).load();
          if (!mounted) return;
          await ProfileStoreProvider.of(context).load();
          if (!mounted) return;
          context.go(dashboardRouteForRole(user.role));
        case LoginResult.invalidCredentials:
          _showMessage(l10n.invalidCredentials);
        case LoginResult.accountPending:
          _showMessage(l10n.accountPendingApproval);
        case LoginResult.accountRejected:
          _showMessage(l10n.accountRejected);
        case LoginResult.accountSuspended:
          _showMessage(l10n.accountSuspended);
        case LoginResult.emailAlreadyRegistered:
          _showMessage(l10n.emailAlreadyRegistered);
        case LoginResult.registrationFailed:
          _showMessage(l10n.registrationFailed);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeNotifier = LocaleNotifierProvider.of(context);
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AuthHeader(
              title: l10n.authAppTitle,
              subtitle: l10n.appTagline,
              onToggleLanguage: localeNotifier.toggleLocale,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: size.height * 0.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.login,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.welcome,
                        style: TextStyle(
                          color: AppColors.text.withValues(alpha: 0.7),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 28),
                      TextField(
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
                      const SizedBox(height: 28),
                      FilledButton(
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.background,
                                ),
                              )
                            : Text(l10n.login),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: TextButton(
                          onPressed: () => context.push(AppRoutes.register),
                          child: Text(
                            l10n.studentRegistration,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
