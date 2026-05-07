// ============================================================
// ISF HR Portal — Regularize Screen
// File: lib/screens/attendance/regularize_screen.dart
//
// Features:
//   - Pending regularizations alert banner
//   - New Regularization form:
//       • Date picker (past dates only, no future)
//       • Regularization type chip selector (5 types)
//       • Correct In Time / Out Time pickers (conditional)
//       • Work location dropdown
//       • Reason text field (required, min 10 chars)
//       • Optional file attachment
//       • Validation + animated submit
//   - Regularization history list
//       • Filter chips (All / Pending / Approved / Rejected)
//       • Expandable cards with approver comment
//       • Cancel pending option
//
// Dependencies: none beyond flutter/material
// ============================================================

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// INLINE THEME
// ─────────────────────────────────────────────
class _C {
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
// ENUMS & MODELS
// ─────────────────────────────────────────────
enum _RegType {
  missingPunchIn,
  missingPunchOut,
  wrongTime,
  wrongLocation,
  bothMissing,
}

enum _RegStatus { pending, approved, rejected }

enum _WorkLocation { office, wfh, field, clientSite }

class _RegRequest {
  final String id;
  final DateTime date;
  final _RegType type;
  final String? correctInTime;
  final String? correctOutTime;
  final _WorkLocation location;
  final String reason;
  final _RegStatus status;
  final String appliedOn;
  final String? approverComment;
  bool expanded = false;

