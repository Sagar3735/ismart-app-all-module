// ============================================================
// ISF HR Portal — Leave Apply Screen
// File: lib/screens/leave/leave_apply_screen.dart
//
// Features:
//   - Tab 1: Apply — full leave application form
//       • Leave type selector with balance cards
//       • Date range picker (from/to with calendar)
//       • Half-day toggle with AM/PM selector
//       • Working days auto-calculation (excludes weekends)
//       • Balance exceeded warning
//       • Reporting manager selector (bottom sheet)
//       • Reason text field with char counter
//       • Optional file attachment
//       • Validation + animated submit button
//   - Tab 2: History — leave application list
//       • Filter chips (All / Pending / Approved / Rejected)
//       • Expandable cards with manager comment
//       • Cancel pending leave option
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
  static const success = Color(0xFF22C55E);
  static const successLight = Color(0xFFDCFCE7);
  static const successDark = Color(0xFF16A34A);
  static const warningLight = Color(0xFFFEF9C3);
  static const warningDark = Color(0xFFCA8A04);
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFEF2F2);
  static const errorDark = Color(0xFFDC2626);
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
// MODELS
// ─────────────────────────────────────────────
enum LeaveType { casual, sick, earned, compOff }

enum LeaveStatus { pending, approved, rejected, cancelled }

class _LeaveBalance {
  final LeaveType type;
  final String label;
  final int total;
  final int used;
  final int balance;
  final Color color;
  final Color bg;
  final IconData icon;

  const _LeaveBalance({
    required this.type,
    required this.label,
    required this.total,
    required this.used,
    required this.balance,
    required this.color,
    required this.bg,
    required this.icon,
  });
}

class _Manager {
  final String id, initials, name, role, department;
  final Color avatarColor;
  const _Manager({
    required this.id,
    required this.initials,
    required this.name,
    required this.role,
    required this.department,
    required this.avatarColor,
  });
}

class _LeaveApplication {
  final String id;
  final LeaveType type;
  final DateTime fromDate, toDate;
  final double days;
  final bool isHalfDay;
  final String? halfDayPeriod;
  final String reason;
  final String managerName;
  final LeaveStatus status;
  final String appliedOn;
  final String? managerComment;
  bool expanded = false;

  _LeaveApplication({
    required this.id,
    required this.type,
    required this.fromDate,
    required this.toDate,
    required this.days,
    required this.isHalfDay,
    this.halfDayPeriod,
    required this.reason,
    required this.managerName,
    required this.status,
    required this.appliedOn,
    this.managerComment,
  });
}

// ─────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────
const _balances = [
  _LeaveBalance(
    type: LeaveType.casual,
    label: 'Casual',
    total: 15,
    used: 3,
    balance: 12,
    color: _C.primary,
    bg: _C.primaryLight,
    icon: Icons.calendar_today_outlined,
  ),
  _LeaveBalance(
    type: LeaveType.sick,
    label: 'Sick',
    total: 10,
    used: 4,
    balance: 6,
    color: _C.error,
    bg: _C.errorLight,
    icon: Icons.local_hospital_outlined,
  ),
  _LeaveBalance(
    type: LeaveType.earned,
    label: 'Earned',
    total: 21,
    used: 3,
    balance: 18,
    color: _C.successDark,
    bg: _C.successLight,
    icon: Icons.event_available_outlined,
  ),
  _LeaveBalance(
    type: LeaveType.compOff,
    label: 'Comp Off',
    total: 2,
    used: 0,
    balance: 2,
    color: _C.purple,
    bg: _C.purpleLight,
    icon: Icons.swap_horiz_rounded,
  ),
];

const _managers = [
  _Manager(
    id: 'mgr1',
    initials: 'PM',
    name: 'Priya Mehta',
    role: 'Direct Manager',
    department: 'IT Department',
    avatarColor: Color(0xFF6366F1),
  ),
  _Manager(
    id: 'mgr2',
    initials: 'RK',
    name: 'Rajesh Kumar',
    role: 'Senior Manager',
    department: 'Operations',
    avatarColor: Color(0xFF0EA5E9),
  ),
  _Manager(
    id: 'mgr3',
    initials: 'SP',
    name: 'Sneha Patil',
    role: 'HR Manager',
    department: 'People & Culture',
    avatarColor: Color(0xFFEC4899),
  ),
];

