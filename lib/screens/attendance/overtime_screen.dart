// ============================================================
// ISF HR Portal — Overtime Screen
// File: lib/screens/attendance/overtime_screen.dart
//
// Features:
//   - Monthly OT summary gradient hero card with animated ring
//   - Apply OT collapsible form (date, from/to time, duration, reason)
//   - OT log list with status chips + expandable detail sheet
//   - Compensation toggle (Comp Off vs Cash Payout) with calculation
//   - Claim compensation button with confirmation dialog
//   - Custom time picker rows
//
// Dependencies: none beyond flutter/material
// ============================================================

import 'package:flutter/material.dart';
import 'dart:math' as math;

// ─────────────────────────────────────────────
// INLINE THEME
// ─────────────────────────────────────────────
class _C {
  static const primary = Color(0xFF2563EB);
  static const primaryLight = Color(0xFFEFF6FF);
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
  static const orangeDark = Color(0xFFC2410C);
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
enum _OTStatus { approved, pending, rejected }

enum _OTReason {
  projectDeadline,
  clientRequest,
  dataMigration,
  systemMaintenance,
  other
}

enum _CompType { compOff, cash }

class _OTEntry {
  final String id;
  final DateTime date;
  final String inTime;
  final String outTime;
  final double otHours; // fractional hours e.g. 1.75
  final _OTStatus status;
  final String? approver;
  final String? notes;
  final _OTReason reason;
  bool expanded;