  _RegRequest({
    required this.id,
    required this.date,
    required this.type,
    this.correctInTime,
    this.correctOutTime,
    required this.location,
    required this.reason,
    required this.status,
    required this.appliedOn,
    this.approverComment,
  });
}

// ─────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────
final _mockHistory = [
  _RegRequest(
    id: 'REG-2026-019',
    date: DateTime(2026, 4, 21),
    type: _RegType.missingPunchOut,
    correctOutTime: '06:00 PM',
    location: _WorkLocation.office,
    reason:
        'Forgot to punch out due to an urgent production issue that required immediate attention.',
    status: _RegStatus.approved,
    appliedOn: '22 Apr 2026',
    approverComment: 'Verified with CCTV logs. Approved.',
  ),
  _RegRequest(
    id: 'REG-2026-014',
    date: DateTime(2026, 4, 15),
    type: _RegType.wrongTime,
    correctInTime: '09:05 AM',
    correctOutTime: '06:10 PM',
    location: _WorkLocation.office,
    reason:
        'Biometric device was malfunctioning on this day. Recorded wrong punch time.',
    status: _RegStatus.pending,
    appliedOn: '16 Apr 2026',
  ),
  _RegRequest(
    id: 'REG-2026-008',
    date: DateTime(2026, 4, 8),
    type: _RegType.missingPunchIn,
    correctInTime: '09:00 AM',
    location: _WorkLocation.office,
    reason:
        'Was unaware that the biometric machine was offline. Raised ticket with IT.',
    status: _RegStatus.rejected,
    appliedOn: '09 Apr 2026',
    approverComment:
        'No supporting evidence. Please coordinate with IT for confirmation.',
  ),
  _RegRequest(
    id: 'REG-2026-003',
    date: DateTime(2026, 3, 25),
    type: _RegType.wrongLocation,
    location: _WorkLocation.clientSite,
    reason:
        'Was working from client site in Pune but location showed Mumbai office.',
    status: _RegStatus.approved,
    appliedOn: '26 Mar 2026',
    approverComment: 'Client visit confirmed via email. Approved.',
  ),
  _RegRequest(
    id: 'REG-2026-001',
    date: DateTime(2026, 3, 10),
    type: _RegType.bothMissing,
    correctInTime: '09:00 AM',
    correctOutTime: '06:00 PM',
    location: _WorkLocation.wfh,
    reason:
        'VPN was down throughout the day. Could not register punches via remote system.',
    status: _RegStatus.approved,
    appliedOn: '11 Mar 2026',
    approverComment: 'VPN issue confirmed with IT logs. Approved.',
  ),
];

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────
({
  String label,
  String shortLabel,
  IconData icon,
  Color color,
  Color bg,
  bool needsIn,
  bool needsOut
}) _regTypeMeta(_RegType t) {
  switch (t) {
    case _RegType.missingPunchIn:
      return (
        label: 'Missing Punch In',
        shortLabel: 'No Punch In',
        icon: Icons.login_outlined,
        color: _C.error,
        bg: _C.errorLight,
        needsIn: true,
        needsOut: false,
      );
    case _RegType.missingPunchOut:
      return (
        label: 'Missing Punch Out',
        shortLabel: 'No Punch Out',
        icon: Icons.logout_outlined,
        color: _C.orange,
        bg: _C.orangeLight,
        needsIn: false,
        needsOut: true,
      );
    case _RegType.wrongTime:
      return (
        label: 'Wrong Punch Time',
        shortLabel: 'Wrong Time',
        icon: Icons.access_time_rounded,
        color: _C.warningDark,
        bg: _C.warningLight,
        needsIn: true,
        needsOut: true,
      );
    case _RegType.wrongLocation:
      return (
        label: 'Wrong Location',
        shortLabel: 'Wrong Location',
        icon: Icons.location_off_outlined,
        color: _C.purple,
        bg: _C.purpleLight,
        needsIn: false,
        needsOut: false,
      );
    case _RegType.bothMissing:
      return (
        label: 'Both Punches Missing',
        shortLabel: 'Both Missing',
        icon: Icons.sync_problem_outlined,
        color: _C.errorDark,
        bg: _C.errorLight,
        needsIn: true,
        needsOut: true,
      );
  }
}

({String label, Color color, Color bg, IconData icon}) _statusMeta(
    _RegStatus s) {
  switch (s) {
    case _RegStatus.pending:
      return (
        label: 'Pending',
        color: _C.warningDark,
        bg: _C.warningLight,
        icon: Icons.hourglass_top_rounded
      );
    case _RegStatus.approved:
      return (
        label: 'Approved',
        color: _C.successDark,
        bg: _C.successLight,
        icon: Icons.check_circle_outline_rounded
      );
    case _RegStatus.rejected:
      return (
        label: 'Rejected',
        color: _C.errorDark,
        bg: _C.errorLight,
        icon: Icons.cancel_outlined
      );
  }
}

({String label, IconData icon}) _locationMeta(_WorkLocation l) {
  switch (l) {
    case _WorkLocation.office:
      return (label: 'Office', icon: Icons.business_outlined);
    case _WorkLocation.wfh:
      return (label: 'WFH', icon: Icons.home_outlined);
    case _WorkLocation.field:
      return (label: 'Field', icon: Icons.terrain_outlined);
    case _WorkLocation.clientSite:
      return (label: 'Client Site', icon: Icons.work_outline_rounded);
  }
}

String _fmtDate(DateTime d) {
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
  const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return '${days[d.weekday]}, ${d.day} ${months[d.month]} ${d.year}';
}

String _fmtDateShort(DateTime d) {
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

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class RegularizeScreen extends StatefulWidget {
  const RegularizeScreen({super.key});

  @override
  State<RegularizeScreen> createState() => _RegularizeScreenState();
}

class _RegularizeScreenState extends State<RegularizeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  // ── Form state ──────────────────────────────
  final _formKey = GlobalKey<FormState>();
  DateTime? _selDate;
  _RegType? _selType;
  TimeOfDay? _inTime;
  TimeOfDay? _outTime;
  _WorkLocation _location = _WorkLocation.office;
  final _reasonCtrl = TextEditingController();
  bool _hasDoc = false;
  bool _submitting = false;

  // ── History state ───────────────────────────
  _RegStatus? _filterStatus;
  final List<_RegRequest> _history = List.from(_mockHistory);

  int get _pendingCount =>
      _history.where((r) => r.status == _RegStatus.pending).length;

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

  // ── Date picker ──────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selDate ?? DateTime.now().subtract(const Duration(days: 1)),
      firstDate: DateTime.now().subtract(const Duration(days: 60)),
      lastDate: DateTime.now().subtract(const Duration(days: 1)),
      helpText: 'Select affected date',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _C.accent,
            onPrimary: Colors.white,
            surface: _C.card,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selDate = picked);
  }

  // ── Time pickers ─────────────────────────────
  Future<void> _pickInTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _inTime ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
              primary: _C.accent, onPrimary: Colors.white, surface: _C.card),
        ),
        child: child!,
      ),
    );
    if (t != null) setState(() => _inTime = t);
  }

  Future<void> _pickOutTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _outTime ?? const TimeOfDay(hour: 18, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
              primary: _C.accent, onPrimary: Colors.white, surface: _C.card),
        ),
        child: child!,
      ),
    );
    if (t != null) setState(() => _outTime = t);
  }

  String _fmtTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  // ── Submit ───────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selDate == null) {
      _snack('Please select the affected date', _C.error);
      return;
    }
    if (_selType == null) {
      _snack('Please select regularization type', _C.error);
      return;
    }

    final meta = _regTypeMeta(_selType!);
    if (meta.needsIn && _inTime == null) {
      _snack('Please set the correct In Time', _C.error);
      return;
    }
    if (meta.needsOut && _outTime == null) {
      _snack('Please set the correct Out Time', _C.error);
      return;
    }

    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final newReq = _RegRequest(
      id: 'REG-2026-0${30 + _history.length}',
      date: _selDate!,
      type: _selType!,
      correctInTime: _inTime != null ? _fmtTime(_inTime!) : null,
      correctOutTime: _outTime != null ? _fmtTime(_outTime!) : null,
      location: _location,
      reason: _reasonCtrl.text.trim(),
      status: _RegStatus.pending,
      appliedOn: _fmtDateShort(DateTime.now()),
    );

    setState(() {
      _submitting = false;
      _history.insert(0, newReq);
      _selDate = null;
      _selType = null;
      _inTime = null;
      _outTime = null;
      _location = _WorkLocation.office;
      _hasDoc = false;
      _reasonCtrl.clear();
      _tabCtrl.animateTo(1);
    });

    _snack('Regularization request submitted ✅', _C.successDark);
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
      duration: const Duration(seconds: 3),
    ));
  }

  void _cancelRequest(_RegRequest req) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Request?',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        content: Text('Cancel regularization request ${req.id}?',
            style: const TextStyle(fontSize: 14, color: _C.textSec)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Keep', style: TextStyle(color: _C.textSec))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _history.removeWhere((r) => r.id == req.id));
              _snack('Request ${req.id} cancelled', _C.textSec);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Cancel'),
          ),
        ],
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
              _buildFormTab(),
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
        title: const Text('Regularize',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        actions: [
          if (_pendingCount > 0)
            Container(
              margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _C.warningLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.hourglass_top_rounded,
                    size: 12, color: _C.warningDark),
                const SizedBox(width: 4),
                Text('$_pendingCount Pending',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _C.warningDark)),
              ]),
            ),
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
          tabs: const [
            Tab(text: 'New Request'),
            Tab(text: 'History'),
          ],
          labelColor: _C.accent,
          unselectedLabelColor: _C.textSec,
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          indicatorColor: _C.accent,
          indicatorWeight: 2.5,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: _C.border,
        ),
      );

  // ─────────────────────────────────────────────
  // TAB 1: FORM
  // ─────────────────────────────────────────────
  Widget _buildFormTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
      children: [
        // Pending banner
        if (_pendingCount > 0) ...[
          _PendingBanner(
              count: _pendingCount, onView: () => _tabCtrl.animateTo(1)),
          const SizedBox(height: 14),
        ],

        // Policy info
        const _InfoBanner(
          'Regularization must be submitted within 3 days of the missed punch. '
          'Supporting evidence (email/CCTV confirmation) speeds up approval.',
          Icons.info_outline_rounded,
          _C.accent,
          _C.accentLight,
        ),
        const SizedBox(height: 16),

        // Form card
        _buildFormCard(),
      ],
    );
  }

  Widget _buildFormCard() {
    final typeMeta = _selType != null ? _regTypeMeta(_selType!) : null;
    final needsIn = typeMeta?.needsIn ?? false;
    final needsOut = typeMeta?.needsOut ?? false;

    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Column(children: [
        const _CardHdr('Request Regularization', Icons.edit_calendar_outlined,
            _C.accent, _C.accentLight),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Date picker ───────────────────
                const _FieldLabel('Date *'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: _C.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selDate != null
                            ? _C.accent.withValues(alpha: .5)
                            : _C.border,
                        width: _selDate != null ? 1.5 : 1,
                      ),
                    ),
                    child: Row(children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                            color: _C.accentLight,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.calendar_today_outlined,
                            size: 16, color: _C.accent),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selDate != null
                              ? _fmtDate(_selDate!)
                              : 'Select affected date (past only)',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: _selDate != null
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                              color: _selDate != null
                                  ? _C.textPrimary
                                  : _C.textTert),
                        ),
                      ),
                      const Icon(Icons.edit_outlined,
                          size: 15, color: _C.textTert),
                    ]),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Regularization type ────────────
                const _FieldLabel('Regularization Type *'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _RegType.values.map((t) {
                    final m = _regTypeMeta(t);
                    final active = _selType == t;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selType = t;
                        // Reset times when type changes
                        if (!m.needsIn) _inTime = null;
                        if (!m.needsOut) _outTime = null;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 9),
                        decoration: BoxDecoration(
                          color: active ? m.color : _C.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: active ? m.color : _C.border,
                            width: 1.5,
                          ),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(m.icon,
                              size: 13,
                              color: active ? Colors.white : _C.textSec),
                          const SizedBox(width: 6),
                          Text(m.shortLabel,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: active ? Colors.white : _C.textSec)),
                        ]),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // ── Time pickers (conditional) ─────
                if (needsIn || needsOut) ...[
                  _FieldLabel(
                    needsIn && needsOut
                        ? 'Correct In & Out Time *'
                        : needsIn
                            ? 'Correct In Time *'
                            : 'Correct Out Time *',
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    if (needsIn) ...[
                      Expanded(
                          child: _TimeField(
                        label: 'In Time',
                        time: _inTime,
                        onTap: _pickInTime,
                        color: _C.successDark,
                        icon: Icons.login_outlined,
                      )),
                    ],
                    if (needsIn && needsOut) const SizedBox(width: 10),
                    if (needsOut) ...[
                      Expanded(
                          child: _TimeField(
                        label: 'Out Time',
                        time: _outTime,
                        onTap: _pickOutTime,
                        color: _C.error,
                        icon: Icons.logout_outlined,
                      )),
                    ],
                  ]),
                  const SizedBox(height: 16),
                ],

                // ── Work location ──────────────────
                const _FieldLabel('Work Location'),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: _C.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _C.border, width: 1.5),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<_WorkLocation>(
                      value: _location,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 20, color: _C.textSec),
                      style: const TextStyle(
                          fontSize: 14,
                          color: _C.textPrimary,
                          fontWeight: FontWeight.w500),
                      onChanged: (v) {
                        if (v != null) setState(() => _location = v);
                      },
                      items: _WorkLocation.values.map((l) {
                        final m = _locationMeta(l);
                        return DropdownMenuItem(
                          value: l,
                          child: Row(children: [
                            Icon(m.icon, size: 17, color: _C.textSec),
                            const SizedBox(width: 10),
                            Text(m.label),
                          ]),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Reason ────────────────────────
                const _FieldLabel('Reason *'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _reasonCtrl,
                  maxLines: 4,
                  maxLength: 300,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Reason is required';
                    }
                    if (v.trim().length < 10) return 'Min 10 characters';
                    return null;
                  },
                  style: const TextStyle(fontSize: 13, color: _C.textPrimary),
                  decoration: _inputDeco(
                      'Explain why the punch is missing/incorrect. Include supporting details…'),
                ),
                const SizedBox(height: 12),

                // ── Supporting doc ─────────────────
                GestureDetector(
                  onTap: () => setState(() => _hasDoc = !_hasDoc),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: _hasDoc ? _C.successLight : _C.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _hasDoc ? _C.success.withValues(alpha: .4) : _C.border,
                        width: _hasDoc ? 1.5 : 1,
                      ),
                    ),
                    child: Row(children: [
                      Icon(
                        _hasDoc
                            ? Icons.check_circle_outline_rounded
                            : Icons.attach_file_rounded,
                        size: 20,
                        color: _hasDoc ? _C.successDark : _C.textSec,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _hasDoc
                                  ? 'it_confirmation_email.pdf'
                                  : 'Attach Supporting Document',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: _hasDoc
                                      ? _C.successDark
                                      : _C.textPrimary),
                            ),
                            Text(
                              _hasDoc
                                  ? 'Tap to remove'
                                  : 'Email screenshot, IT ticket, CCTV confirmation (optional)',
                              style: const TextStyle(
                                  fontSize: 11, color: _C.textSec),
                            ),
                          ],
                        ),
                      ),
                      if (_hasDoc)
                        GestureDetector(
                          onTap: () => setState(() => _hasDoc = false),
                          child: const Icon(Icons.close_rounded,
                              size: 16, color: _C.textSec),
                        ),
                    ]),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Submit ────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _C.accent,
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
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton(
                    onPressed: _submitting
                        ? null
                        : () => setState(() {
                              _selDate = null;
                              _selType = null;
                              _inTime = null;
                              _outTime = null;
                              _hasDoc = false;
                              _location = _WorkLocation.office;
                              _reasonCtrl.clear();
                            }),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _C.textSec,
                      side: const BorderSide(color: _C.border, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Reset',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────
  // TAB 2: HISTORY
  // ─────────────────────────────────────────────
  Widget _buildHistoryTab() {
    final filtered = _filterStatus == null
        ? _history
        : _history.where((r) => r.status == _filterStatus).toList();

    return Column(children: [
      // Filter row
      Container(
        color: _C.card,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _FChip('All', _filterStatus == null, _history.length,
                () => setState(() => _filterStatus = null)),
            ..._RegStatus.values.map((s) {
              final m = _statusMeta(s);
              final cnt = _history.where((r) => r.status == s).length;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _FChip(
                  m.label,
                  _filterStatus == s,
                  cnt,
                  () => setState(
                      () => _filterStatus = _filterStatus == s ? null : s),
                  color: m.color,
                  bg: m.bg,
                ),
              );
            }),
          ]),
        ),
      ),
      Container(height: 1, color: _C.border),

      // Stats row (when showing All)
      if (_filterStatus == null) _buildStatsRow(),

      // List
      Expanded(
        child: filtered.isEmpty
            ? _EmptyState(
                label: _filterStatus == null
                    ? 'No regularization requests yet'
                    : 'No ${_statusMeta(_filterStatus!).label.toLowerCase()} requests')
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 48),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _RegCard(
                  request: filtered[i],
                  onToggle: () => setState(
                      () => filtered[i].expanded = !filtered[i].expanded),
                  onCancel: filtered[i].status == _RegStatus.pending
                      ? () => _cancelRequest(filtered[i])
                      : null,
                ),
              ),
      ),
    ]);
  }

  Widget _buildStatsRow() {
    final approved =
        _history.where((r) => r.status == _RegStatus.approved).length;
    final pending =
        _history.where((r) => r.status == _RegStatus.pending).length;
    final rejected =
        _history.where((r) => r.status == _RegStatus.rejected).length;

    return Container(
      color: _C.card,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(children: [
        _statPill('$approved Approved', _C.successDark, _C.successLight),
        const SizedBox(width: 8),
        _statPill('$pending Pending', _C.warningDark, _C.warningLight),
        const SizedBox(width: 8),
        _statPill('$rejected Rejected', _C.errorDark, _C.errorLight),
      ]),
    );
  }

  Widget _statPill(String label, Color color, Color bg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      );

  // ── Shared helpers ─────────────────────────
  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: _C.textTert),
        filled: true,
        fillColor: _C.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        counterStyle: const TextStyle(fontSize: 10, color: _C.textTert),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _C.border, width: 1.5)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _C.border, width: 1.5)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _C.accent, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _C.error, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _C.error, width: 1.5)),
        errorStyle: const TextStyle(fontSize: 11, color: _C.error),
      );
}

