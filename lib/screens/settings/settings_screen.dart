// ============================================================
// ISF HR Portal — Settings Screen
// File: lib/screens/settings/settings_screen.dart
//
// Features:
//   - Employee profile header (avatar, name, designation, ID)
//   - Account settings (language, region, time zone)
//   - Security settings (change password, biometric, active sessions)
//   - Appearance (theme, font size, colour scheme)
//   - Notification preferences (quick toggles)
//   - Privacy & data (download data, delete cache, consent)
//   - About (version, changelog, terms, privacy policy)
//   - Logout with confirmation dialog
//   - Danger zone (deactivate account)
//
// Dependencies: none beyond flutter/material
// ============================================================

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// INLINE THEME
// ─────────────────────────────────────────────
class _C {
  static const primary = Color(0xFF2563EB);
  static const primaryLight = Color(0xFFEFF6FF);
  static const primaryDark = Color(0xFF1D4ED8);
  static const accent = Color(0xFF6366F1);
  static const accentLight = Color(0xFFEEF2FF);
  static const success = Color(0xFF22C55E);
  static const successLight = Color(0xFFDCFCE7);
  static const successDark = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFEF9C3);
  static const warningDark = Color(0xFFCA8A04);
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFEF2F2);
  static const errorDark = Color(0xFFDC2626);
  static const teal = Color(0xFF0D9488);
  static const tealLight = Color(0xFFF0FDFA);
  static const orange = Color(0xFFEA580C);
  static const orangeLight = Color(0xFFFFF7ED);
  static const purple = Color(0xFF7C3AED);
  static const purpleLight = Color(0xFFF5F3FF);
  static const bg = Color(0xFFF8FAFC);
  static const card = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF1F5F9);
  static const textPrimary = Color(0xFF0F172A);
  static const textSec = Color(0xFF64748B);
  static const textTert = Color(0xFF94A3B8);
  static const textDisabled = Color(0xFFCBD5E1);
  static const border = Color(0xFFE2E8F0);
}

// ─────────────────────────────────────────────
// SETTINGS STATE
// ─────────────────────────────────────────────
class _SettingsState {
  // Appearance
  bool darkMode = false;
  bool useSystemTheme = true;
  double fontSize = 1.0; // 0.85 small / 1.0 normal / 1.15 large

  // Notifications
  bool pushNotifs = true;
  bool emailNotifs = true;
  bool smsNotifs = false;
  bool soundEnabled = true;
  bool vibrationEnabled = true;

  // Security
  bool biometricEnabled = true;
  bool autoLock = true;
  int autoLockMins = 5;

  // Privacy
  bool analyticsEnabled = true;
  bool crashReporting = true;

