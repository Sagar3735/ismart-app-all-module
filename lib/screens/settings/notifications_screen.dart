// ============================================================
// ISF HR Portal — Notifications Screen
// File: lib/screens/settings/notifications_screen.dart
//
// Features:
//   - Unread count badge in app bar
//   - "Mark all as read" + "Clear all" actions
//   - Filter chips (All / Unread / HR / Payroll / Leave / IT / System)
//   - Grouped by date (Today / Yesterday / Earlier)
//   - Notification cards with icon, type badge, action button
//   - Swipe-to-dismiss individual notifications
//   - Tap to expand and see full notification body
//   - Notification preference settings bottom sheet
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
  static const successLight = Color(0xFFDCFCE7);
  static const successDark = Color(0xFF16A34A);
  static const warningLight = Color(0xFFFEF9C3);
  static const warningDark = Color(0xFFCA8A04);
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFEF2F2);
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
  static const border = Color(0xFFE2E8F0);
}

// ─────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────
enum _NotifType {
  hr,
  payroll,
  leave,
  it,
  system,
  attendance,
  approval,
  reminder
}

class _Notification {
  final String id;
  final _NotifType type;
  final String title;
  final String body;
  final String time;
  final String dateGroup; // 'today' | 'yesterday' | 'earlier'
  final String? actionLabel;
  final String? actionRoute;
  bool isRead;
  bool isExpanded = false;

  _Notification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    required this.dateGroup,
    this.actionLabel,
    this.actionRoute,
    this.isRead = false,
  });
}

// ─────────────────────────────────────────────
// TYPE METADATA
// ─────────────────────────────────────────────
({
  String label,
  IconData icon,
  Color color,
  Color bg,
}) _typeMeta(_NotifType t) {
  switch (t) {
    case _NotifType.hr:
      return (
        label: 'HR',
        icon: Icons.people_outline_rounded,
        color: _C.purple,
        bg: _C.purpleLight,
      );
    case _NotifType.payroll:
      return (
        label: 'Payroll',
        icon: Icons.account_balance_wallet_outlined,
        color: _C.successDark,
        bg: _C.successLight,
      );
    case _NotifType.leave:
      return (
        label: 'Leave',
        icon: Icons.event_available_outlined,
        color: _C.primary,
        bg: _C.primaryLight,
      );
    case _NotifType.it:
      return (
        label: 'IT',
        icon: Icons.computer_outlined,
        color: _C.teal,
        bg: _C.tealLight,
      );
    case _NotifType.system:
      return (
        label: 'System',
        icon: Icons.settings_outlined,
        color: _C.textSec,
        bg: _C.surface,
      );
    case _NotifType.attendance:
      return (
        label: 'Attendance',
        icon: Icons.access_time_rounded,
        color: _C.orange,
        bg: _C.orangeLight,
      );
    case _NotifType.approval:
      return (
        label: 'Approval',
        icon: Icons.check_circle_outline_rounded,
        color: _C.successDark,
        bg: _C.successLight,
      );
    case _NotifType.reminder:
      return (
        label: 'Reminder',
        icon: Icons.alarm_outlined,
        color: _C.warningDark,
        bg: _C.warningLight,
      );
  }
}