final _mockHistory = [
  _LeaveApplication(
    id: 'LV-2026-032',
    type: LeaveType.casual,
    fromDate: DateTime(2026, 4, 10),
    toDate: DateTime(2026, 4, 11),
    days: 2,
    isHalfDay: false,
    reason: 'Family function',
    managerName: 'Priya Mehta',
    status: LeaveStatus.approved,
    appliedOn: '07 Apr 2026',
    managerComment: 'Approved. Enjoy your time!',
  ),
  _LeaveApplication(
    id: 'LV-2026-021',
    type: LeaveType.sick,
    fromDate: DateTime(2026, 3, 18),
    toDate: DateTime(2026, 3, 18),
    days: 1,
    isHalfDay: false,
    reason: 'Fever and cold',
    managerName: 'Priya Mehta',
    status: LeaveStatus.approved,
    appliedOn: '18 Mar 2026',
    managerComment: 'Get well soon.',
  ),
  _LeaveApplication(
    id: 'LV-2026-041',
    type: LeaveType.earned,
    fromDate: DateTime(2026, 5, 5),
    toDate: DateTime(2026, 5, 7),
    days: 3,
    isHalfDay: false,
    reason: 'Annual vacation',
    managerName: 'Priya Mehta',
    status: LeaveStatus.pending,
    appliedOn: '25 Apr 2026',
  ),
  _LeaveApplication(
    id: 'LV-2026-009',
    type: LeaveType.casual,
    fromDate: DateTime(2026, 2, 14),
    toDate: DateTime(2026, 2, 14),
    days: 1,
    isHalfDay: false,
    reason: 'Personal work',
    managerName: 'Rajesh Kumar',
    status: LeaveStatus.rejected,
    appliedOn: '12 Feb 2026',
    managerComment: 'Critical deliverable due. Please reschedule.',
  ),
];

const _filterLabels = ['All', 'Pending', 'Approved', 'Rejected'];

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────
_LeaveBalance _balanceFor(LeaveType t) =>
    _balances.firstWhere((b) => b.type == t);

String _formatDate(DateTime d) {
  const months = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return '${d.day} ${months[d.month]} ${d.year}';
}

String _formatDateShort(DateTime d) {
  const months = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return '${d.day} ${months[d.month]}';
}

int _calcWorkingDays(DateTime from, DateTime to) {
  int count = 0;
  DateTime cur = from;
  while (!cur.isAfter(to)) {
    if (cur.weekday != DateTime.saturday && cur.weekday != DateTime.sunday) {
      count++;
    }
    cur = cur.add(const Duration(days: 1));
  }
  return count;
}

({String label, Color color, Color bg, IconData icon}) _statusMeta(
    LeaveStatus s) {
  switch (s) {
    case LeaveStatus.pending:
      return (
        label: 'Pending',
        color: _C.warningDark,
        bg: _C.warningLight,
        icon: Icons.hourglass_top_rounded
      );
    case LeaveStatus.approved:
      return (
        label: 'Approved',
        color: _C.successDark,
        bg: _C.successLight,
        icon: Icons.check_circle_outline_rounded
      );
    case LeaveStatus.rejected:
      return (
        label: 'Rejected',
        color: _C.errorDark,
        bg: _C.errorLight,
        icon: Icons.cancel_outlined
      );
    case LeaveStatus.cancelled:
      return (
        label: 'Cancelled',
        color: _C.textSec,
        bg: _C.surface,
        icon: Icons.remove_circle_outline_rounded
      );
  }
}

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class LeaveApplyScreen extends StatefulWidget {
  const LeaveApplyScreen({super.key});

  @override
  State<LeaveApplyScreen> createState() => _LeaveApplyScreenState();
}

