import 'package:flutter/material.dart';
import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/admin/models/managed_user.dart';
import 'package:kitoapp/features/auth/models/login_result.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/users_management_store_provider.dart';

void showAddEditUserSheet(
  BuildContext context, {
  ManagedUser? existing,
}) {
  final messenger = ScaffoldMessenger.of(context);

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _AddEditUserSheet(
      existing: existing,
      onClose: () {
        final navigator = Navigator.of(sheetContext, rootNavigator: true);
        if (navigator.canPop()) navigator.pop();
      },
      onSuccess: (message) {
        final navigator = Navigator.of(sheetContext, rootNavigator: true);
        if (navigator.canPop()) navigator.pop();
        messenger.showSnackBar(SnackBar(content: Text(message)));
      },
    ),
  );
}

class _AddEditUserSheet extends StatefulWidget {
  const _AddEditUserSheet({
    required this.onClose,
    required this.onSuccess,
    this.existing,
  });

  final VoidCallback onClose;
  final void Function(String message) onSuccess;
  final ManagedUser? existing;

  @override
  State<_AddEditUserSheet> createState() => _AddEditUserSheetState();
}

class _AddEditUserSheetState extends State<_AddEditUserSheet> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _compassionController = TextEditingController();
  final _universityController = TextEditingController();
  final _departmentController = TextEditingController();
  final _passwordController = TextEditingController();

  UserRole _role = UserRole.student;
  ManagedUserStatus _status = ManagedUserStatus.pending;
  bool _submitting = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final user = widget.existing;
    if (user != null) {
      _nameController.text = user.fullName;
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
      _compassionController.text = user.compassionId ?? '';
      _universityController.text = user.university ?? '';
      _departmentController.text = user.department ?? '';
      _role = user.role;
      _status = user.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _compassionController.dispose();
    _universityController.dispose();
    _departmentController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.userFormRequired)),
      );
      return;
    }

    setState(() => _submitting = true);
    final store = UsersManagementStoreProvider.of(context);

    if (_isEditing) {
      final result = await store.updateUser(
        widget.existing!.copyWith(
          fullName: name,
          email: email,
          role: _role,
          status: _status,
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          compassionId: _role == UserRole.student &&
                  _compassionController.text.trim().isNotEmpty
              ? _compassionController.text.trim()
              : null,
          university: _role == UserRole.student &&
                  _universityController.text.trim().isNotEmpty
              ? _universityController.text.trim()
              : null,
          department: _role != UserRole.student &&
                  _departmentController.text.trim().isNotEmpty
              ? _departmentController.text.trim()
              : null,
        ),
      );
      if (!mounted) return;
      setState(() => _submitting = false);
      if (result == LoginResult.success) {
        widget.onSuccess(l10n.userUpdated);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.reportGenerateFailed)),
        );
      }
    } else {
      final password = _passwordController.text.trim();
      if (password.length < 6) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.userFormRequired)),
        );
        return;
      }

      final result = await store.addUser(
        fullName: name,
        email: email,
        password: password,
        role: _role,
        status: _status,
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        compassionId: _role == UserRole.student &&
                _compassionController.text.trim().isNotEmpty
            ? _compassionController.text.trim()
            : null,
        university: _role == UserRole.student &&
                _universityController.text.trim().isNotEmpty
            ? _universityController.text.trim()
            : null,
        department: _role != UserRole.student &&
                _departmentController.text.trim().isNotEmpty
            ? _departmentController.text.trim()
            : null,
      );
      if (!mounted) return;
      setState(() => _submitting = false);
      if (result == LoginResult.success) {
        widget.onSuccess(l10n.userAdded);
      } else if (result == LoginResult.emailAlreadyRegistered) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.emailAlreadyRegistered)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.reportGenerateFailed)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
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
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEditing ? l10n.editUser : l10n.addUser,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _field(
                      controller: _nameController,
                      label: l10n.fullName,
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 14),
                    _field(
                      controller: _emailController,
                      label: l10n.email,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    if (!_isEditing) ...[
                      const SizedBox(height: 14),
                      _field(
                        controller: _passwordController,
                        label: l10n.password,
                        icon: Icons.lock_outline,
                        obscureText: true,
                      ),
                    ],
                    const SizedBox(height: 14),
                    _field(
                      controller: _phoneController,
                      label: '${l10n.phoneNumber} (${l10n.optional})',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      l10n.selectRole,
                      style: TextStyle(
                        color: AppColors.text.withValues(alpha: 0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _RoleChip(
                          label: l10n.student,
                          selected: _role == UserRole.student,
                          onTap: () => setState(() => _role = UserRole.student),
                        ),
                        const SizedBox(width: 8),
                        _RoleChip(
                          label: l10n.teacher,
                          selected: _role == UserRole.teacher,
                          onTap: () => setState(() => _role = UserRole.teacher),
                        ),
                        const SizedBox(width: 8),
                        _RoleChip(
                          label: l10n.admin,
                          selected: _role == UserRole.admin,
                          onTap: () => setState(() => _role = UserRole.admin),
                        ),
                      ],
                    ),
                    if (_role == UserRole.student) ...[
                      const SizedBox(height: 14),
                      _field(
                        controller: _compassionController,
                        label: l10n.compassionProjectId,
                        icon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 14),
                      _field(
                        controller: _universityController,
                        label: l10n.university,
                        icon: Icons.account_balance_outlined,
                      ),
                    ] else ...[
                      const SizedBox(height: 14),
                      _field(
                        controller: _departmentController,
                        label: l10n.department,
                        icon: Icons.business_outlined,
                      ),
                    ],
                    const SizedBox(height: 18),
                    Text(
                      l10n.status,
                      style: TextStyle(
                        color: AppColors.text.withValues(alpha: 0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final status in ManagedUserStatus.values)
                          _StatusChip(
                            label: managedUserStatusLabel(status, l10n),
                            selected: _status == status,
                            onTap: () => setState(() => _status = status),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.background,
                              ),
                            )
                          : Text(_isEditing ? l10n.save : l10n.addUser),
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

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: AppColors.text),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? AppColors.primary : AppColors.background,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primary,
                width: selected ? 0 : 1,
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? AppColors.background : AppColors.text,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.background : AppColors.text,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

String managedUserStatusLabel(
  ManagedUserStatus status,
  AppLocalizations l10n,
) {
  return switch (status) {
    ManagedUserStatus.active => l10n.active,
    ManagedUserStatus.suspended => l10n.suspended,
    ManagedUserStatus.pending => l10n.pending,
    ManagedUserStatus.rejected => l10n.rejected,
  };
}