// ─────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────
final _allNotifications = [
  // TODAY
  _Notification(
    id: 'n01',
    type: _NotifType.approval,
    title: 'Leave Approved ✅',
    body:
        'Your casual leave request (LV-2026-041) from 05–07 May 2026 has been approved by Priya Mehta. Your leave balance has been updated accordingly.',
    time: '10:15 AM',
    dateGroup: 'today',
    actionLabel: 'View Leave',
    actionRoute: '/leave',
    isRead: false,
  ),
  _Notification(
    id: 'n02',
    type: _NotifType.payroll,
    title: 'April Payslip Available',
    body:
        'Your salary of ₹72,450 for April 2026 has been credited. Payslip is available for download in the Payroll section.',
    time: '09:05 AM',
    dateGroup: 'today',
    actionLabel: 'View Payslip',
    actionRoute: '/payslip',
    isRead: false,
  ),
  _Notification(
    id: 'n03',
    type: _NotifType.attendance,
    title: 'Missed Punch Out',
    body:
        'You have not recorded a punch out for today (29 Apr 2026). Please regularize via the Attendance module to avoid a mark.',
    time: '08:30 PM',
    dateGroup: 'today',
    actionLabel: 'Regularize',
    actionRoute: '/regularize',
    isRead: false,
  ),
  _Notification(
    id: 'n04',
    type: _NotifType.reminder,
    title: 'IT Declaration Deadline',
    body:
        'Reminder: Your Income Tax Declaration for FY 2026-27 must be submitted by 15 Dec 2026. You have 3 sections pending.',
    time: '08:00 AM',
    dateGroup: 'today',
    actionLabel: 'Declare Now',
    actionRoute: '/tax',
    isRead: false,
  ),

  // YESTERDAY
  _Notification(
    id: 'n05',
    type: _NotifType.hr,
    title: 'Query Resolved — REG-2026-014',
    body:
        'Your attendance regularization request for 15 Apr 2026 has been reviewed. Please check the updated status in the Regularize module.',
    time: '04:30 PM',
    dateGroup: 'yesterday',
    actionLabel: 'View Status',
    actionRoute: '/regularize',
    isRead: true,
  ),
  _Notification(
    id: 'n06',
    type: _NotifType.leave,
    title: 'Leave Request Submitted',
    body:
        'Your earned leave application (LV-2026-041) for 05–07 May 2026 has been submitted and is pending approval by Priya Mehta.',
    time: '02:15 PM',
    dateGroup: 'yesterday',
    isRead: true,
  ),
  _Notification(
    id: 'n07',
    type: _NotifType.it,
    title: 'VPN Token Reset',
    body:
        'Your VPN access token has been reset by the IT team (Ticket TKT-2026-0041). Try connecting again with your current credentials.',
    time: '11:30 AM',
    dateGroup: 'yesterday',
    actionLabel: 'View Ticket',
    actionRoute: '/tickets',
    isRead: true,
  ),
  _Notification(
    id: 'n08',
    type: _NotifType.system,
    title: 'App Updated — v3.2.1',
    body:
        'ISmart HR Portal has been updated to v3.2.1. New features include: improved payslip viewer, dark mode, and faster attendance sync.',
    time: '07:00 AM',
    dateGroup: 'yesterday',
    isRead: true,
  ),

  // EARLIER
  _Notification(
    id: 'n09',
    type: _NotifType.payroll,
    title: 'PF Contribution Processed',
    body:
        'Your PF contribution for April 2026 — Employee: ₹5,100 + Employer: ₹6,660 — has been remitted to EPFO.',
    time: '27 Apr',
    dateGroup: 'earlier',
    isRead: true,
  ),
  _Notification(
    id: 'n10',
    type: _NotifType.hr,
    title: 'Tour Request Approved',
    body:
        'Your outstation tour request (TRV-2026-008) to Pune Client Office on 12–13 May 2026 has been approved. Book via Cleartrip corporate.',
    time: '26 Apr',
    dateGroup: 'earlier',
    actionLabel: 'View Tour',
    actionRoute: '/tour',
    isRead: true,
  ),
  _Notification(
    id: 'n11',
    type: _NotifType.reminder,
    title: 'Holiday Tomorrow: Holi 🎨',
    body:
        'Tomorrow, 14 Mar 2026 is Ambedkar Jayanti — a national holiday. ISF offices will remain closed. Enjoy the long weekend!',
    time: '25 Apr',
    dateGroup: 'earlier',
    isRead: true,
  ),
  _Notification(
    id: 'n12',
    type: _NotifType.attendance,
    title: 'OT Request Approved',
    body:
        'Your overtime request (OT-2026-024) for 28 Apr 2026 has been approved by Priya Mehta. EMI deduction will be processed next month.',
    time: '24 Apr',
    dateGroup: 'earlier',
    actionLabel: 'View OT',
    actionRoute: '/overtime',
    isRead: true,
  ),
];