class _LeaveApplyScreenState extends State<LeaveApplyScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final List<_LeaveApplication> _history = List.from(_mockHistory);

  // ── Form state ─────────────────────────────
  LeaveType? _leaveType;
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _isHalfDay = false;
  String _halfDayPeriod = 'AM';
  _Manager _manager = _managers[0];
  final _reasonCtrl = TextEditingController();
  bool _hasAttachment = false;
  bool _submitting = false;

  // ── History state ──────────────────────────
  int _activeFilter = 0;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  // ── Computed ──────────────────────────────
  int get _workingDays {
    if (_fromDate == null || _toDate == null) return 0;
    return _calcWorkingDays(_fromDate!, _toDate!);
  }

  double get _totalDays => _isHalfDay ? 0.5 : _workingDays.toDouble();

  _LeaveBalance? get _selectedBalance =>
      _leaveType != null ? _balanceFor(_leaveType!) : null;

  bool get _exceedsBalance =>
      _selectedBalance != null &&
      _totalDays > 0 &&
      _totalDays > _selectedBalance!.balance;

  bool get _formValid =>
      _leaveType != null &&
      _fromDate != null &&
      _toDate != null &&
      _reasonCtrl.text.trim().length >= 5 &&
      !_exceedsBalance &&
      !_submitting;

  // ── Date picker ──────────────────────────
  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: _datePickerTheme,
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked;
        if (_toDate != null && _toDate!.isBefore(picked)) {
          _toDate = picked;
        }
      });
    }
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? _fromDate ?? DateTime.now(),
      firstDate: _fromDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: _datePickerTheme,
    );
    if (picked != null) setState(() => _toDate = picked);
  }

  Widget Function(BuildContext, Widget?) get _datePickerTheme =>
      (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(
                primary: _C.primary,
                onPrimary: Colors.white,
                surface: _C.card,
              ),
            ),
            child: child!,
          );

  // ── Submit ──────────────────────────────
  Future<void> _submit() async {
    if (!_formValid) return;
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final newApp = _LeaveApplication(
      id: 'LV-2026-0${50 + _history.length}',
      type: _leaveType!,
      fromDate: _fromDate!,
      toDate: _toDate!,
      days: _totalDays,
      isHalfDay: _isHalfDay,
      halfDayPeriod: _isHalfDay ? _halfDayPeriod : null,
      reason: _reasonCtrl.text.trim(),
      managerName: _manager.name,
      status: LeaveStatus.pending,
      appliedOn: _formatDate(DateTime.now()),
    );

    setState(() {
      _submitting = false;
      _history.insert(0, newApp);
      _leaveType = null;
      _fromDate = null;
      _toDate = null;
      _isHalfDay = false;
      _halfDayPeriod = 'AM';
      _hasAttachment = false;
      _reasonCtrl.clear();
      _tabCtrl.animateTo(1);
    });

    _showSnack('Leave request submitted ✅', _C.successDark);
  }

  void _cancelLeave(_LeaveApplication app) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Leave?',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        content: Text(
            'Cancel leave request ${app.id}? This action cannot be undone.',
            style: const TextStyle(fontSize: 14, color: _C.textSec)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep', style: TextStyle(color: _C.textSec)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                final idx = _history.indexWhere((h) => h.id == app.id);
                if (idx != -1) {
                  _history[idx] = _LeaveApplication(
                    id: app.id,
                    type: app.type,
                    fromDate: app.fromDate,
                    toDate: app.toDate,
                    days: app.days,
                    isHalfDay: app.isHalfDay,
                    reason: app.reason,
                    managerName: app.managerName,
                    status: LeaveStatus.cancelled,
                    appliedOn: app.appliedOn,
                  );
                }
              });
              _showSnack('Leave ${app.id} cancelled', _C.textSec);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Cancel Leave'),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: bg,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ));
  }

  void _showManagerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ManagerSheet(
        selected: _manager,
        onSelect: (m) {
          setState(() => _manager = m);
          Navigator.pop(context);
        },
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
      body: Column(children: [
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _buildApplyTab(),
              _buildHistoryTab(),
            ],
          ),
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
        title: const Text('Leave Apply',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        actions: [
          // Leave policy info button
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, size: 20),
            color: _C.textSec,
            onPressed: _showLeavePolicy,
            tooltip: 'Leave Policy',
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _C.border),
        ),
      );

  // ─────────────────────────────────────────────
  // TAB BAR
  // ─────────────────────────────────────────────
  Widget _buildTabBar() => Container(
        color: _C.card,
        child: TabBar(
          controller: _tabCtrl,
          tabs: const [Tab(text: 'Apply'), Tab(text: 'History')],
          labelColor: _C.primary,
          unselectedLabelColor: _C.textSec,
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          indicatorColor: _C.primary,
          indicatorWeight: 2.5,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: _C.border,
        ),
      );

  // ─────────────────────────────────────────────
  // TAB 1: APPLY
  // ─────────────────────────────────────────────
  Widget _buildApplyTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        // ── Balance Cards ─────────────────────
        _BalanceCardsRow(
          balances: _balances,
          selected: _leaveType,
          onSelect: (t) => setState(() => _leaveType = t),
        ),
        const SizedBox(height: 16),

        // ── Main Form Card ────────────────────
        _formCard(),
      ],
    );
  }

  Widget _formCard() {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Column(children: [
        // Card header
        const _CardHeader(
            title: 'Leave Application', icon: Icons.event_note_outlined),

        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Leave type pills ─────────────
              const _FieldLabel('Leave Type *'),
              const SizedBox(height: 8),
              Row(
                  children: _balances.map((b) {
                final active = _leaveType == b.type;
                return Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.only(right: b != _balances.last ? 8 : 0),
                    child: GestureDetector(
                      onTap: () => setState(() => _leaveType = b.type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        height: 38,
                        decoration: BoxDecoration(
                          color: active ? b.color : _C.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: active ? b.color : _C.border,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(b.label,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: active ? Colors.white : _C.textSec)),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList()),
              const SizedBox(height: 16),

              // ── Date range ───────────────────
              const _FieldLabel('Duration *'),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                    child: _DateField(
                  label: 'From',
                  value: _fromDate,
                  onTap: _pickFromDate,
                  icon: Icons.calendar_month_outlined,
                )),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 24,
                      height: 2,
                      decoration: BoxDecoration(
                          color: _C.border,
                          borderRadius: BorderRadius.circular(1)),
                    ),
                  ]),
                ),
                Expanded(
                    child: _DateField(
                  label: 'To',
                  value: _toDate,
                  onTap: _pickToDate,
                  icon: Icons.calendar_month_outlined,
                  enabled: _fromDate != null,
                )),
              ]),
              const SizedBox(height: 12),

              // ── Days summary box ─────────────
              if (_totalDays > 0)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _exceedsBalance
                        ? _C.errorLight
                        : _selectedBalance != null
                            ? _selectedBalance!.bg
                            : _C.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _exceedsBalance
                          ? _C.error.withValues(alpha: .4)
                          : _selectedBalance != null
                              ? _selectedBalance!.color.withValues(alpha: .3)
                              : _C.primary.withValues(alpha: .3),
                    ),
                  ),
                  child: Row(children: [
                    Icon(
                      _exceedsBalance
                          ? Icons.warning_amber_rounded
                          : Icons.info_outline_rounded,
                      size: 18,
                      color: _exceedsBalance
                          ? _C.errorDark
                          : _selectedBalance?.color ?? _C.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _exceedsBalance
                          ? RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                    fontSize: 13, color: _C.errorDark),
                                children: [
                                  const TextSpan(
                                      text: 'Insufficient balance. '),
                                  TextSpan(
                                    text:
                                        'You have ${_selectedBalance!.balance} day${_selectedBalance!.balance != 1 ? "s" : ""} left.',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            )
                          : RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                    fontSize: 13, color: _C.textPrimary),
                                children: [
                                  const TextSpan(text: 'Total: '),
                                  TextSpan(
                                    text:
                                        '${_totalDays == _totalDays.roundToDouble() ? _totalDays.toInt() : _totalDays} day${_totalDays != 1 ? "s" : ""}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: _selectedBalance?.color ??
                                            _C.primary),
                                  ),
                                  if (_selectedBalance != null)
                                    TextSpan(
                                      text:
                                          '  ·  ${_selectedBalance!.balance} remaining',
                                      style: const TextStyle(
                                          fontSize: 12, color: _C.textSec),
                                    ),
                                ],
                              ),
                            ),
                    ),
                  ]),
                ),
              if (_totalDays > 0) const SizedBox(height: 12),

              // ── Half day toggle ──────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _isHalfDay ? _C.primaryLight : _C.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isHalfDay ? _C.primary.withValues(alpha: .3) : _C.border,
                  ),
                ),
                child: Column(children: [
                  Row(children: [
                    Icon(Icons.wb_twilight_outlined,
                        size: 18, color: _isHalfDay ? _C.primary : _C.textSec),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Half Day',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color:
                                    _isHalfDay ? _C.primary : _C.textPrimary)),
                        const Text('Apply for half day only',
                            style: TextStyle(fontSize: 11, color: _C.textSec)),
                      ],
                    )),
                    Transform.scale(
                      scale: 0.85,
                      child: Switch(
                        value: _isHalfDay,
                        onChanged: (v) => setState(() => _isHalfDay = v),
                        activeThumbColor: _C.primary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ]),
                  if (_isHalfDay) ...[
                    const SizedBox(height: 12),
                    Row(
                        children: ['AM', 'PM'].map((p) {
                      final sel = _halfDayPeriod == p;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: p == 'AM' ? 8 : 0),
                          child: GestureDetector(
                            onTap: () => setState(() => _halfDayPeriod = p),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              height: 38,
                              decoration: BoxDecoration(
                                color: sel ? _C.primary : _C.card,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: sel ? _C.primary : _C.border,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(p,
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            sel ? Colors.white : _C.textSec)),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList()),
                  ],
                ]),
              ),
              const SizedBox(height: 16),

              // ── Reason ───────────────────────
              const _FieldLabel('Reason *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reasonCtrl,
                maxLines: 3,
                maxLength: 200,
                style: const TextStyle(fontSize: 14, color: _C.textPrimary),
                decoration: _inputDeco('Reason for leave…'),
              ),
              const SizedBox(height: 12),

              // ── Reporting Manager ─────────────
              const _FieldLabel('Reporting Manager'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _showManagerSheet,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _C.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _C.border, width: 1.5),
                  ),
                  child: Row(children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: _manager.avatarColor, shape: BoxShape.circle),
                      child: Center(
                        child: Text(_manager.initials,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_manager.name,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _C.textPrimary)),
                        Text('${_manager.role} · ${_manager.department}',
                            style: const TextStyle(
                                fontSize: 11, color: _C.textSec)),
                      ],
                    )),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 20, color: _C.textSec),
                  ]),
                ),
              ),
              const SizedBox(height: 12),

              // ── Attachment ────────────────────
              GestureDetector(
                onTap: () => setState(() => _hasAttachment = !_hasAttachment),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _hasAttachment ? _C.successLight : _C.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _hasAttachment
                          ? _C.success.withValues(alpha: .4)
                          : _C.border,
                      width: _hasAttachment ? 1.5 : 1,
                    ),
                  ),
                  child: Row(children: [
                    Icon(
                      _hasAttachment
                          ? Icons.check_circle_outline_rounded
                          : Icons.attach_file_rounded,
                      size: 20,
                      color: _hasAttachment ? _C.successDark : _C.textSec,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _hasAttachment
                            ? 'medical_certificate.pdf attached'
                            : 'Attach supporting document (optional)',
                        style: TextStyle(
                            fontSize: 13,
                            color:
                                _hasAttachment ? _C.successDark : _C.textSec),
                      ),
                    ),
                    if (_hasAttachment)
                      GestureDetector(
                        onTap: () => setState(() => _hasAttachment = false),
                        child: const Icon(Icons.close_rounded,
                            size: 16, color: _C.textSec),
                      ),
                  ]),
                ),
              ),
              const SizedBox(height: 24),

              // ── Submit + Reset ────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _formValid ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.primary,
                    disabledBackgroundColor: _C.textDisabled,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_outlined, size: 17),
                            SizedBox(width: 8),
                            Text('Submit Request',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _submitting
                      ? null
                      : () => setState(() {
                            _leaveType = null;
                            _fromDate = null;
                            _toDate = null;
                            _isHalfDay = false;
                            _hasAttachment = false;
                            _reasonCtrl.clear();
                          }),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _C.textSec,
                    side: const BorderSide(color: _C.border, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Reset',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────
  // TAB 2: HISTORY
  // ─────────────────────────────────────────────
  Widget _buildHistoryTab() {
    List<_LeaveApplication> filtered;
    if (_activeFilter == 0) {
      filtered = _history;
    } else {
      final label = _filterLabels[_activeFilter].toLowerCase();
      filtered = _history.where((a) {
        switch (a.status) {
          case LeaveStatus.pending:
            return label == 'pending';
          case LeaveStatus.approved:
            return label == 'approved';
          case LeaveStatus.rejected:
            return label == 'rejected';
          case LeaveStatus.cancelled:
            return false;
        }
      }).toList();
    }

    return Column(children: [
      // Filter row
      Container(
        color: _C.card,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Row(children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_filterLabels.length, (i) {
                  final active = i == _activeFilter;
                  final label = _filterLabels[i];
                  final count = i == 0
                      ? _history.length
                      : _history
                          .where((a) => _statusMatch(a.status, label))
                          .length;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _activeFilter = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
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
                              color: active
                                  ? Colors.white.withValues(alpha: .25)
                                  : _C.border,
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
                }),
              ),
            ),
          ),
        ]),
      ),
      Container(height: 1, color: _C.border),

      // List
      Expanded(
        child: filtered.isEmpty
            ? _EmptyHistory(filterLabel: _filterLabels[_activeFilter])
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _HistoryCard(
                  app: filtered[i],
                  onToggle: () => setState(
                      () => filtered[i].expanded = !filtered[i].expanded),
                  onCancel: filtered[i].status == LeaveStatus.pending
                      ? () => _cancelLeave(filtered[i])
                      : null,
                ),
              ),
      ),
    ]);
  }

  bool _statusMatch(LeaveStatus s, String label) {
    switch (s) {
      case LeaveStatus.pending:
        return label == 'Pending';
      case LeaveStatus.approved:
        return label == 'Approved';
      case LeaveStatus.rejected:
        return label == 'Rejected';
      case LeaveStatus.cancelled:
        return false;
    }
  }

  // ── Policy sheet ──────────────────────────
  void _showLeavePolicy() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _LeavePolicySheet(),
    );
  }

  // ── Input decoration ──────────────────────
  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: _C.textTert),
        filled: true,
        fillColor: _C.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        counterStyle: const TextStyle(fontSize: 11, color: _C.textTert),
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
      );
}