  // Language & Region
  String language = 'English';
  String dateFormat = 'DD MMM YYYY';
  String timeZone = 'IST (UTC+5:30)';
}

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _prefs = _SettingsState();

  void _snack(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: bg,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  // ── Change password sheet ─────────────────────
  void _showChangePassword() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ChangePasswordSheet(
        onSaved: () {
          Navigator.pop(context);
          _snack('Password updated successfully ✅', _C.successDark);
        },
      ),
    );
  }

  // ── Active sessions sheet ─────────────────────
  void _showActiveSessions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ActiveSessionsSheet(
        onRevoke: (_) => _snack('Session revoked', _C.error),
      ),
    );
  }

  // ── Logout ────────────────────────────────────
  void _showLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out?',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        content: const Text(
            'You will need to log in again to access ISmart HR Portal.',
            style: TextStyle(fontSize: 14, color: _C.textSec)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: _C.textSec))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _snack('Logged out successfully', _C.textSec);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  // ── Deactivate account ────────────────────────
  void _showDeactivate() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Deactivate Account?',
            style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w600, color: _C.error)),
        content: const Text(
            'This will deactivate your ISmart portal access. '
            'You will need to contact HR to re-enable access. '
            'This action cannot be undone.',
            style: TextStyle(fontSize: 14, color: _C.textSec)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: _C.textSec))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _snack('Request sent to HR — you will be contacted.', _C.orange);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Request Deactivation'),
          ),
        ],
      ),
    );
  }

  // ── Auto lock picker ──────────────────────────
  void _showAutoLockPicker() {
    final opts = [1, 2, 5, 10, 15, 30];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 36),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: _C.border,
                          borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Text('Auto-Lock After',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary)),
              const SizedBox(height: 12),
              ...opts.map((m) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('$m minute${m != 1 ? "s" : ""}',
                        style: const TextStyle(
                            fontSize: 14, color: _C.textPrimary)),
                    trailing: _prefs.autoLockMins == m
                        ? const Icon(Icons.check_rounded, color: _C.primary)
                        : null,
                    onTap: () {
                      setState(() => _prefs.autoLockMins = m);
                      Navigator.pop(context);
                      _snack('Auto-lock set to $m min', _C.textSec);
                    },
                  )),
            ]),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
        children: [
          _buildProfileCard(),
          const SizedBox(height: 20),

          _buildSectionHeader('Account'),
          _buildAccountCard(),
          const SizedBox(height: 16),

          _buildSectionHeader('Security'),
          _buildSecurityCard(),
          const SizedBox(height: 16),

          _buildSectionHeader('Appearance'),
          _buildAppearanceCard(),
          const SizedBox(height: 16),

          _buildSectionHeader('Notifications'),
          _buildNotificationsCard(),
          const SizedBox(height: 16),

          _buildSectionHeader('Privacy & Data'),
          _buildPrivacyCard(),
          const SizedBox(height: 16),

          _buildSectionHeader('About'),
          _buildAboutCard(),
          const SizedBox(height: 20),

          // Logout button
          _buildLogoutButton(),
          const SizedBox(height: 12),

          // Danger zone
          _buildDangerZone(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // APP BAR
  // ─────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() => AppBar(
        backgroundColor: _C.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: _C.textPrimary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Settings',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _C.border),
        ),
      );

  // ─────────────────────────────────────────────
  // SECTION HEADER
  // ─────────────────────────────────────────────
  Widget _buildSectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _C.textSec,
                letterSpacing: 0.5)),
      );

  // ─────────────────────────────────────────────
  // PROFILE CARD
  // ─────────────────────────────────────────────
  Widget _buildProfileCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: _C.primary.withValues(alpha: .3),
              blurRadius: 14,
              offset: const Offset(0, 5))
        ],
      ),
      child: Stack(children: [
        Positioned(
            right: -20,
            top: -20,
            child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: .07)))),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            // Avatar
            Stack(children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .2),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: Colors.white.withValues(alpha: .4), width: 2),
                ),
                child: const Center(
                  child: Text('AP',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _C.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ]),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text('Amit Patil',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const Text('Full Stack Developer',
                      style: TextStyle(fontSize: 12, color: Colors.white70)),
                  const SizedBox(height: 5),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('ISF-2024-0042',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'monospace')),
                  ),
                ])),
            GestureDetector(
              onTap: () => _snack('Navigate to My Profile', _C.textSec),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_outlined,
                    size: 18, color: Colors.white),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────
  // ACCOUNT CARD
  // ─────────────────────────────────────────────
  Widget _buildAccountCard() {
    return _SettingsCard(children: [
      _SettingsTile(
        icon: Icons.language_outlined,
        color: _C.primary,
        bg: _C.primaryLight,
        title: 'Language',
        subtitle: _prefs.language,
        onTap: () => _snack('Language: ${_prefs.language}', _C.textSec),
        trailing: _chevron(),
      ),
      _divider(),
      _SettingsTile(
        icon: Icons.calendar_today_outlined,
        color: _C.teal,
        bg: _C.tealLight,
        title: 'Date Format',
        subtitle: _prefs.dateFormat,
        onTap: () => _snack('Date format unchanged', _C.textSec),
        trailing: _chevron(),
      ),
      _divider(),
      _SettingsTile(
        icon: Icons.schedule_outlined,
        color: _C.purple,
        bg: _C.purpleLight,
        title: 'Time Zone',
        subtitle: _prefs.timeZone,
        onTap: () => _snack('Time zone: ${_prefs.timeZone}', _C.textSec),
        trailing: _chevron(),
      ),
      _divider(),
      const _SettingsTile(
        icon: Icons.work_outline_rounded,
        color: _C.orange,
        bg: _C.orangeLight,
        title: 'Designation',
        subtitle: 'Full Stack Developer · IT Department',
        trailing: null,
      ),
    ]);
  }

  // ─────────────────────────────────────────────
  // SECURITY CARD
  // ─────────────────────────────────────────────
  Widget _buildSecurityCard() {
    return _SettingsCard(children: [
      _SettingsTile(
        icon: Icons.lock_outline_rounded,
        color: _C.error,
        bg: _C.errorLight,
        title: 'Change Password',
        subtitle: 'Last changed 3 months ago',
        onTap: _showChangePassword,
        trailing: _chevron(),
      ),
      _divider(),
      _SettingsTile(
        icon: Icons.fingerprint_rounded,
        color: _C.successDark,
        bg: _C.successLight,
        title: 'Biometric Login',
        subtitle: _prefs.biometricEnabled
            ? 'Face ID / Fingerprint enabled'
            : 'Tap to enable biometric login',
        trailing: _switch(_prefs.biometricEnabled,
            (v) => setState(() => _prefs.biometricEnabled = v), _C.successDark),
      ),
      _divider(),
      _SettingsTile(
        icon: Icons.timer_outlined,
        color: _C.warningDark,
        bg: _C.warningLight,
        title: 'Auto-Lock',
        subtitle: _prefs.autoLock
            ? 'Lock after ${_prefs.autoLockMins} minutes of inactivity'
            : 'Disabled',
        onTap: _prefs.autoLock ? _showAutoLockPicker : null,
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (_prefs.autoLock)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: _C.warningLight,
                  borderRadius: BorderRadius.circular(20)),
              child: Text('${_prefs.autoLockMins}m',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _C.warningDark)),
            ),
          const SizedBox(width: 6),
          _switch(_prefs.autoLock, (v) => setState(() => _prefs.autoLock = v),
              _C.warningDark),
        ]),
      ),
      _divider(),
      _SettingsTile(
        icon: Icons.devices_outlined,
        color: _C.primary,
        bg: _C.primaryLight,
        title: 'Active Sessions',
        subtitle: '2 active sessions — view all devices',
        onTap: _showActiveSessions,
        trailing: _chevron(),
      ),
      _divider(),
      _SettingsTile(
        icon: Icons.security_outlined,
        color: _C.accent,
        bg: _C.accentLight,
        title: 'Two-Factor Authentication',
        subtitle: 'Not enabled — Tap to set up',
        onTap: () => _snack('2FA setup — coming soon', _C.textSec),
        trailing: _chevron(),
      ),
    ]);
  }

  // ─────────────────────────────────────────────
  // APPEARANCE CARD
  // ─────────────────────────────────────────────
  Widget _buildAppearanceCard() {
    return _SettingsCard(children: [
      _SettingsTile(
        icon: Icons.brightness_auto_rounded,
        color: _C.accent,
        bg: _C.accentLight,
        title: 'Use System Theme',
        subtitle: 'Automatically switch light/dark based on device',
        trailing: _switch(_prefs.useSystemTheme,
            (v) => setState(() => _prefs.useSystemTheme = v), _C.accent),
      ),
      _divider(),
      _SettingsTile(
        icon: Icons.dark_mode_outlined,
        color: _C.textPrimary,
        bg: _C.surface,
        title: 'Dark Mode',
        subtitle: _prefs.useSystemTheme
            ? 'Controlled by system theme'
            : _prefs.darkMode
                ? 'On'
                : 'Off',
        trailing: _switch(
          _prefs.darkMode,
          _prefs.useSystemTheme
              ? null
              : (v) => setState(() => _prefs.darkMode = v),
          _C.textPrimary,
        ),
      ),
      _divider(),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  color: _C.primaryLight,
                  borderRadius: BorderRadius.circular(9)),
              child: const Icon(Icons.text_fields_rounded,
                  size: 17, color: _C.primary),
            ),
            const SizedBox(width: 12),
            const Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Font Size',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _C.textPrimary)),
                  Text('Adjust text size across the app',
                      style: TextStyle(fontSize: 12, color: _C.textSec)),
                ])),
            Text(
              _prefs.fontSize < 0.95
                  ? 'Small'
                  : _prefs.fontSize > 1.05
                      ? 'Large'
                      : 'Normal',
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: _C.textSec),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            const Text('A', style: TextStyle(fontSize: 12, color: _C.textSec)),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _C.primary,
                  inactiveTrackColor: _C.primaryLight,
                  thumbColor: _C.primaryDark,
                  overlayColor: _C.primary.withValues(alpha: .12),
                  trackHeight: 4,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 9),
                ),
                child: Slider(
                  value: _prefs.fontSize,
                  min: 0.85,
                  max: 1.15,
                  divisions: 6,
                  onChanged: (v) => setState(() => _prefs.fontSize = v),
                ),
              ),
            ),
            const Text('A',
                style: TextStyle(
                    fontSize: 18,
                    color: _C.textSec,
                    fontWeight: FontWeight.w700)),
          ]),
        ]),
      ),
    ]);
  }

  // ─────────────────────────────────────────────
  // NOTIFICATIONS CARD
  // ─────────────────────────────────────────────
  Widget _buildNotificationsCard() {
    return _SettingsCard(children: [
      _SettingsTile(
        icon: Icons.notifications_outlined,
        color: _C.primary,
        bg: _C.primaryLight,
        title: 'Push Notifications',
        subtitle: 'In-app and mobile alerts',
        trailing: _switch(_prefs.pushNotifs,
            (v) => setState(() => _prefs.pushNotifs = v), _C.primary),
      ),
      _divider(),
      _SettingsTile(
        icon: Icons.email_outlined,
        color: _C.teal,
        bg: _C.tealLight,
        title: 'Email Notifications',
        subtitle: 'Sent to amit.patil@isf.com',
        trailing: _switch(_prefs.emailNotifs,
            (v) => setState(() => _prefs.emailNotifs = v), _C.teal),
      ),
      _divider(),
      _SettingsTile(
        icon: Icons.sms_outlined,
        color: _C.orange,
        bg: _C.orangeLight,
        title: 'SMS Alerts',
        subtitle: 'Critical alerts via +91 98100 XXXXX',
        trailing: _switch(_prefs.smsNotifs,
            (v) => setState(() => _prefs.smsNotifs = v), _C.orange),
      ),
      _divider(),
      _SettingsTile(
        icon: Icons.volume_up_outlined,
        color: _C.accent,
        bg: _C.accentLight,
        title: 'Notification Sound',
        subtitle: 'Play sound for new alerts',
        trailing: _switch(_prefs.soundEnabled,
            (v) => setState(() => _prefs.soundEnabled = v), _C.accent),
      ),
      _divider(),
      _SettingsTile(
        icon: Icons.vibration_rounded,
        color: _C.purple,
        bg: _C.purpleLight,
        title: 'Vibration',
        subtitle: 'Vibrate for notifications',
        trailing: _switch(_prefs.vibrationEnabled,
            (v) => setState(() => _prefs.vibrationEnabled = v), _C.purple),
      ),
      _divider(),
      _SettingsTile(
        icon: Icons.tune_rounded,
        color: _C.primary,
        bg: _C.primaryLight,
        title: 'Notification Preferences',
        subtitle: 'Customise per category (HR, Payroll, IT…)',
        onTap: () => _snack('Navigate to Notification Preferences', _C.textSec),
        trailing: _chevron(),
      ),
    ]);
  }

  // ─────────────────────────────────────────────
  // PRIVACY CARD
  // ─────────────────────────────────────────────
  Widget _buildPrivacyCard() {
    return _SettingsCard(children: [
      _SettingsTile(
        icon: Icons.analytics_outlined,
        color: _C.successDark,
        bg: _C.successLight,
        title: 'Usage Analytics',
        subtitle: 'Help improve the app by sharing usage data',
        trailing: _switch(_prefs.analyticsEnabled,
            (v) => setState(() => _prefs.analyticsEnabled = v), _C.successDark),
      ),
      _divider(),
      _SettingsTile(
        icon: Icons.bug_report_outlined,
        color: _C.orange,
        bg: _C.orangeLight,
        title: 'Crash Reporting',
        subtitle: 'Automatically send crash reports to improve stability',
        trailing: _switch(_prefs.crashReporting,
            (v) => setState(() => _prefs.crashReporting = v), _C.orange),
      ),
      _divider(),
      _SettingsTile(
        icon: Icons.download_outlined,
        color: _C.primary,
        bg: _C.primaryLight,
        title: 'Download My Data',
        subtitle: 'Export all your HR data as a ZIP archive',
        onTap: () => _snack(
            'Data export requested — you\'ll receive an email', _C.successDark),
        trailing: _chevron(),
      ),
      _divider(),
      _SettingsTile(
        icon: Icons.delete_sweep_outlined,
        color: _C.textSec,
        bg: _C.surface,
        title: 'Clear App Cache',
        subtitle: 'Free up storage (${(24.7).toStringAsFixed(1)} MB cached)',
        onTap: () => _snack('Cache cleared — 24.7 MB freed', _C.successDark),
        trailing: _chevron(),
      ),
      _divider(),
      _SettingsTile(
        icon: Icons.policy_outlined,
        color: _C.accent,
        bg: _C.accentLight,
        title: 'Privacy Policy',
        subtitle: 'Read how ISF handles your data',
        onTap: () => _snack('Opening Privacy Policy…', _C.textSec),
        trailing: _chevron(),
      ),
    ]);
  }

  // ─────────────────────────────────────────────
  // ABOUT CARD
  // ─────────────────────────────────────────────
  Widget _buildAboutCard() {
    return _SettingsCard(children: [
      const _SettingsTile(
        icon: Icons.info_outline_rounded,
        color: _C.primary,
        bg: _C.primaryLight,
        title: 'App Version',
        subtitle: 'v3.2.1 (Build 241) · Released 29 Apr 2026',
        trailing: null,
      ),
      _divider(),
      _SettingsTile(
        icon: Icons.update_rounded,
        color: _C.teal,
        bg: _C.tealLight,
        title: 'Check for Updates',
        subtitle: 'You are on the latest version',
        onTap: () => _snack('ISmart is up to date ✅', _C.successDark),
        trailing: _chevron(),
      ),
      _divider(),
      _SettingsTile(
        icon: Icons.history_rounded,
        color: _C.accent,
        bg: _C.accentLight,
        title: 'Changelog',
        subtitle: 'What\'s new in v3.2.1',
        onTap: () => _showChangelog(),
        trailing: _chevron(),
      ),
      _divider(),
      _SettingsTile(
        icon: Icons.description_outlined,
        color: _C.textSec,
        bg: _C.surface,
        title: 'Terms of Service',
        subtitle: 'ISF Software Terms and Conditions',
        onTap: () => _snack('Opening Terms of Service…', _C.textSec),
        trailing: _chevron(),
      ),
      _divider(),
      _SettingsTile(
        icon: Icons.rate_review_outlined,
        color: _C.warningDark,
        bg: _C.warningLight,
        title: 'Rate the App',
        subtitle: 'Your feedback helps us improve ISmart',
        onTap: () => _snack('⭐ Thank you for rating ISmart!', _C.successDark),
        trailing: _chevron(),
      ),
      _divider(),
      _SettingsTile(
        icon: Icons.share_outlined,
        color: _C.purple,
        bg: _C.purpleLight,
        title: 'Share ISmart',
        subtitle: 'Invite your colleagues',
        onTap: () => _snack('Share link copied!', _C.textSec),
        trailing: _chevron(),
      ),
    ]);
  }

  void _showChangelog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: _C.border,
                          borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Row(children: [
                const Text('Changelog',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _C.textPrimary)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: _C.primaryLight,
                      borderRadius: BorderRadius.circular(20)),
                  child: const Text('v3.2.1',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _C.primary)),
                ),
              ]),
              const SizedBox(height: 4),
              const Text('Released 29 Apr 2026',
                  style: TextStyle(fontSize: 12, color: _C.textSec)),
              const SizedBox(height: 16),
              ...[
                (
                  '✨ New',
                  [
                    'Conveyance module: auto-calculate own vehicle fare at ₹8/km',
                    'Tax screen: live regime comparison (Old vs New)',
                    'Notices screen: full-text search across all notices',
                  ]
                ),
                (
                  '🔧 Improved',
                  [
                    'Payslip preview now supports pinch-to-zoom',
                    'Attendance calendar loads 40% faster',
                    'PF balance card now shows animated count-up',
                  ]
                ),
                (
                  '🐛 Fixed',
                  [
                    'Leave balance not refreshing after approval',
                    'Dark mode text colour contrast issues in modals',
                    'Biometric login failing on Android 15 devices',
                  ]
                ),
              ].map((entry) {
                final (section, items) = entry;
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(section,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _C.textPrimary)),
                      const SizedBox(height: 6),
                      ...items.map((item) => Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 5),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      width: 5,
                                      height: 5,
                                      margin: const EdgeInsets.only(
                                          top: 7, right: 8),
                                      decoration: const BoxDecoration(
                                          color: _C.primary,
                                          shape: BoxShape.circle)),
                                  Expanded(
                                      child: Text(item,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: _C.textSec,
                                              height: 1.4))),
                                ]),
                          )),
                      const SizedBox(height: 10),
                    ]);
              }),
            ]),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // LOGOUT BUTTON
  // ─────────────────────────────────────────────
  Widget _buildLogoutButton() => SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton.icon(
          onPressed: _showLogout,
          icon: const Icon(Icons.logout_rounded, size: 18),
          label: const Text('Log Out',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            foregroundColor: _C.error,
            side: const BorderSide(color: _C.error, width: 1.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: _C.errorLight,
          ),
        ),
      );

  // ─────────────────────────────────────────────
  // DANGER ZONE
  // ─────────────────────────────────────────────
  Widget _buildDangerZone() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _C.errorLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _C.error.withValues(alpha: .3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.warning_amber_rounded, size: 16, color: _C.error),
            SizedBox(width: 6),
            Text('Danger Zone',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _C.error)),
          ]),
          const SizedBox(height: 8),
          const Text(
              'Actions here are irreversible. Please contact HR before proceeding.',
              style: TextStyle(fontSize: 12, color: _C.errorDark, height: 1.4)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: _showDeactivate,
              style: OutlinedButton.styleFrom(
                foregroundColor: _C.error,
                side: const BorderSide(color: _C.error, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Request Account Deactivation',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      );

  // ── Shared helpers ──────────────────────────
  Widget _chevron() =>
      const Icon(Icons.chevron_right_rounded, size: 20, color: _C.textTert);

  Widget _switch(bool value, void Function(bool)? onChanged, Color color) =>
      Transform.scale(
        scale: 0.85,
        child: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: color,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );

  Widget _divider() => Container(
      height: 1,
      color: _C.border,
      margin: const EdgeInsets.symmetric(horizontal: 16));
}

// ─────────────────────────────────────────────
// SETTINGS CARD WRAPPER
// ─────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.border),
        ),
        child: Column(children: children),
      );
}