// ─────────────────────────────────────────────
// TIME FIELD WIDGET
// ─────────────────────────────────────────────
class _TimeField extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;
  final Color color;
  final IconData icon;

  const _TimeField({
    required this.label,
    required this.time,
    required this.onTap,
    required this.color,
    required this.icon,
  });

  String _fmt(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: time != null ? color.withValues(alpha: .06) : _C.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: time != null ? color.withValues(alpha: .5) : _C.border,
            width: time != null ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: time != null ? color : _C.textSec)),
            const SizedBox(height: 3),
            Row(children: [
              Icon(icon, size: 14, color: time != null ? color : _C.textTert),
              const SizedBox(width: 6),
              Text(
                time != null ? _fmt(time!) : 'Tap to set',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        time != null ? FontWeight.w700 : FontWeight.w400,
                    color: time != null ? _C.textPrimary : _C.textTert),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REGULARIZE CARD (history)
// ─────────────────────────────────────────────
class _RegCard extends StatelessWidget {
  final _RegRequest request;
  final VoidCallback onToggle;
  final VoidCallback? onCancel;

  const _RegCard({
    required this.request,
    required this.onToggle,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final typeMeta = _regTypeMeta(request.type);
    final statusMeta = _statusMeta(request.status);
    final locMeta = _locationMeta(request.location);

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                request.expanded ? typeMeta.color.withValues(alpha: .35) : _C.border,
            width: request.expanded ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: .04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: ID + status
                Row(children: [
                  Text(request.id,
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
                      Icon(statusMeta.icon, size: 10, color: statusMeta.color),
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
                    turns: request.expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 18, color: _C.textTert),
                  ),
                ]),
                const SizedBox(height: 10),

                // Date
                Row(children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 13, color: _C.textSec),
                  const SizedBox(width: 5),
                  Text(_fmtDate(request.date),
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _C.textPrimary)),
                ]),
                const SizedBox(height: 8),

                // Type chip + location chip
                Row(children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                        color: typeMeta.bg,
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: typeMeta.color.withValues(alpha: .3))),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(typeMeta.icon, size: 11, color: typeMeta.color),
                      const SizedBox(width: 5),
                      Text(typeMeta.shortLabel,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: typeMeta.color)),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: _C.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _C.border)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(locMeta.icon, size: 10, color: _C.textSec),
                      const SizedBox(width: 4),
                      Text(locMeta.label,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _C.textSec)),
                    ]),
                  ),
                ]),
                const SizedBox(height: 6),

                // Time corrections (if any)
                if (request.correctInTime != null ||
                    request.correctOutTime != null)
                  Row(children: [
                    if (request.correctInTime != null) ...[
                      const Icon(Icons.login_outlined,
                          size: 12, color: _C.successDark),
                      const SizedBox(width: 3),
                      Text(request.correctInTime!,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _C.successDark)),
                    ],
                    if (request.correctInTime != null &&
                        request.correctOutTime != null) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(Icons.arrow_forward_rounded,
                            size: 11, color: _C.textTert),
                      ),
                    ],
                    if (request.correctOutTime != null) ...[
                      const Icon(Icons.logout_outlined,
                          size: 12, color: _C.error),
                      const SizedBox(width: 3),
                      Text(request.correctOutTime!,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _C.error)),
                    ],
                    const Spacer(),
                    Text('Applied: ${request.appliedOn}',
                        style:
                            const TextStyle(fontSize: 10, color: _C.textTert)),
                  ]),
              ],
            ),
          ),

          // ── Expanded detail ────────────────
          if (request.expanded) ...[
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
                  Text(request.reason,
                      style: const TextStyle(
                          fontSize: 13, color: _C.textPrimary, height: 1.5)),

                  // Approver comment
                  if (request.approverComment != null) ...[
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
                            Text('Approver Comment',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: statusMeta.color)),
                          ]),
                          const SizedBox(height: 5),
                          Text(request.approverComment!,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: _C.textPrimary,
                                  height: 1.4)),
                        ],
                      ),
                    ),
                  ],

                  // Cancel button
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
// SMALL SHARED WIDGETS
// ─────────────────────────────────────────────
class _PendingBanner extends StatelessWidget {
  final int count;
  final VoidCallback onView;
  const _PendingBanner({required this.count, required this.onView});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: _C.warningLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.warning.withValues(alpha: .3)),
        ),
        child: Row(children: [
          const Icon(Icons.hourglass_top_rounded,
              size: 16, color: _C.warningDark),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'You have $count pending regularization${count != 1 ? "s" : ""} awaiting approval.',
              style: const TextStyle(
                  fontSize: 12, color: _C.warningDark, height: 1.4),
            ),
          ),
          GestureDetector(
            onTap: onView,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: _C.warningDark,
                  borderRadius: BorderRadius.circular(20)),
              child: const Text('View',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ]),
      );
}

