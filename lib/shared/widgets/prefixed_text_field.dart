import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kitoapp/core/theme/app_colors.dart';

class PrefixedTextField extends StatelessWidget {
  const PrefixedTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixText,
    required this.icon,
    this.keyboardType,
    this.hintText,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String labelText;
  final String prefixText;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? hintText;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: AppColors.text),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColors.primary),
        prefix: Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Text(
            prefixText,
            style: TextStyle(
              color: AppColors.text.withValues(alpha: 0.85),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

const compassionIdPrefix = 'ET-221-';
const ethiopianPhonePrefix = '+2519';

String fullCompassionId(String suffix) => '$compassionIdPrefix${suffix.trim()}';

String? fullPhoneNumber(String suffix) {
  final trimmed = suffix.trim();
  if (trimmed.isEmpty) return null;
  return '$ethiopianPhonePrefix$trimmed';
}