const _filterLabels = [
  'All',
  'Unread',
  'HR',
  'Payroll',
  'Leave',
  'IT',
  'System'
];

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_Notification> _notifications = List.from(_allNotifications);
  String _activeFilter = 'All';

  // ── Computed ──────────────────────────────────
  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  List<_Notification> get _filtered {
    switch (_activeFilter) {
      case 'Unread':
        return _notifications.where((n) => !n.isRead).toList();
      case 'HR':
        return _notifications
            .where(
                (n) => n.type == _NotifType.hr || n.type == _NotifType.approval)
            .toList();
      case 'Payroll':
        return _notifications
            .where((n) => n.type == _NotifType.payroll)
            .toList();
      case 'Leave':
        return _notifications.where((n) => n.type == _NotifType.leave).toList();
      case 'IT':
        return _notifications.where((n) => n.type == _NotifType.it).toList();
      case 'System':
        return _notifications
            .where((n) =>
                n.type == _NotifType.system || n.type == _NotifType.reminder)
            .toList();
      default:
        return _notifications;
    }
  }

  // Group filtered list by dateGroup
  Map<String, List<_Notification>> get _grouped {
    final map = <String, List<_Notification>>{};
    for (final n in _filtered) {
      (map[n.dateGroup] ??= []).add(n);
    }
    return map;
  }

  // ── Actions ───────────────────────────────────
  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
    _snack('All notifications marked as read', _C.textSec);
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear All Notifications?',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        content: const Text('All notifications will be permanently deleted.',
            style: TextStyle(fontSize: 14, color: _C.textSec)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: _C.textSec)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _notifications.clear());
              _snack('All notifications cleared', _C.textSec);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _dismiss(_Notification n) {
    setState(() => _notifications.removeWhere((x) => x.id == n.id));
    _snack('Notification dismissed', _C.textSec);
  }

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

  void _showPreferences() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _PreferencesSheet(),
    );
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    final hasNotifs = _filtered.isNotEmpty;

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _buildAppBar(),
      body: Column(children: [
        // Filter chips
        _buildFilters(),
        // List or empty state
        Expanded(
          child: hasNotifs
              ? ListView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 48),
                  children: [
                    // Today group
                    if (grouped['today']?.isNotEmpty == true) ...[
                      _GroupHeader('Today', grouped['today']!.length),
                      const SizedBox(height: 8),
                      ...grouped['today']!.map((n) => _NotifCard(
                            notif: n,
                            onDismiss: () => _dismiss(n),
                            onTap: () => setState(() {
                              n.isRead = true;
                              n.isExpanded = !n.isExpanded;
                            }),
                            onAction: () {
                              setState(() => n.isRead = true);
                              _snack('Opening ${n.actionRoute ?? "screen"}…',
                                  _C.primary);
                            },
                          )),
                      const SizedBox(height: 16),
                    ],
                    // Yesterday group
                    if (grouped['yesterday']?.isNotEmpty == true) ...[
                      _GroupHeader('Yesterday', grouped['yesterday']!.length),
                      const SizedBox(height: 8),
                      ...grouped['yesterday']!.map((n) => _NotifCard(
                            notif: n,
                            onDismiss: () => _dismiss(n),
                            onTap: () => setState(() {
                              n.isRead = true;
                              n.isExpanded = !n.isExpanded;
                            }),
                            onAction: () {
                              setState(() => n.isRead = true);
                              _snack('Opening ${n.actionRoute ?? "screen"}…',
                                  _C.primary);
                            },
                          )),
                      const SizedBox(height: 16),
                    ],
                    // Earlier group
                    if (grouped['earlier']?.isNotEmpty == true) ...[
                      _GroupHeader('Earlier', grouped['earlier']!.length),
                      const SizedBox(height: 8),
                      ...grouped['earlier']!.map((n) => _NotifCard(
                            notif: n,
                            onDismiss: () => _dismiss(n),
                            onTap: () => setState(() {
                              n.isRead = true;
                              n.isExpanded = !n.isExpanded;
                            }),
                            onAction: () {
                              setState(() => n.isRead = true);
                              _snack('Opening ${n.actionRoute ?? "screen"}…',
                                  _C.primary);
                            },
                          )),
                    ],
                  ],
                )
              : _EmptyState(filterLabel: _activeFilter),
        ),
      ]),
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
        title: Row(children: [
          const Text('Notifications',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: _C.textPrimary)),
          if (_unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                  color: _C.error, borderRadius: BorderRadius.circular(20)),
              child: Text('$_unreadCount',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ),
          ],
        ]),
        actions: [
          // Preferences
          IconButton(
            icon: const Icon(Icons.tune_rounded, size: 20),
            color: _C.textSec,
            onPressed: _showPreferences,
            tooltip: 'Preferences',
          ),
          // More menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded,
                size: 20, color: _C.textSec),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 8,
            shadowColor: Colors.black12,
            color: _C.card,
            onSelected: (val) {
              if (val == 'mark_all') _markAllRead();
              if (val == 'clear_all') _clearAll();
            },
            itemBuilder: (_) => [
              _menuItem('mark_all', Icons.done_all_rounded, 'Mark All as Read',
                  _C.primary),
              _menuItem('clear_all', Icons.delete_sweep_outlined, 'Clear All',
                  _C.error),
            ],
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _C.border),
        ),
      );

  PopupMenuItem<String> _menuItem(
          String val, IconData icon, String label, Color color) =>
      PopupMenuItem(
        value: val,
        height: 44,
        child: Row(children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500, color: color)),
        ]),
      );

  // ─────────────────────────────────────────────
  // FILTER CHIPS
  // ─────────────────────────────────────────────
  Widget _buildFilters() {
    return Container(
      color: _C.card,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filterLabels.map((label) {
            final active = label == _activeFilter;
            // Count per filter
            int count;
            switch (label) {
              case 'All':
                count = _notifications.length;
                break;
              case 'Unread':
                count = _unreadCount;
                break;
              case 'HR':
                count = _notifications
                    .where((n) =>
                        n.type == _NotifType.hr ||
                        n.type == _NotifType.approval)
                    .length;
                break;
              case 'Payroll':
                count = _notifications
                    .where((n) => n.type == _NotifType.payroll)
                    .length;
                break;
              case 'Leave':
                count = _notifications
                    .where((n) => n.type == _NotifType.leave)
                    .length;
                break;
              case 'IT':
                count =
                    _notifications.where((n) => n.type == _NotifType.it).length;
                break;
              case 'System':
                count = _notifications
                    .where((n) =>
                        n.type == _NotifType.system ||
                        n.type == _NotifType.reminder)
                    .length;
                break;
              default:
                count = 0;
            }

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _activeFilter = label),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: active ? _C.primary : _C.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: active ? _C.primary : _C.border,
                    ),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(label,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: active ? Colors.white : _C.textSec)),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color:
                            active ? Colors.white.withValues(alpha: .25) : _C.border,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$count',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: active ? Colors.white : _C.textSec)),
                    ),
                  ]),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// GROUP HEADER
