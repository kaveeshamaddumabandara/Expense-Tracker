import 'package:flutter/material.dart';
import '../controller.dart';
import '../theme/app_theme.dart';
import '../widgets/shape_decorations.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({
    super.key,
    required this.controller,
  });

  final ExpenseController controller;

  @override
  Widget build(BuildContext context) {
    final summary = controller.getSummary();
    final userName = controller.userName;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Blue Header
          BubbleHeader(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Profile & Security',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                        if (controller.hasPassword && controller.isPasswordProtectionEnabled)
                          IconButton(
                            tooltip: 'Lock App',
                            onPressed: () => controller.lockApp(),
                            icon: const Icon(Icons.lock_rounded, color: Colors.white),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Large Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _editNameDialog(context),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '100% Offline & Private Account',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Transform.translate(
            offset: const Offset(0, -14),
            child: CurvedSheetContainer(
              topRadius: 32,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick stats overview
                  Row(
                    children: [
                      Expanded(
                        child: _ProfileStatCard(
                          title: 'Income',
                          value: 'LKR ${summary.totalIncome.toStringAsFixed(0)}',
                          icon: Icons.arrow_downward_rounded,
                          color: AppColors.mintGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ProfileStatCard(
                          title: 'Expenses',
                          value: 'LKR ${summary.totalExpenses.toStringAsFixed(0)}',
                          icon: Icons.arrow_upward_rounded,
                          color: AppColors.coralRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Security & Protection',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Password Protection Status Switch
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      child: SwitchListTile(
                        value: controller.isPasswordProtectionEnabled,
                        activeThumbColor: AppColors.primaryBlue,
                        secondary: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.09),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.shield_rounded, color: AppColors.primaryBlue, size: 22),
                        ),
                        title: const Text(
                          'Password Protection',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        subtitle: Text(
                          controller.isPasswordProtectionEnabled
                              ? 'App lock active on launch'
                              : 'No passcode required to open',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        onChanged: (bool value) {
                          if (value) {
                            if (!controller.hasPassword) {
                              _setPasswordDialog(context);
                            } else {
                              controller.togglePasswordProtection(true);
                            }
                          } else {
                            _disablePasswordDialog(context);
                          }
                        },
                      ),
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.lock_outline_rounded,
                    title: controller.hasPassword ? 'Change Password' : 'Set App Password',
                    subtitle: controller.hasPassword
                        ? 'Update your offline passcode'
                        : 'Add passcode protection now',
                    onTap: () {
                      if (controller.hasPassword) {
                        _changePasswordDialog(context);
                      } else {
                        _setPasswordDialog(context);
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Preferences & Data',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Display Name',
                    subtitle: 'Current: $userName',
                    onTap: () => _editNameDialog(context),
                  ),
                  _SettingsTile(
                    icon: Icons.file_download_outlined,
                    title: 'Export Statements',
                    subtitle: 'Download CSV summaries offline',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Statements exported to downloads.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & FAQ',
                    subtitle: 'Offline usage guide and FAQs',
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),
                  // Lock App Now button
                  FilledButton.icon(
                    onPressed: () {
                      if (!controller.hasPassword) {
                        _setPasswordDialog(context);
                      } else {
                        controller.lockApp();
                      }
                    },
                    icon: const Icon(Icons.lock_rounded),
                    label: Text(controller.hasPassword ? 'Lock App Now' : 'Set Password to Lock'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // About Extrack App Brand Card
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.borderLight),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/extrack_logo.png',
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Extrack • Smart Expense Tracker',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Version 1.0.0 (Offline Edition) • LKR Currency',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editNameDialog(BuildContext context) {
    final textController = TextEditingController(text: controller.userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Display Name'),
        content: TextField(
          controller: textController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Display Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              controller.setUserName(textController.text);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _setPasswordDialog(BuildContext context) {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Set App Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (errorText != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(errorText!, style: const TextStyle(color: AppColors.coralRed, fontSize: 13)),
                ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final p = passwordController.text.trim();
                final c = confirmController.text.trim();
                if (p.length < 4) {
                  setState(() => errorText = 'Password must be at least 4 characters');
                  return;
                }
                if (p != c) {
                  setState(() => errorText = 'Passwords do not match');
                  return;
                }
                controller.setAppPassword(p);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password protection enabled!'), behavior: SnackBarBehavior.floating),
                );
              },
              child: const Text('Set Password'),
            ),
          ],
        ),
      ),
    );
  }

  void _changePasswordDialog(BuildContext context) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (errorText != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(errorText!, style: const TextStyle(color: AppColors.coralRed, fontSize: 13)),
                ),
              TextField(
                controller: currentController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Current Password'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final success = await controller.changePassword(
                  currentController.text.trim(),
                  newController.text.trim(),
                );
                if (!success) {
                  setState(() => errorText = controller.errorMessage ?? 'Failed to update password');
                } else {
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password updated successfully!'), behavior: SnackBarBehavior.floating),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _disablePasswordDialog(BuildContext context) {
    final currentController = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Disable Password Protection?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your current password to turn off password protection:'),
              const SizedBox(height: 12),
              if (errorText != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(errorText!, style: const TextStyle(color: AppColors.coralRed, fontSize: 13)),
                ),
              TextField(
                controller: currentController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Current Password'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final success = await controller.togglePasswordProtection(
                  false,
                  currentPassword: currentController.text.trim(),
                );
                if (!success) {
                  setState(() => errorText = controller.errorMessage ?? 'Incorrect password');
                } else {
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password protection disabled'), behavior: SnackBarBehavior.floating),
                    );
                  }
                }
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.coralRed),
              child: const Text('Disable'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  const _ProfileStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 22),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textMuted,
            size: 22,
          ),
        ),
      ),
    );
  }
}