class _InfoBanner extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color, bg;
  const _InfoBanner(this.message, this.icon, this.color, this.bg);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: .3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message,
                  style: TextStyle(fontSize: 11, color: color, height: 1.4)),
            ),
          ],
        ),
      );
}

class _CardHdr extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color, bg;
  const _CardHdr(this.title, this.icon, this.color, this.bg);

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 16, color: color),
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

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: _C.textPrimary));
}

class _FChip extends StatelessWidget {
  final String label;
  final bool active;
  final int count;
  final VoidCallback onTap;
  final Color? color, bg;
  const _FChip(this.label, this.active, this.count, this.onTap,
      {this.color, this.bg});

  @override
  Widget build(BuildContext context) {
    final ac = color ?? _C.accent;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? ac : _C.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? ac : _C.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : _C.textSec)),
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: active ? Colors.white.withValues(alpha: .25) : _C.border,
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
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String label;
  const _EmptyState({required this.label});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    color: _C.accentLight,
                    borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.edit_calendar_outlined,
                    size: 36, color: _C.accent),
              ),
              const SizedBox(height: 16),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary)),
              const SizedBox(height: 6),
              const Text('Your regularization requests will appear here.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 13, color: _C.textSec, height: 1.5)),
            ],
          ),
        ),
      );
}