// ─────────────────────────────────────────────
class _GroupHeader extends StatelessWidget {
  final String label;
  final int count;
  const _GroupHeader(this.label, this.count);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(label,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _C.textPrimary)),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
            color: _C.surface, borderRadius: BorderRadius.circular(10)),
        child: Text('$count',
            style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700, color: _C.textSec)),
      ),
      const SizedBox(width: 10),
      Expanded(child: Container(height: 1, color: _C.border)),
    ]);
  }
}

// ─────────────────────────────────────────────
// NOTIFICATION CARD
// ─────────────────────────────────────────────
class _NotifCard extends StatelessWidget {
  final _Notification notif;
  final VoidCallback onDismiss;
  final VoidCallback onTap;
  final VoidCallback? onAction;

  const _NotifCard({
    required this.notif,
    required this.onDismiss,
    required this.onTap,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final meta = _typeMeta(notif.type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: Key(notif.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
              color: _C.errorLight, borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.delete_outline_rounded,
              color: _C.error, size: 24),
        ),
        onDismissed: (_) => onDismiss(),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: notif.isRead ? _C.card : const Color(0xFFF0F5FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: notif.isRead ? _C.border : _C.primary.withValues(alpha: .25),
                width: notif.isRead ? 1 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon circle
                      Stack(children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: meta.bg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(meta.icon, size: 20, color: meta.color),
                        ),
                        // Unread dot
                        if (!notif.isRead)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _C.primary,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 1.5),
                              ),
                            ),
                          ),
                      ]),
                      const SizedBox(width: 12),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Type chip + time
                            Row(children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: meta.bg,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: meta.color.withValues(alpha: .2)),
                                ),
                                child: Text(meta.label,
                                    style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: meta.color)),
                              ),
                              const Spacer(),
                              Text(notif.time,
                                  style: const TextStyle(
                                      fontSize: 10, color: _C.textTert)),
                            ]),
                            const SizedBox(height: 5),

                            // Title
                            Text(notif.title,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: notif.isRead
                                        ? FontWeight.w600
                                        : FontWeight.w800,
                                    color: _C.textPrimary)),
                            const SizedBox(height: 4),

                            // Body (truncated unless expanded)
                            Text(
                              notif.body,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: _C.textSec,
                                  height: 1.5,
                                  fontWeight: notif.isRead
                                      ? FontWeight.w400
                                      : FontWeight.w500),
                              maxLines: notif.isExpanded ? null : 2,
                              overflow: notif.isExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Action button + expand indicator
                  if (notif.actionLabel != null || !notif.isExpanded) ...[
                    const SizedBox(height: 10),
                    Row(children: [
                      // Action button
                      if (notif.actionLabel != null)
                        GestureDetector(
                          onTap: onAction,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: meta.color,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(notif.actionLabel!,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                          ),
                        ),

                      const Spacer(),

                      // Expand indicator
                      AnimatedRotation(
                        turns: notif.isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: _C.textTert,
                        ),
                      ),
                    ]),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String filterLabel;
  const _EmptyState({required this.filterLabel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
                color: _C.primaryLight,
                borderRadius: BorderRadius.circular(24)),
            child: const Icon(Icons.notifications_none_rounded,
                size: 42, color: _C.primary),
          ),
          const SizedBox(height: 20),
          Text(
            filterLabel == 'All'
                ? 'No notifications'
                : 'No $filterLabel notifications',
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _C.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            filterLabel == 'Unread'
                ? 'You\'re all caught up! 🎉'
                : 'Notifications will appear here when available.',
            textAlign: TextAlign.center,
            style:
                const TextStyle(fontSize: 14, color: _C.textSec, height: 1.5),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PREFERENCES SHEET
// ─────────────────────────────────────────────
class _PreferencesSheet extends StatefulWidget {
  const _PreferencesSheet();

  @override
  State<_PreferencesSheet> createState() => _PreferencesSheetState();
}

class _PreferencesSheetState extends State<_PreferencesSheet> {
  // Toggle states
  final _prefs = {
    'push': true,
    'email': true,
    'sms': false,
    'hr': true,
    'payroll': true,
    'leave': true,
    'attendance': true,
    'it': true,
    'reminders': true,
    'system': false,
  };

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      minChildSize: 0.5,
      expand: false,
      builder: (_, ctrl) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: _C.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),

            // Title
            Row(children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: _C.primaryLight,
                    borderRadius: BorderRadius.circular(10)),
                child:
                    const Icon(Icons.tune_rounded, size: 18, color: _C.primary),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notification Preferences',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _C.textPrimary)),
                  Text('Manage how you receive alerts',
                      style: TextStyle(fontSize: 12, color: _C.textSec)),
                ],
              ),
            ]),
            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                controller: ctrl,
                children: [
                  // Channels
                  _sectionHeader('Notification Channels'),
                  _prefTile(
                      'push',
                      Icons.notifications_outlined,
                      'Push Notifications',
                      'In-app & mobile alerts',
                      _C.primary,
                      _C.primaryLight),
                  _prefTile(
                      'email',
                      Icons.email_outlined,
                      'Email Notifications',
                      'Sent to work email',
                      _C.teal,
                      _C.tealLight),
                  _prefTile('sms', Icons.sms_outlined, 'SMS Alerts',
                      'Critical alerts via SMS', _C.orange, _C.orangeLight),
                  const SizedBox(height: 16),

                  // Categories
                  _sectionHeader('Alert Categories'),
                  _prefTile(
                      'hr',
                      Icons.people_outline_rounded,
                      'HR & Approvals',
                      'Leave, tour, regularize',
                      _C.purple,
                      _C.purpleLight),
                  _prefTile(
                      'payroll',
                      Icons.account_balance_wallet_outlined,
                      'Payroll',
                      'Payslip, PF, ESIC updates',
                      _C.successDark,
                      _C.successLight),
                  _prefTile(
                      'leave',
                      Icons.event_available_outlined,
                      'Leave Management',
                      'Apply, approve, balance',
                      _C.primary,
                      _C.primaryLight),
                  _prefTile(
                      'attendance',
                      Icons.access_time_rounded,
                      'Attendance',
                      'Punch reminders, OT alerts',
                      _C.orange,
                      _C.orangeLight),
                  _prefTile('it', Icons.computer_outlined, 'IT & Helpdesk',
                      'Ticket updates', _C.teal, _C.tealLight),
                  _prefTile('reminders', Icons.alarm_outlined, 'Reminders',
                      'Deadlines, holidays', _C.warningDark, _C.warningLight),
                  _prefTile('system', Icons.settings_outlined, 'System Updates',
                      'App updates & maintenance', _C.textSec, _C.surface),
                  const SizedBox(height: 16),

                  // Save
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Preferences saved ✅',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                            backgroundColor: _C.successDark,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            margin: const EdgeInsets.all(16),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _C.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save Preferences',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _C.textSec,
                letterSpacing: 0.5)),
      );

  Widget _prefTile(String key, IconData icon, String title, String sub,
          Color color, Color bg) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          decoration: BoxDecoration(
            color: _C.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _C.border),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: color),
            ),
            title: Text(title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _C.textPrimary)),
            subtitle: Text(sub,
                style: const TextStyle(fontSize: 11, color: _C.textSec)),
            trailing: Transform.scale(
              scale: 0.85,
              child: Switch(
                value: _prefs[key] ?? false,
                onChanged: (v) => setState(() => _prefs[key] = v),
                activeThumbColor: color,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ),
      );
}
