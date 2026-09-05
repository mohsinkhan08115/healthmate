import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:healthmate/controller/bottom_navi_controller/dashboard_controller.dart';
import 'package:healthmate/core/theme/app_colors.dart';
import 'package:healthmate/core/theme/app_theme.dart';
import 'package:healthmate/screens/auth_screens/login_screen.dart';
import 'package:healthmate/services/step_service.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final DashboardController controller = Get.find();

  // ---- Setting properties (swap these for your prefs/controller later) ----
  bool _stepNotification = true;
  bool _goalReachedAlert = true;
  bool _waterReminder = false;
  bool _useMetricUnits = true;
  bool _keepScreenAwake = false;
  int _dailyStepGoal = 10000;
  int _reminderHour = 20;

  Future<void> signOut() async {
    controller.resetDashboard();
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthScreen()),
    );
  }

  Future<void> _editStepGoal() async {
    final textController = TextEditingController(text: '$_dailyStepGoal');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Daily step goal',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: textController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            suffixText: 'steps',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              int.tryParse(textController.text.trim()),
            ),
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (result != null && result > 0) {
      setState(() => _dailyStepGoal = result);
    }
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _reminderHour, minute: 0),
    );
    if (picked != null) {
      setState(() => _reminderHour = picked.hour);
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete account',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This removes your account and all saved activity. You cannot undo this.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep account'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: AppColors.calories,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseAuth.instance.currentUser?.delete();
      if (!mounted) return;
      controller.resetDashboard();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final message = e.code == 'requires-recent-login'
          ? 'Sign in again, then delete your account.'
          : 'Could not delete the account. Try again.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  // ---------------------------- shared pieces ----------------------------

  Widget _card({
    required String title,
    String? description,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.06)
        : AppColors.lightBorder;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: AppTheme.cardShadow(context),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(color: textSecondary, fontSize: 13, height: 1.4),
            ),
          ],
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _rowDivider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.06)
        : AppColors.lightBorder;
    return Divider(height: 1, thickness: 1, color: borderColor);
  }

  Widget _switchRow({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _tapRow({
    required IconData icon,
    required String title,
    String? value,
    String? subtitle,
    VoidCallback? onTap,
    Color? tint,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final color = tint ?? AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: tint ?? textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (value != null)
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textSecondary,
                ),
              ),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.06)
        : AppColors.lightBorder;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final email = FirebaseAuth.instance.currentUser?.email ?? 'Not signed in';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Settings",
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ------------------- your original card, unchanged -------------------
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: AppTheme.cardShadow(context),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Background Step Tracking",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "If step tracking or the notification stops after restarting your phone, tap below and allow HealthMate to auto-start in the background.",
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => StepService.openAutoStartSettings(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Fix background step tracking',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ----------------------------- Activity -----------------------------
            _card(
              title: "Activity",
              children: [
                _tapRow(
                  icon: Icons.flag_rounded,
                  title: 'Daily step goal',
                  value: '$_dailyStepGoal',
                  onTap: _editStepGoal,
                ),
                _rowDivider(),
                _tapRow(
                  icon: Icons.straighten_rounded,
                  title: 'Units',
                  value: _useMetricUnits ? 'Kilometres' : 'Miles',
                  onTap: () =>
                      setState(() => _useMetricUnits = !_useMetricUnits),
                ),
                _rowDivider(),
                _switchRow(
                  icon: Icons.screen_lock_portrait_rounded,
                  title: 'Keep screen awake while tracking',
                  value: _keepScreenAwake,
                  onChanged: (v) => setState(() => _keepScreenAwake = v),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // --------------------------- Notifications ---------------------------
            _card(
              title: "Notifications",
              children: [
                _switchRow(
                  icon: Icons.directions_walk_rounded,
                  title: 'Live step counter',
                  subtitle: 'Shows todays steps in the notification bar.',
                  value: _stepNotification,
                  onChanged: (v) => setState(() => _stepNotification = v),
                ),
                _rowDivider(),
                _switchRow(
                  icon: Icons.emoji_events_rounded,
                  title: 'Goal reached alert',
                  value: _goalReachedAlert,
                  onChanged: (v) => setState(() => _goalReachedAlert = v),
                ),
                _rowDivider(),
                _switchRow(
                  icon: Icons.water_drop_rounded,
                  title: 'Water reminder',
                  value: _waterReminder,
                  onChanged: (v) => setState(() => _waterReminder = v),
                ),
                if (_waterReminder) ...[
                  _rowDivider(),
                  _tapRow(
                    icon: Icons.schedule_rounded,
                    title: 'Reminder time',
                    value: TimeOfDay(
                      hour: _reminderHour,
                      minute: 0,
                    ).format(context),
                    onTap: _pickReminderTime,
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // ------------------------------ Account ------------------------------
            _card(
              title: "Account",
              children: [
                _tapRow(
                  icon: Icons.person_rounded,
                  title: 'Signed in as',
                  subtitle: email,
                ),
                _rowDivider(),
                _tapRow(
                  icon: Icons.lock_reset_rounded,
                  title: 'Reset password',
                  onTap: () async {
                    final address = FirebaseAuth.instance.currentUser?.email;
                    if (address == null) return;
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: address,
                    );
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Reset link sent to $address')),
                    );
                  },
                ),
                _rowDivider(),
                _tapRow(
                  icon: Icons.delete_outline_rounded,
                  title: 'Delete account',
                  tint: AppColors.calories,
                  onTap: _confirmDeleteAccount,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ------------------------------- About -------------------------------
            _card(
              title: "About",
              children: [
                _tapRow(
                  icon: Icons.shield_outlined,
                  title: 'Privacy policy',
                  onTap: () {},
                ),
                _rowDivider(),
                _tapRow(
                  icon: Icons.description_outlined,
                  title: 'Terms of use',
                  onTap: () {},
                ),
                _rowDivider(),
                _tapRow(
                  icon: Icons.info_outline_rounded,
                  title: 'App version',
                  value: '1.0.0',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ----------------- your original sign out button, unchanged -----------------
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: signOut,
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text(
                  "Sign Out",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.calories,
                  side: const BorderSide(color: AppColors.calories, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