  _OTEntry({
    required this.id,
    required this.date,
    required this.inTime,
    required this.outTime,
    required this.otHours,
    required this.status,
    this.approver,
    this.notes,
    required this.reason,
  }) : expanded = false;
}

// ─────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────
final _mockOTLog = [
  _OTEntry(
    id: 'OT-2026-019',
    date: DateTime(2026, 4, 23),
    inTime: '09:00 AM',
    outTime: '08:30 PM',
    otHours: 2.5,
    status: _OTStatus.approved,
    approver: 'Priya Mehta',
    reason: _OTReason.projectDeadline,
    notes: 'Sprint release preparation. Final QA and deployment.',
  ),
  _OTEntry(
    id: 'OT-2026-016',
    date: DateTime(2026, 4, 17),
    inTime: '09:00 AM',
    outTime: '07:45 PM',
    otHours: 1.75,
    status: _OTStatus.approved,
    approver: 'Priya Mehta',
    reason: _OTReason.clientRequest,
    notes: 'Client demo preparation for international timezone.',
  ),
  _OTEntry(
    id: 'OT-2026-011',
    date: DateTime(2026, 4, 3),
    inTime: '09:00 AM',
    outTime: '08:00 PM',
    otHours: 2.0,
    status: _OTStatus.approved,
    approver: 'Priya Mehta',
    reason: _OTReason.dataMigration,
    notes: 'Production DB migration during low-traffic window.',
  ),
  _OTEntry(
    id: 'OT-2026-024',
    date: DateTime(2026, 4, 28),
    inTime: '09:00 AM',
    outTime: '07:15 PM',
    otHours: 1.25,
    status: _OTStatus.pending,
    reason: _OTReason.projectDeadline,
    notes: 'Module delivery deadline.',
  ),
  _OTEntry(
    id: 'OT-2026-008',
    date: DateTime(2026, 3, 20),
    inTime: '09:00 AM',
    outTime: '07:00 PM',
    otHours: 1.0,
    status: _OTStatus.rejected,
    reason: _OTReason.other,
    notes: 'Exceeded approved OT hours quota for the week.',
  ),
];

const _reasons = [
  (label: 'Project Deadline', value: _OTReason.projectDeadline),
  (label: 'Client Request', value: _OTReason.clientRequest),
  (label: 'Data Migration', value: _OTReason.dataMigration),
  (label: 'System Maintenance', value: _OTReason.systemMaintenance),
  (label: 'Other', value: _OTReason.other),
];

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────
String _fmtHours(double h) {
  final hrs = h.floor();
  final mins = ((h - hrs) * 60).round();
  return '${hrs}h ${mins.toString().padLeft(2, '0')}m';
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
  return '${days[d.weekday]} ${d.day} ${months[d.month]} ${d.year}';
}

String _reasonLabel(_OTReason r) =>
    _reasons.firstWhere((x) => x.value == r).label;

({String label, Color color, Color bg, IconData icon}) _statusMeta(
    _OTStatus s) {
  switch (s) {
    case _OTStatus.approved:
      return (
        label: 'Approved',
        color: _C.successDark,
        bg: _C.successLight,
        icon: Icons.check_circle_outline_rounded
      );
    case _OTStatus.pending:
      return (
        label: 'Pending',
        color: _C.warningDark,
        bg: _C.warningLight,
        icon: Icons.hourglass_top_rounded
      );
    case _OTStatus.rejected:
      return (
        label: 'Rejected',
        color: _C.errorDark,
        bg: _C.errorLight,
        icon: Icons.cancel_outlined
      );
  }
}

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class OvertimeScreen extends StatefulWidget {
  const OvertimeScreen({super.key});

  @override
  State<OvertimeScreen> createState() => _OvertimeScreenState();
}

class _OvertimeScreenState extends State<OvertimeScreen>
    with TickerProviderStateMixin {
  // ── Animation ─────────────────────────────
  late final AnimationController _ringCtrl;
  late final Animation<double> _ringAnim;

  // ── OT Log ────────────────────────────────
  final List<_OTEntry> _log = List.from(_mockOTLog);

  // ── Apply form ────────────────────────────
  bool _formOpen = false;
  DateTime? _otDate;
  TimeOfDay _fromTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _toTime = const TimeOfDay(hour: 20, minute: 0);
  _OTReason? _otReason;
  final _notesCtrl = TextEditingController();
  bool _submitting = false;

  // ── Compensation ──────────────────────────
  _CompType _compType = _CompType.compOff;

  // ── Filter ────────────────────────────────
  _OTStatus? _filterStatus; // null = All

  // ── Computed OT totals ────────────────────
  double get _approvedHours => _log
      .where((e) => e.status == _OTStatus.approved)
      .fold(0.0, (s, e) => s + e.otHours);
  double get _pendingHours => _log
      .where((e) => e.status == _OTStatus.pending)
      .fold(0.0, (s, e) => s + e.otHours);
  double get _totalHours => _approvedHours + _pendingHours;

  // Cash rate: ₹5,700/day ÷ 9h = ₹633/h (rounded to 633)
  static const _ratePerHour = 633.0;
  double get _cashValue => _approvedHours * _ratePerHour;
  double get _compOffDays => _approvedHours / 9.0;

  // ── Duration calc ─────────────────────────
  double get _otDuration {
    if (_otDate == null) return 0;
    const std = 9.0; // standard hours
    final from = _fromTime.hour + _fromTime.minute / 60.0;
    final to = _toTime.hour + _toTime.minute / 60.0;
    final total = to - from;
    return math.max(0, total - std);
  }

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _ringAnim = CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _ringCtrl.forward();
    });
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Submit OT ─────────────────────────────
  Future<void> _submitOT() async {
    if (_otDate == null || _otReason == null) {
      _snack('Please select date and reason', _C.error);
      return;
    }
    if (_otDuration <= 0) {
      _snack('To time must be after standard shift end (6 PM)', _C.error);
      return;
    }
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 1300));
    if (!mounted) return;

    String fmt(TimeOfDay t) =>
        '${t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod}:${t.minute.toString().padLeft(2, '0')} ${t.period == DayPeriod.am ? 'AM' : 'PM'}';

    setState(() {
      _log.insert(
          0,
          _OTEntry(
            id: 'OT-2026-0${30 + _log.length}',
            date: _otDate!,
            inTime: '09:00 AM',
            outTime: fmt(_toTime),
            otHours: _otDuration,
            status: _OTStatus.pending,
            reason: _otReason!,
            notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
          ));
      _submitting = false;
      _formOpen = false;
      _otDate = null;
      _otReason = null;
      _notesCtrl.clear();
      _fromTime = const TimeOfDay(hour: 18, minute: 0);
      _toTime = const TimeOfDay(hour: 20, minute: 0);
    });

    _snack('OT request submitted ✅', _C.successDark);
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

  Future<TimeOfDay?> _pickTime(TimeOfDay initial) async {
    return showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _C.orange,
            onPrimary: Colors.white,
            surface: _C.card,
          ),
        ),
        child: child!,
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _otDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _C.orange,
            onPrimary: Colors.white,
            surface: _C.card,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _otDate = picked);
  }

  void _showClaimDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          _compType == _CompType.compOff
              ? 'Claim Compensatory Off'
              : 'Claim Cash Payout',
          style: const TextStyle(
              fontSize: 17, fontWeight: FontWeight.w600, color: _C.textPrimary),
        ),
        content: Text(
          _compType == _CompType.compOff
              ? 'Claim ${_compOffDays.toStringAsFixed(1)} comp-off days for ${_fmtHours(_approvedHours)} of overtime?'
              : 'Claim ₹${_cashValue.toStringAsFixed(0)} cash payout for ${_fmtHours(_approvedHours)} of overtime?',
          style: const TextStyle(fontSize: 14, color: _C.textSec),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: _C.textSec)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _snack('Compensation claim submitted ✅', _C.successDark);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.orange,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Confirm'),
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
    final filtered = _filterStatus == null
        ? _log
        : _log.where((e) => e.status == _filterStatus).toList();

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 16),
          _buildApplyCard(),
          const SizedBox(height: 16),
          _buildOTLog(filtered),
          const SizedBox(height: 16),
          _buildCompensationCard(),
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
        title: const Text('Overtime',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        actions: [
          // Month badge
          Container(
            margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _C.orangeLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Apr 2026',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _C.orange)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _C.border),
        ),
      );

  // ─────────────────────────────────────────────
  // SUMMARY HERO CARD
  // ─────────────────────────────────────────────
  Widget _buildSummaryCard() {
    const maxHours = 20.0; // max scale for ring
    final ringPct = (_approvedHours / maxHours).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFC2410C), Color(0xFFEA580C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        // Ring
        AnimatedBuilder(
          animation: _ringAnim,
          builder: (_, __) => SizedBox(
            width: 100,
            height: 100,
            child: Stack(alignment: Alignment.center, children: [
              CustomPaint(
                size: const Size(100, 100),
                painter: _RingPainter(
                  progress: ringPct * _ringAnim.value,
                  trackColor: Colors.white.withValues(alpha: .2),
                  fillColor: Colors.white,
                  strokeWidth: 9,
                ),
              ),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text(_fmtHours(_approvedHours * _ringAnim.value).split(' ')[0],
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1)),
                Text(_fmtHours(_approvedHours).split(' ')[1],
                    style:
                        const TextStyle(fontSize: 11, color: Colors.white70)),
                const Text('Approved',
                    style: TextStyle(fontSize: 9, color: Colors.white54)),
              ]),
            ]),
          ),
        ),
        const SizedBox(width: 20),

        // Stats column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('This Month',
                  style: TextStyle(fontSize: 12, color: Colors.white60)),
              const SizedBox(height: 4),
              Text(_fmtHours(_totalHours),
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5)),
              const Text('Total OT Hours',
                  style: TextStyle(fontSize: 11, color: Colors.white60)),
              const SizedBox(height: 14),
              _summaryRow('Approved', _fmtHours(_approvedHours), Colors.white),
              const SizedBox(height: 5),
              _summaryRow('Pending', _fmtHours(_pendingHours), Colors.white70),
              const SizedBox(height: 5),
              _summaryRow(
                  'Pay Rate', '₹${_ratePerHour.toInt()}/hr', Colors.white54),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _summaryRow(String label, String value, Color color) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54)),
        Text(value,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ]);

  // ─────────────────────────────────────────────
  // APPLY OT CARD  (collapsible)
  // ─────────────────────────────────────────────
  Widget _buildApplyCard() {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Column(children: [
        // Header (always visible — tappable)
        InkWell(
          onTap: () => setState(() => _formOpen = !_formOpen),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    color: _C.orangeLight,
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.add_circle_outline_rounded,
                    size: 16, color: _C.orange),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Apply for Overtime',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _C.textPrimary)),
                    Text('Log overtime for manager approval',
                        style: TextStyle(fontSize: 11, color: _C.textSec)),
                  ],
                ),
              ),
              AnimatedRotation(
                turns: _formOpen ? 0.5 : 0,
                duration: const Duration(milliseconds: 250),
                child: const Icon(Icons.keyboard_arrow_down_rounded,
                    size: 22, color: _C.textSec),
              ),
            ]),
          ),
        ),

        // Collapsible form
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _formOpen
              ? Column(children: [
                  Container(height: 1, color: _C.border),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildApplyForm(),
                  ),
                ])
              : const SizedBox.shrink(),
        ),
      ]),
    );
  }

  Widget _buildApplyForm() {
    final durStr = _otDuration > 0 ? _fmtHours(_otDuration) : '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Date ──────────────────────────────
        _fieldLabel('Date *'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: _C.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _otDate != null ? _C.orange.withValues(alpha: .5) : _C.border,
                width: _otDate != null ? 1.5 : 1,
              ),
            ),
            child: Row(children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    color: _C.orangeLight,
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.calendar_today_outlined,
                    size: 15, color: _C.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _otDate != null ? _fmtDate(_otDate!) : 'Select date',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          _otDate != null ? FontWeight.w500 : FontWeight.w400,
                      color: _otDate != null ? _C.textPrimary : _C.textTert),
                ),
              ),
              const Icon(Icons.edit_calendar_outlined,
                  size: 15, color: _C.textTert),
            ]),
          ),
        ),
        const SizedBox(height: 14),

        // ── Time range ────────────────────────
        _fieldLabel('Time Range *'),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
              child: _timeField('From', _fromTime, () async {
            final t = await _pickTime(_fromTime);
            if (t != null) setState(() => _fromTime = t);
          })),
          const SizedBox(width: 10),
          const Column(children: [
            SizedBox(height: 12),
            Icon(Icons.arrow_forward_rounded, size: 16, color: _C.textTert),
          ]),
          const SizedBox(width: 10),
          Expanded(
              child: _timeField('To', _toTime, () async {
            final t = await _pickTime(_toTime);
            if (t != null) setState(() => _toTime = t);
          })),
        ]),
        const SizedBox(height: 10),

        // ── Duration result ───────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _otDuration > 0 ? _C.orangeLight : _C.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _otDuration > 0 ? _C.orange.withValues(alpha: .3) : _C.border,
            ),
          ),
          child: Row(children: [
            Icon(
              _otDuration > 0
                  ? Icons.timelapse_rounded
                  : Icons.info_outline_rounded,
              size: 16,
              color: _otDuration > 0 ? _C.orange : _C.textTert,
            ),
            const SizedBox(width: 10),
            _otDuration > 0
                ? RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 13),
                      children: [
                        const TextSpan(
                            text: 'OT Duration: ',
                            style: TextStyle(color: _C.textSec)),
                        TextSpan(
                          text: durStr,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, color: _C.orange),
                        ),
                        const TextSpan(
                          text: '  ·  1.5× pay',
                          style: TextStyle(fontSize: 11, color: _C.textSec),
                        ),
                      ],
                    ),
                  )
                : const Text('Select from/to times above',
                    style: TextStyle(fontSize: 13, color: _C.textTert)),
          ]),
        ),
        const SizedBox(height: 14),

        // ── Reason chips ──────────────────────
        _fieldLabel('Reason *'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _reasons.map((r) {
            final active = _otReason == r.value;
            return GestureDetector(
              onTap: () => setState(() => _otReason = r.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? _C.orange : _C.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active ? _C.orange : _C.border,
                    width: 1.5,
                  ),
                ),
                child: Text(r.label,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: active ? Colors.white : _C.textSec)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),

        // ── Notes ─────────────────────────────
        _fieldLabel('Notes (optional)'),
        const SizedBox(height: 8),
        TextField(
          controller: _notesCtrl,
          maxLines: 2,
          maxLength: 200,
          style: const TextStyle(fontSize: 13, color: _C.textPrimary),
          decoration: _inputDeco('Brief description of work done…'),
        ),
        const SizedBox(height: 20),

        // ── Submit ────────────────────────────
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _submitting ? null : _submitOT,
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.orange,
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
                      Text('Submit OT Request',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _timeField(String label, TimeOfDay time, VoidCallback onTap) {
    final isAM = time.period == DayPeriod.am;
    final h = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final m = time.minute.toString().padLeft(2, '0');
    final per = isAM ? 'AM' : 'PM';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.border, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 10, color: _C.textSec)),
            const SizedBox(height: 2),
            Row(children: [
              const Icon(Icons.access_time_rounded, size: 13, color: _C.orange),
              const SizedBox(width: 4),
              Text('$h:$m',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary)),
              const SizedBox(width: 3),
              Text(per,
                  style: const TextStyle(fontSize: 11, color: _C.textSec)),
            ]),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // OT LOG
  // ─────────────────────────────────────────────
  Widget _buildOTLog(List<_OTEntry> filtered) {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Column(children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                  color: _C.orangeLight,
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.list_alt_outlined,
                  size: 16, color: _C.orange),
            ),
            const SizedBox(width: 10),
            const Text('OT Log',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary)),
            const Spacer(),
            Text('${filtered.length} entries',
                style: const TextStyle(fontSize: 11, color: _C.textSec)),
          ]),
        ),

        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(children: [
            _filterChip('All', _filterStatus == null, () {
              setState(() => _filterStatus = null);
            }),
            const SizedBox(width: 8),
            _filterChip('Approved', _filterStatus == _OTStatus.approved, () {
              setState(() => _filterStatus = _OTStatus.approved);
            }),
            const SizedBox(width: 8),
            _filterChip('Pending', _filterStatus == _OTStatus.pending, () {
              setState(() => _filterStatus = _OTStatus.pending);
            }),
            const SizedBox(width: 8),
            _filterChip('Rejected', _filterStatus == _OTStatus.rejected, () {
              setState(() => _filterStatus = _OTStatus.rejected);
            }),
          ]),
        ),

        Container(height: 1, color: _C.border),

        // List
        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Column(children: [
              Icon(Icons.timelapse_rounded, size: 40, color: _C.textDisabled),
              SizedBox(height: 10),
              Text('No records found',
                  style: TextStyle(fontSize: 14, color: _C.textSec)),
            ]),
          )
        else
          Column(
            children: filtered.asMap().entries.map((e) {
              final i = e.key;
              final ot = e.value;
              final isLast = i == filtered.length - 1;
              return _OTLogRow(
                entry: ot,
                isLast: isLast,
                onToggle: () => setState(() => ot.expanded = !ot.expanded),
                onViewDetail: () => _showOTDetail(ot),
              );
            }).toList(),
          ),
      ]),
    );
  }

  Widget _filterChip(String label, bool active, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: active ? _C.orange : _C.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active ? _C.orange : _C.border,
            ),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : _C.textSec)),
        ),
      );

  void _showOTDetail(_OTEntry ot) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _OTDetailSheet(entry: ot),
    );
  }

  // ─────────────────────────────────────────────
  // COMPENSATION CARD
  // ─────────────────────────────────────────────
  Widget _buildCompensationCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: _C.orangeLight,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.account_balance_wallet_outlined,
                  size: 18, color: _C.orange),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OT Compensation',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _C.textPrimary)),
                Text('For approved overtime hours only',
                    style: TextStyle(fontSize: 11, color: _C.textSec)),
              ],
            ),
          ]),
          const SizedBox(height: 16),

          // Available hours
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _C.orangeLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _C.orange.withValues(alpha: .3)),
            ),
            child: Row(children: [
              const Icon(Icons.timelapse_rounded, size: 18, color: _C.orange),
              const SizedBox(width: 10),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 13),
                  children: [
                    const TextSpan(
                        text: 'Approved OT: ',
                        style: TextStyle(color: _C.textSec)),
                    TextSpan(
                      text: _fmtHours(_approvedHours),
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, color: _C.orange),
                    ),
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(height: 14),

          // Toggle
          _fieldLabel('Compensation Mode'),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
                child: _compToggleBtn(
              'Compensatory Off',
              Icons.swap_horiz_rounded,
              _CompType.compOff,
            )),
            const SizedBox(width: 10),
            Expanded(
                child: _compToggleBtn(
              'Cash Payout',
              Icons.currency_rupee_rounded,
              _CompType.cash,
            )),
          ]),
          const SizedBox(height: 14),

          // Value preview
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _compType == _CompType.compOff
                ? _compValue(
                    key: const ValueKey('compoff'),
                    label: 'Equivalent Comp Off',
                    value:
                        '${_compOffDays.toStringAsFixed(1)} Day${_compOffDays != 1 ? "s" : ""}',
                    sub: '${_fmtHours(_approvedHours)} ÷ 9h/day',
                    color: _C.successDark,
                    bg: _C.successLight,
                    icon: Icons.event_available_outlined,
                  )
                : _compValue(
                    key: const ValueKey('cash'),
                    label: 'Cash Payout',
                    value: '₹ ${_cashValue.toStringAsFixed(0)}',
                    sub:
                        '₹${_ratePerHour.toInt()}/hr × ${_fmtHours(_approvedHours)}',
                    color: _C.primary,
                    bg: _C.primaryLight,
                    icon: Icons.currency_rupee_rounded,
                  ),
          ),
          const SizedBox(height: 14),

          // Info note
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _C.warningLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _C.warning.withValues(alpha: .3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 15, color: _C.warningDark),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _compType == _CompType.compOff
                        ? 'Comp-off days must be used within 30 days of approval. Unconsumed days lapse automatically.'
                        : 'Cash payout is processed in the next payroll cycle. Subject to TDS deduction as per applicable slab.',
                    style: const TextStyle(
                        fontSize: 11, color: _C.warningDark, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Claim button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _approvedHours > 0 ? _showClaimDialog : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.orange,
                disabledBackgroundColor: _C.textDisabled,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _compType == _CompType.compOff
                        ? Icons.event_available_outlined
                        : Icons.currency_rupee_rounded,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _compType == _CompType.compOff
                        ? 'Claim Comp Off'
                        : 'Claim Cash Payout',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _compToggleBtn(String label, IconData icon, _CompType type) {
    final active = _compType == type;
    return GestureDetector(
      onTap: () => setState(() => _compType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 50,
        decoration: BoxDecoration(
          color: active ? _C.orange : _C.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? _C.orange : _C.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: active ? Colors.white : _C.textSec),
            const SizedBox(width: 6),
            Flexible(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: active ? Colors.white : _C.textSec),
                    textAlign: TextAlign.center,
                    maxLines: 2)),
          ],
        ),
      ),
    );
  }

  Widget _compValue({
    required Key key,
    required String label,
    required String value,
    required String sub,
    required Color color,
    required Color bg,
    required IconData icon,
  }) =>
      Container(
        key: key,
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: .2)),
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 11, color: _C.textSec)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: -0.5)),
              Text(sub,
                  style: const TextStyle(fontSize: 11, color: _C.textSec)),
            ],
          )),
        ]),
      );

  // ── Shared helpers ─────────────────────────
  Widget _fieldLabel(String text) => Text(text,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: _C.textPrimary));

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
            borderSide: const BorderSide(color: _C.orange, width: 1.5)),
        errorStyle: const TextStyle(fontSize: 11, color: _C.error),
      );
}