// ─────────────────────────────────────────────
// SETTINGS TILE
// ─────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color color, bg;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.color,
    required this.bg,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _C.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: _C.textSec, height: 1.3),
                    maxLines: 2),
              ])),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CHANGE PASSWORD SHEET
// ─────────────────────────────────────────────
class _ChangePasswordSheet extends StatefulWidget {
  final VoidCallback onSaved;
  const _ChangePasswordSheet({required this.onSaved});

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _saving = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String? _strength() {
    final p = _newCtrl.text;
    if (p.isEmpty) return null;
    if (p.length < 8) return 'Too short (min 8 chars)';
    final hasUpper = p.contains(RegExp(r'[A-Z]'));
    final hasLower = p.contains(RegExp(r'[a-z]'));
    final hasDigit = p.contains(RegExp(r'[0-9]'));
    final hasSpec = p.contains(RegExp(r'[^A-Za-z0-9]'));
    final score =
        [hasUpper, hasLower, hasDigit, hasSpec].where((b) => b).length;
    if (score <= 2) return 'Weak';
    if (score == 3) return 'Fair';
    return 'Strong ✓';
  }

  Color _strengthColor() {
    final s = _strength();
    if (s == null) return _C.border;
    if (s.startsWith('Too') || s == 'Weak') return _C.error;
    if (s == 'Fair') return _C.warning;
    return _C.successDark;
  }

