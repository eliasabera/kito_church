import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';

enum AppToastType { success, error, info }

/// Consistent floating toast-style messages across the app.
class AppToast {
  AppToast._();

  static const _duration = Duration(seconds: 4);

  static void show(
    ScaffoldMessengerState messenger, {
    required String message,
    AppToastType type = AppToastType.info,
  }) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              color: AppColors.background,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: _backgroundFor(type),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          duration: _duration,
        ),
      );
  }

  static void showSuccess(BuildContext context, String message) {
    show(
      ScaffoldMessenger.of(context),
      message: message,
      type: AppToastType.success,
    );
  }

  static void showError(BuildContext context, String message) {
    show(
      ScaffoldMessenger.of(context),
      message: message,
      type: AppToastType.error,
    );
  }

  static void showInfo(BuildContext context, String message) {
    show(
      ScaffoldMessenger.of(context),
      message: message,
      type: AppToastType.info,
    );
  }

  static Color _backgroundFor(AppToastType type) {
    return switch (type) {
      AppToastType.success => AppColors.primary,
      AppToastType.error => AppColors.error,
      AppToastType.info => AppColors.primary,
    };
  }
}