// ─────────────────────────────────────────────
// BALANCE CARDS ROW
// ─────────────────────────────────────────────
class _BalanceCardsRow extends StatelessWidget {
  final List<_LeaveBalance> balances;
  final LeaveType? selected;
  final void Function(LeaveType) onSelect;

  const _BalanceCardsRow({
    required this.balances,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: balances.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final b = balances[i];
          final isSelected = selected == b.type;
          return GestureDetector(
            onTap: () => onSelect(b.type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 100,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? b.color : _C.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? b.color : _C.border,
                  width: isSelected ? 0 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: b.color.withValues(alpha: .3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(b.icon,
                          size: 16,
                          color: isSelected
                              ? Colors.white.withValues(alpha: .8)
                              : b.color),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? Colors.white.withValues(alpha: .2) : b.bg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('${b.used} used',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : b.color)),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${b.balance}',
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : b.color,
                              height: 1)),
                      Text('${b.label} days',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: .8)
                                  : b.color.withValues(alpha: .8))),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DATE FIELD
// ─────────────────────────────────────────────
class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final IconData icon;
  final bool enabled;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    required this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: enabled ? _C.surface : _C.surface.withValues(alpha: .5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value != null ? _C.primary.withValues(alpha: .5) : _C.border,
            width: value != null ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 10, color: _C.textSec)),
            const SizedBox(height: 2),
            Row(children: [
              Icon(icon,
                  size: 13,
                  color: value != null
                      ? _C.primary
                      : enabled
                          ? _C.textTert
                          : _C.textDisabled),
              const SizedBox(width: 5),
              Text(
                value != null ? _formatDateShort(value!) : 'Select',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        value != null ? FontWeight.w600 : FontWeight.w400,
                    color: value != null
                        ? _C.textPrimary
                        : enabled
                            ? _C.textTert
                            : _C.textDisabled),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HISTORY CARD
// ─────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  final _LeaveApplication app;
  final VoidCallback onToggle;
  final VoidCallback? onCancel;

  const _HistoryCard({
    required this.app,
    required this.onToggle,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final balance = _balanceFor(app.type);
    final statusMeta = _statusMeta(app.status);

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: app.expanded ? balance.color.withValues(alpha: .4) : _C.border,
            width: app.expanded ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: ID + status + chevron
                Row(children: [
                  Text(app.id,
                      style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: _C.textTert,
                          letterSpacing: 0.3)),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                        color: statusMeta.bg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: statusMeta.color.withValues(alpha: .3))),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(statusMeta.icon, size: 11, color: statusMeta.color),
                      const SizedBox(width: 4),
                      Text(statusMeta.label,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: statusMeta.color)),
                    ]),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: app.expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 18, color: _C.textTert),
                  ),
                ]),
                const SizedBox(height: 10),

                // Leave type chip + days
                Row(children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                        color: balance.bg,
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: balance.color.withValues(alpha: .3))),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(balance.icon, size: 12, color: balance.color),
                      const SizedBox(width: 4),
                      Text(balance.label,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: balance.color)),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(
                        color: _C.surface,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      '${app.days == app.days.roundToDouble() ? app.days.toInt() : app.days} day${app.days != 1 ? "s" : ""}',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _C.textPrimary),
                    ),
                  ),
                ]),
                const SizedBox(height: 8),

                // Date range
                Row(children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 12, color: _C.textSec),
                  const SizedBox(width: 5),
                  Text(
                    app.fromDate == app.toDate
                        ? _formatDate(app.fromDate)
                        : '${_formatDate(app.fromDate)} – ${_formatDate(app.toDate)}',
                    style: const TextStyle(fontSize: 12, color: _C.textSec),
                  ),
                  if (app.isHalfDay) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: _C.warningLight,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text('${app.halfDayPeriod} half',
                          style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: _C.warningDark)),
                    ),
                  ],
                ]),
                const SizedBox(height: 4),

                // Applied on + manager
                Row(children: [
                  const Icon(Icons.person_outline_rounded,
                      size: 12, color: _C.textTert),
                  const SizedBox(width: 4),
                  Text(app.managerName,
                      style: const TextStyle(fontSize: 11, color: _C.textTert)),
                  const SizedBox(width: 8),
                  const Icon(Icons.access_time_rounded,
                      size: 12, color: _C.textTert),
                  const SizedBox(width: 4),
                  Text('Applied: ${app.appliedOn}',
                      style: const TextStyle(fontSize: 11, color: _C.textTert)),
                ]),
              ],
            ),
          ),

          // Expanded detail
          if (app.expanded) ...[
            Container(
                height: 1,
                color: _C.border,
                margin: const EdgeInsets.symmetric(horizontal: 14)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reason
                  const Text('Reason',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _C.textSec)),
                  const SizedBox(height: 4),
                  Text(app.reason,
                      style: const TextStyle(
                          fontSize: 13, color: _C.textPrimary, height: 1.5)),

                  // Manager comment
                  if (app.managerComment != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusMeta.bg,
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: statusMeta.color.withValues(alpha: .2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(Icons.comment_outlined,
                                size: 13, color: statusMeta.color),
                            const SizedBox(width: 5),
                            Text('Manager Comment',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: statusMeta.color)),
                          ]),
                          const SizedBox(height: 6),
                          Text(app.managerComment!,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: _C.textPrimary,
                                  height: 1.5)),
                        ],
                      ),
                    ),
                  ],

                  // Cancel button (only for pending)
                  if (onCancel != null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _C.error,
                          side: const BorderSide(color: _C.error, width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Cancel Request',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MANAGER BOTTOM SHEET
// ─────────────────────────────────────────────
class _ManagerSheet extends StatelessWidget {
  final _Manager selected;
  final void Function(_Manager) onSelect;

  const _ManagerSheet({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
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
                    color: _C.border, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 18),
          const Text('Select Reporting Manager',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary)),
          const SizedBox(height: 4),
          const Text('Choose who should approve this leave',
              style: TextStyle(fontSize: 13, color: _C.textSec)),
          const SizedBox(height: 16),
          ..._managers.map((m) {
            final isSel = m.id == selected.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => onSelect(m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSel ? _C.primaryLight : _C.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSel ? _C.primary : _C.border,
                      width: isSel ? 1.5 : 1,
                    ),
                  ),
                  child: Row(children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                          color: m.avatarColor, shape: BoxShape.circle),
                      child: Center(
                        child: Text(m.initials,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.name,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _C.textPrimary)),
                        Text('${m.role} · ${m.department}',
                            style: const TextStyle(
                                fontSize: 11, color: _C.textSec)),
                      ],
                    )),
                    AnimatedOpacity(
                      opacity: isSel ? 1 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                            color: _C.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.check_rounded,
                            size: 13, color: Colors.white),
                      ),
                    ),
                  ]),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LEAVE POLICY SHEET