  @override
  Widget build(BuildContext context) {
    final strength = _strength();
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, 32 + MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: _C.border,
                          borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Row(children: [
                Icon(Icons.lock_outline_rounded, size: 20, color: _C.error),
                SizedBox(width: 8),
                Text('Change Password',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _C.textPrimary)),
              ]),
              const SizedBox(height: 16),

              // Current password
              _pwField('Current Password *', _currentCtrl, _showCurrent,
                  () => setState(() => _showCurrent = !_showCurrent),
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 10),

              // New password
              _pwField(
                  'New Password *',
                  _newCtrl,
                  _showNew,
                  () => setState(() {
                        _showNew = !_showNew;
                      }), validator: (v) {
                if (v!.isEmpty) return 'Required';
                if (v.length < 8) return 'Minimum 8 characters';
                return null;
              }),

              // Strength indicator
              if (strength != null) ...[
                const SizedBox(height: 5),
                Row(children: [
                  Expanded(
                      child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: strength.startsWith('Too')
                          ? 0.2
                          : strength == 'Weak'
                              ? 0.35
                              : strength == 'Fair'
                                  ? 0.65
                                  : 1.0,
                      minHeight: 4,
                      backgroundColor: _C.border,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(_strengthColor()),
                    ),
                  )),
                  const SizedBox(width: 8),
                  Text(strength,
                      style: TextStyle(fontSize: 11, color: _strengthColor())),
                ]),
              ],
              const SizedBox(height: 10),

              // Confirm password
              _pwField('Confirm New Password *', _confirmCtrl, _showConfirm,
                  () => setState(() => _showConfirm = !_showConfirm),
                  validator: (v) {
                if (v!.isEmpty) return 'Required';
                if (v != _newCtrl.text) return 'Passwords do not match';
                return null;
              }),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saving
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          setState(() => _saving = true);
                          await Future.delayed(
                              const Duration(milliseconds: 1300));
                          if (mounted) widget.onSaved();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.primary,
                    disabledBackgroundColor: _C.textDisabled,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : const Text('Update Password',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
      ),
    );
  }

  Widget _pwField(String label, TextEditingController ctrl, bool show,
          VoidCallback onToggle,
          {String? Function(String?)? validator}) =>
      TextFormField(
        controller: ctrl,
        obscureText: !show,
        validator: validator,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(fontSize: 14, color: _C.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13, color: _C.textSec),
          filled: true,
          fillColor: _C.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.border, width: 1.5)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.border, width: 1.5)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.primary, width: 1.5)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.error, width: 1.5)),
          errorStyle: const TextStyle(fontSize: 11, color: _C.error),
          suffixIcon: IconButton(
            icon: Icon(
                show
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: _C.textSec),
            onPressed: onToggle,
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// ACTIVE SESSIONS SHEET
// ─────────────────────────────────────────────
class _ActiveSessionsSheet extends StatelessWidget {
  final void Function(String) onRevoke;

  const _ActiveSessionsSheet({required this.onRevoke});

  @override
  Widget build(BuildContext context) {
    final sessions = [
      (
        id: 's1',
        device: 'iPhone 15 Pro Max',
        location: 'Mumbai, India',
        platform: 'iOS 18.3',
        lastActive: 'Active now',
        isCurrent: true
      ),
      (
        id: 's2',
        device: 'MacBook Air M3',
        location: 'Mumbai, India',
        platform: 'Safari on macOS',
        lastActive: '2 hours ago',
        isCurrent: false
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: _C.border,
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Row(children: [
              Icon(Icons.devices_outlined, size: 20, color: _C.primary),
              SizedBox(width: 8),
              Text('Active Sessions',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary)),
            ]),
            const SizedBox(height: 4),
            const Text('These devices have active access to your account.',
                style: TextStyle(fontSize: 12, color: _C.textSec)),
            const SizedBox(height: 16),
            ...sessions.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: s.isCurrent ? _C.successLight : _C.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: s.isCurrent
                              ? _C.success.withValues(alpha: .3)
                              : _C.border),
                    ),
                    child: Row(children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: s.isCurrent ? _C.successLight : _C.card,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _C.border)),
                        child: Icon(
                          s.platform.contains('iOS') ||
                                  s.platform.contains('Android')
                              ? Icons.smartphone_outlined
                              : Icons.laptop_outlined,
                          size: 20,
                          color: _C.textSec,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Row(children: [
                              Text(s.device,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: _C.textPrimary)),
                              if (s.isCurrent) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: _C.successLight,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: const Text('Current',
                                      style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: _C.successDark)),
                                ),
                              ],
                            ]),
                            Text('${s.location} · ${s.platform}',
                                style: const TextStyle(
                                    fontSize: 11, color: _C.textSec)),
                            Text(s.lastActive,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: s.isCurrent
                                        ? _C.successDark
                                        : _C.textTert,
                                    fontWeight: s.isCurrent
                                        ? FontWeight.w600
                                        : FontWeight.w400)),
                          ])),
                      if (!s.isCurrent)
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            onRevoke(s.id);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                                color: _C.errorLight,
                                borderRadius: BorderRadius.circular(8)),
                            child: const Text('Revoke',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _C.error)),
                          ),
                        ),
                    ]),
                  ),
                )),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _C.textSec,
                  side: const BorderSide(color: _C.border, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Close',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ),
            ),
          ]),
    );
  }
}