// ─────────────────────────────────────────────
// OT LOG ROW
// ─────────────────────────────────────────────
class _OTLogRow extends StatelessWidget {
  final _OTEntry entry;
  final bool isLast;
  final VoidCallback onToggle;
  final VoidCallback onViewDetail;

  const _OTLogRow({
    required this.entry,
    required this.isLast,
    required this.onToggle,
    required this.onViewDetail,
  });

  @override
  Widget build(BuildContext context) {
    final meta = _statusMeta(entry.status);

    return Column(children: [
      InkWell(
        onTap: onToggle,
        onLongPress: onViewDetail,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row
              Row(children: [
                // Date block
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _C.orangeLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${entry.date.day}',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: _C.orange,
                              height: 1)),
                      Text(_monthShort(entry.date.month),
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _C.orangeDark)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_dayName(entry.date.weekday),
                        style:
                            const TextStyle(fontSize: 11, color: _C.textSec)),
                    Row(children: [
                      Text(entry.inTime,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _C.textPrimary)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Icon(Icons.arrow_forward_rounded,
                            size: 12, color: _C.textTert),
                      ),
                      Text(entry.outTime,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _C.textPrimary)),
                    ]),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: _C.orangeLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '🔥 ${_fmtHours(entry.otHours)} OT',
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _C.orange),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('1.5× pay',
                          style: TextStyle(fontSize: 10, color: _C.textTert)),
                    ]),
                  ],
                )),

                // Status + chevron
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: meta.bg,
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: meta.color.withValues(alpha: .3))),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(meta.icon, size: 10, color: meta.color),
                        const SizedBox(width: 3),
                        Text(meta.label,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: meta.color)),
                      ]),
                    ),
                    const SizedBox(height: 4),
                    AnimatedRotation(
                      turns: entry.expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 18, color: _C.textTert),
                    ),
                  ],
                ),
              ]),

              // Expanded details
              if (entry.expanded) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _C.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _detailRow('Reason', _reasonLabel(entry.reason)),
                      if (entry.notes != null)
                        _detailRow('Notes', entry.notes!),
                      if (entry.approver != null)
                        _detailRow('Approver', entry.approver!),
                      _detailRow('ID', entry.id, monospace: true),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: onViewDetail,
                    child: const Text('View full details →',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _C.orange)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      if (!isLast)
        Container(
            height: 1,
            color: _C.border,
            margin: const EdgeInsets.symmetric(horizontal: 16)),
    ]);
  }

  Widget _detailRow(String label, String value, {bool monospace = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 65,
              child: Text(label,
                  style: const TextStyle(fontSize: 11, color: _C.textSec)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _C.textPrimary,
                    fontFamily: monospace ? 'monospace' : null),
              ),
            ),
          ],
        ),
      );

  String _monthShort(int m) => [
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
      ][m];

  String _dayName(int w) =>
      ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][w];
}