// ─────────────────────────────────────────────
class _LeavePolicySheet extends StatelessWidget {
  final _rules = const [
    (
      Icons.event_available_outlined,
      'Casual Leave',
      '15 days/year. Min 1 day. Apply 1 day in advance.'
    ),
    (
      Icons.local_hospital_outlined,
      'Sick Leave',
      '10 days/year. Medical certificate required for > 2 days.'
    ),
    (
      Icons.beach_access_outlined,
      'Earned Leave',
      '21 days/year. Apply 3 days in advance. Encashable.'
    ),
    (
      Icons.swap_horiz_rounded,
      'Comp Off',
      'Accrued for weekend/holiday work. Must use within 30 days.'
    ),
    (
      Icons.wb_twilight_outlined,
      'Half Day',
      'Available for any leave type. AM = before 1 PM, PM = after 1 PM.'
    ),
    (
      Icons.cancel_outlined,
      'Cancellation',
      'Pending leaves can be cancelled anytime. Approved leaves: 1 day prior.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      expand: false,
      builder: (_, ctrl) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: _C.border,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 18),
            Row(children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: _C.primaryLight,
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.policy_outlined,
                    size: 18, color: _C.primary),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Leave Policy',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _C.textPrimary)),
                  Text('ISF HR · FY 2026–27',
                      style: TextStyle(fontSize: 12, color: _C.textSec)),
                ],
              ),
            ]),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                controller: ctrl,
                children: _rules.map((r) {
                  final (icon, title, desc) = r;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _C.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                                color: _C.primaryLight,
                                borderRadius: BorderRadius.circular(10)),
                            child: Icon(icon, size: 18, color: _C.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: _C.textPrimary)),
                              const SizedBox(height: 3),
                              Text(desc,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: _C.textSec,
                                      height: 1.4)),
                            ],
                          )),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// EMPTY HISTORY
// ─────────────────────────────────────────────
class _EmptyHistory extends StatelessWidget {
  final String filterLabel;
  const _EmptyHistory({required this.filterLabel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: _C.primaryLight,
                  borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.event_available_outlined,
                  size: 36, color: _C.primary),
            ),
            const SizedBox(height: 16),
            Text(
              filterLabel == 'All'
                  ? 'No leave applications yet'
                  : 'No ${filterLabel.toLowerCase()} requests',
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              filterLabel == 'All'
                  ? 'Submit your first leave request from the Apply tab.'
                  : 'No ${filterLabel.toLowerCase()} leave requests found.',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 13, color: _C.textSec, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────
class _CardHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _CardHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Row(children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
                color: _C.primaryLight, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 16, color: _C.primary),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary)),
        ]),
      ),
      Container(height: 1, color: _C.border),
    ]);
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: _C.textPrimary));
}