// ─────────────────────────────────────────────
// OT DETAIL BOTTOM SHEET
// ─────────────────────────────────────────────
class _OTDetailSheet extends StatelessWidget {
  final _OTEntry entry;
  const _OTDetailSheet({required this.entry});

  @override
  Widget build(BuildContext context) {
    final meta = _statusMeta(entry.status);
    const ratePerHour = 633.0;
    final cashValue = entry.otHours * ratePerHour;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: _C.border, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 18),

          // Header
          Row(children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  color: _C.orangeLight,
                  borderRadius: BorderRadius.circular(14)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${entry.date.day}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _C.orange,
                          height: 1.1)),
                  Text(
                      [
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
                      ][entry.date.month],
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _C.orangeDark)),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_fmtDate(entry.date),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _C.textPrimary)),
                Text('${entry.inTime}  →  ${entry.outTime}',
                    style: const TextStyle(fontSize: 13, color: _C.textSec)),
              ],
            )),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: meta.bg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: meta.color.withValues(alpha: .3))),
              child: Text(meta.label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: meta.color)),
            ),
          ]),
          const SizedBox(height: 16),

          // Stats row
          Row(children: [
            Expanded(
                child: _stat(_fmtHours(entry.otHours), 'OT Hours', _C.orange,
                    _C.orangeLight)),
            const SizedBox(width: 10),
            Expanded(
                child: _stat('1.5×', 'Pay Rate', _C.primary, _C.primaryLight)),
            const SizedBox(width: 10),
            Expanded(
                child: _stat('₹${cashValue.toStringAsFixed(0)}', 'Value',
                    _C.successDark, _C.successLight)),
          ]),
          const SizedBox(height: 16),

          // Detail rows
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: _C.surface, borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              _sheetDetailRow('OT ID', entry.id, mono: true),
              _sheetDetailRow('Reason', _reasonLabel(entry.reason)),
              if (entry.notes != null) _sheetDetailRow('Notes', entry.notes!),
              if (entry.approver != null)
                _sheetDetailRow('Approver', entry.approver!),
              _sheetDetailRow('Status', meta.label, valColor: meta.color),
            ]),
          ),
          const SizedBox(height: 16),

          // Close
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: _C.textSec,
                side: const BorderSide(color: _C.border, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Close',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String val, String label, Color color, Color bg) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Text(val,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: _C.textSec)),
        ]),
      );

  Widget _sheetDetailRow(
    String label,
    String value, {
    bool mono = false,
    Color? valColor,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 72,
              child: Text(label,
                  style: const TextStyle(fontSize: 12, color: _C.textSec)),
            ),
            Expanded(
              child: Text(value,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: valColor ?? _C.textPrimary,
                      fontFamily: mono ? 'monospace' : null)),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────
// RING PAINTER
// ─────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color fillColor;
  final double strokeWidth;

  const _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi,
        false,
        Paint()
          ..color = trackColor
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);

    if (progress > 0) {
      canvas.drawArc(
          rect,
          -math.pi / 2,
          2 * math.pi * progress,
          false,
          Paint()
            ..color = fillColor
            ..strokeWidth = strokeWidth
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
