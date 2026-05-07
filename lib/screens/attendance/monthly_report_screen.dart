// ============================================================
// ISF HR Portal — Monthly Report Screen
// File: lib/screens/attendance/monthly_report_screen.dart
//
// Features:
//   - Month/Year selector with prev/next navigation
//   - Color-coded attendance calendar grid
//   - 6-metric summary row (Present/Absent/Leave/OT/Holiday/Half Day)
//   - Productivity score card with circular progress
//   - Detailed daily log list with expandable rows
//   - Export/Download sheet (PDF, Excel, CSV)
//   - Legend bottom sheet
//
// Dependencies: none beyond flutter/material
// ============================================================

import 'package:flutter/material.dart';
import 'dart:math' as math;

// ─── Replace with actual imports ─────────────────────────
// import '../../theme/app_colors.dart';
// import '../../theme/app_text_styles.dart';
// import '../../data/mock_data.dart';
// ─────────────────────────────────────────────────────────

// ─────────────────────────────────────────────
// INLINE THEME
// ─────────────────────────────────────────────
class _C {
  static const primary = Color(0xFF2563EB);
  static const primaryLight = Color(0xFFEFF6FF);
  static const accent = Color(0xFF6366F1);
  static const accentLight = Color(0xFFEEF2FF);
  static const successLight = Color(0xFFDCFCE7);
  static const successDark = Color(0xFF16A34A);
  static const warningLight = Color(0xFFFEF9C3);
  static const warningDark = Color(0xFFCA8A04);
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFEF2F2);
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
enum AttStatus { present, absent, leave, holiday, weekend, halfDay, overtime }

class DayRecord {
  final DateTime date;
  final AttStatus status;
  final String? inTime;
  final String? outTime;
  final String? hours;
  final String? overtime;
  final String? leaveType;
  final String? holidayName;

  const DayRecord({
    required this.date,
    required this.status,
    this.inTime,
    this.outTime,
    this.hours,
    this.overtime,
    this.leaveType,
    this.holidayName,
  });
}

// ─────────────────────────────────────────────
// MOCK DATA  (April 2026)
// ─────────────────────────────────────────────
List<DayRecord> _buildMockData(int year, int month) {
  // Generates deterministic mock data for any month
  final days = DateUtils.getDaysInMonth(year, month);
  final records = <DayRecord>[];
  final rng = math.Random(year * 100 + month);

  for (int d = 1; d <= days; d++) {
    final date = DateTime(year, month, d);
    final weekday = date.weekday; // 1=Mon…7=Sun

    if (weekday == 6 || weekday == 7) {
      records.add(DayRecord(date: date, status: AttStatus.weekend));
      continue;
    }

    // Fixed special days for April 2026
    if (year == 2026 && month == 4) {
      if (d == 14) {
        records.add(DayRecord(
            date: date,
            status: AttStatus.holiday,
            holidayName: 'Ambedkar Jayanti'));
        continue;
      }
      if (d == 10 || d == 11) {
        records.add(DayRecord(
            date: date, status: AttStatus.leave, leaveType: 'Casual Leave'));
        continue;
      }
      if (d == 8) {
        records.add(DayRecord(date: date, status: AttStatus.absent));
        continue;
      }
      if (d == 16) {
        records.add(DayRecord(
            date: date,
            status: AttStatus.halfDay,
            inTime: '09:05 AM',
            outTime: '01:00 PM',
            hours: '3h 55m'));
        continue;
      }
      if (d == 3 || d == 17 || d == 23) {
        final hrs = 10 + rng.nextInt(2);
        final mins = rng.nextInt(60);
        final ot = hrs - 9;
        records.add(DayRecord(
            date: date,
            status: AttStatus.overtime,
            inTime: '09:00 AM',
            outTime:
                '${(18 + ot).toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')} PM',
            hours: '${hrs}h ${mins.toString().padLeft(2, '0')}m',
            overtime: '${ot}h ${mins.toString().padLeft(2, '0')}m'));
        continue;
      }
    }

    // Default: present
    const inH = 9;
    final inM = rng.nextInt(20);
    const outH = 18;
    final outM = rng.nextInt(20);
    final totalMins = (outH * 60 + outM) - (inH * 60 + inM);
    final th = totalMins ~/ 60;
    final tm = totalMins % 60;

    records.add(DayRecord(
        date: date,
        status: AttStatus.present,
        inTime:
            '${inH.toString().padLeft(2, '0')}:${inM.toString().padLeft(2, '0')} AM',
        outTime:
            '${outH.toString().padLeft(2, '0')}:${outM.toString().padLeft(2, '0')} PM',
        hours: '${th}h ${tm.toString().padLeft(2, '0')}m'));
  }
  return records;
}

// ─────────────────────────────────────────────
// STATUS METADATA
// ─────────────────────────────────────────────
({Color color, Color bg, String label, String short}) _statusMeta(AttStatus s) {
  switch (s) {
    case AttStatus.present:
      return (
        color: _C.successDark,
        bg: _C.successLight,
        label: 'Present',
        short: 'P'
      );
    case AttStatus.absent:
      return (color: _C.error, bg: _C.errorLight, label: 'Absent', short: 'A');
    case AttStatus.leave:
      return (
        color: _C.primary,
        bg: _C.primaryLight,
        label: 'On Leave',
        short: 'L'
      );
    case AttStatus.holiday:
      return (
        color: _C.purple,
        bg: _C.purpleLight,
        label: 'Holiday',
        short: 'H'
      );
    case AttStatus.weekend:
      return (color: _C.textTert, bg: _C.surface, label: 'Weekend', short: '–');
    case AttStatus.halfDay:
      return (
        color: _C.warningDark,
        bg: _C.warningLight,
        label: 'Half Day',
        short: '½'
      );
    case AttStatus.overtime:
      return (
        color: _C.orange,
        bg: _C.orangeLight,
        label: 'Overtime',
        short: 'OT'
      );
  }
}

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  DateTime _month = DateTime(2026, 4);
  late List<DayRecord> _records;
  final _scrollCtrl = ScrollController();

  // Expand state for daily log
  final Set<int> _expandedDays = {};

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    _records = _buildMockData(_month.year, _month.month);
    _expandedDays.clear();
  }

  void _prevMonth() => setState(() {
        _month = DateTime(_month.year, _month.month - 1);
        _loadRecords();
      });

  void _nextMonth() {
    final now = DateTime.now();
    final next = DateTime(_month.year, _month.month + 1);
    if (next.isAfter(DateTime(now.year, now.month))) return;
    setState(() {
      _month = next;
      _loadRecords();
    });
  }

  // ── Computed summaries ────────────────────
  int get _presentCount => _records
      .where((r) =>
          r.status == AttStatus.present || r.status == AttStatus.overtime)
      .length;
  int get _absentCount =>
      _records.where((r) => r.status == AttStatus.absent).length;
  int get _leaveCount =>
      _records.where((r) => r.status == AttStatus.leave).length;
  int get _holidayCount =>
      _records.where((r) => r.status == AttStatus.holiday).length;
  int get _overtimeCount =>
      _records.where((r) => r.status == AttStatus.overtime).length;
  int get _halfDayCount =>
      _records.where((r) => r.status == AttStatus.halfDay).length;
  int get _workingDays => _records
      .where(
          (r) => r.status != AttStatus.weekend && r.status != AttStatus.holiday)
      .length;
  double get _attendancePct =>
      _workingDays == 0 ? 0 : (_presentCount / _workingDays).clamp(0, 1);

  // Total OT hours (mock: 1.5h per OT day)
  double get _totalOTHours => _overtimeCount * 1.5;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrentMonth = _month.year == now.year && _month.month == now.month;

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _buildAppBar(),
      body: ListView(
        controller: _scrollCtrl,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
        children: [
          _buildMonthSelector(isCurrentMonth),
          const SizedBox(height: 16),
          _buildProductivityCard(),
          const SizedBox(height: 16),
          _buildSummaryGrid(),
          const SizedBox(height: 16),
          _buildCalendar(),
          const SizedBox(height: 16),
          _buildDailyLog(),
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
        title: const Text('Monthly Report',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, size: 20),
            color: _C.textSec,
            onPressed: _showLegend,
            tooltip: 'Legend',
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined, size: 22),
            color: _C.textSec,
            onPressed: _showExportSheet,
            tooltip: 'Export',
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _C.border),
        ),
      );

  // ─────────────────────────────────────────────
  // MONTH SELECTOR
  // ─────────────────────────────────────────────
  Widget _buildMonthSelector(bool isCurrentMonth) {
    final monthName = _monthName(_month.month);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          color: _C.textSec,
          onPressed: _prevMonth,
          tooltip: 'Previous month',
        ),
        Expanded(
          child: Column(children: [
            Text('$monthName ${_month.year}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary)),
            const SizedBox(height: 2),
            Text(
              isCurrentMonth
                  ? 'Current month'
                  : '${DateUtils.getDaysInMonth(_month.year, _month.month)} days',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: _C.textSec),
            ),
          ]),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded),
          color: isCurrentMonth ? _C.textDisabled : _C.textSec,
          onPressed: isCurrentMonth ? null : _nextMonth,
          tooltip: 'Next month',
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────
  // PRODUCTIVITY CARD
  // ─────────────────────────────────────────────
  Widget _buildProductivityCard() {
    final pct = (_attendancePct * 100).round();
    final Color scoreColor = pct >= 90
        ? _C.successDark
        : pct >= 75
            ? _C.warningDark
            : _C.error;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Row(children: [
        // Circular progress
        SizedBox(
          width: 90,
          height: 90,
          child: Stack(alignment: Alignment.center, children: [
            CustomPaint(
              size: const Size(90, 90),
              painter: _RingPainter(
                progress: _attendancePct,
                color: scoreColor,
                bgColor: _C.surface,
                strokeWidth: 9,
              ),
            ),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text('$pct%',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: scoreColor)),
              const Text('Score',
                  style: TextStyle(fontSize: 10, color: _C.textSec)),
            ]),
          ]),
        ),
        const SizedBox(width: 20),
        // Stats
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Attendance Score',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary)),
              const SizedBox(height: 4),
              Text(
                pct >= 90
                    ? 'Excellent — Keep it up!'
                    : pct >= 75
                        ? 'Good — Room for improvement'
                        : 'Needs improvement',
                style: TextStyle(fontSize: 12, color: scoreColor),
              ),
              const SizedBox(height: 12),
              _statRow('Working Days', '$_workingDays days', _C.primary),
              const SizedBox(height: 4),
              _statRow('Overtime Hours', '${_totalOTHours.toStringAsFixed(1)}h',
                  _C.orange),
              const SizedBox(height: 4),
              _statRow('Avg In Time', '09:08 AM', _C.textSec),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _statRow(String label, String value, Color valColor) => Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 11, color: _C.textSec)),
          ),
          Text(value,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: valColor)),
        ],
      );

  // ─────────────────────────────────────────────
  // SUMMARY GRID
  // ─────────────────────────────────────────────
  Widget _buildSummaryGrid() {
    final items = [
      (
        'Present',
        _presentCount,
        _C.successDark,
        _C.successLight,
        Icons.check_circle_outline_rounded
      ),
      ('Absent', _absentCount, _C.error, _C.errorLight, Icons.cancel_outlined),
      (
        'On Leave',
        _leaveCount,
        _C.primary,
        _C.primaryLight,
        Icons.event_busy_outlined
      ),
      (
        'Overtime',
        _overtimeCount,
        _C.orange,
        _C.orangeLight,
        Icons.timelapse_rounded
      ),
      (
        'Holiday',
        _holidayCount,
        _C.purple,
        _C.purpleLight,
        Icons.celebration_outlined
      ),
      (
        'Half Day',
        _halfDayCount,
        _C.warningDark,
        _C.warningLight,
        Icons.wb_twilight_outlined
      ),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.15,
      children: items.map((item) {
        final (label, count, color, bg, icon) = item;
        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: .25)),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 20, color: color),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$count',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: color)),
                  Text(label,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color.withValues(alpha: .8))),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ─────────────────────────────────────────────
  // CALENDAR GRID
  // ─────────────────────────────────────────────
  Widget _buildCalendar() {
    final firstDay = DateTime(_month.year, _month.month, 1);
    // 0=Mon offset
    final startOffset = (firstDay.weekday - 1) % 7;
    final daysInMonth = DateUtils.getDaysInMonth(_month.year, _month.month);

    // Build grid cells
    final cells = <Widget>[];

    // Day labels row
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    for (final d in dayLabels) {
      cells.add(Center(
        child: Text(d,
            style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700, color: _C.textSec)),
      ));
    }

    // Leading blanks
    for (int i = 0; i < startOffset; i++) {
      cells.add(const SizedBox.shrink());
    }

    // Days
    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(_month.year, _month.month, d);
      final record = _records.firstWhere((r) => r.date.day == d,
          orElse: () => DayRecord(date: date, status: AttStatus.weekend));
      final meta = _statusMeta(record.status);
      final isToday = _isToday(date);

      cells.add(_CalendarCell(
        day: d,
        meta: meta,
        isToday: isToday,
        status: record.status,
        onTap: record.status != AttStatus.weekend
            ? () => _scrollToDayLog(d)
            : null,
      ));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Calendar',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary)),
              GestureDetector(
                onTap: _showLegend,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _C.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 12, color: _C.primary),
                      SizedBox(width: 4),
                      Text('Legend',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _C.primary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Grid
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 4,
            childAspectRatio: 0.9,
            children: cells,
          ),
          const SizedBox(height: 8),
          // Mini legend row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                AttStatus.present,
                AttStatus.absent,
                AttStatus.leave,
                AttStatus.overtime,
                AttStatus.holiday,
                AttStatus.halfDay,
              ].map((s) {
                final m = _statusMeta(s);
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: m.color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 3),
                      Text(m.label,
                          style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: _C.textSec)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // DAILY LOG
  // ─────────────────────────────────────────────
  Widget _buildDailyLog() {
    final workingRecords = _records
        .where((r) => r.status != AttStatus.weekend)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Daily Log',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _C.textPrimary)),
                Text('${workingRecords.length} entries',
                    style: const TextStyle(fontSize: 11, color: _C.textSec)),
              ],
            ),
          ),
          Container(height: 1, color: _C.border),
          // Records
          ...workingRecords.asMap().entries.map((e) {
            final i = e.key;
            final rec = e.value;
            final isExpanded = _expandedDays.contains(rec.date.day);
            final isLast = i == workingRecords.length - 1;
            return _DayLogRow(
              record: rec,
              isExpanded: isExpanded,
              isLast: isLast,
              onTap: () => setState(() {
                if (isExpanded) {
                  _expandedDays.remove(rec.date.day);
                } else {
                  _expandedDays.add(rec.date.day);
                }
              }),
            );
          }),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _scrollToDayLog(int day) {
    setState(() {
      _expandedDays.add(day);
    });
    // Scroll down a bit to show the log
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  // ─────────────────────────────────────────────
  // LEGEND SHEET
  // ─────────────────────────────────────────────
  void _showLegend() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _LegendSheet(),
    );
  }

  // ─────────────────────────────────────────────
  // EXPORT SHEET
  // ─────────────────────────────────────────────
  void _showExportSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ExportSheet(
        monthLabel: '${_monthName(_month.month)} ${_month.year}',
        onExport: (format) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                '$format report for ${_monthName(_month.month)} downloaded ✅'),
            backgroundColor: _C.successDark,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ));
        },
      ),
    );
  }

  String _monthName(int m) => [
        '',
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ][m];
}

// ─────────────────────────────────────────────
// CALENDAR CELL
// ─────────────────────────────────────────────
class _CalendarCell extends StatelessWidget {
  final int day;
  final ({Color color, Color bg, String label, String short}) meta;
  final bool isToday;
  final AttStatus status;
  final VoidCallback? onTap;

  const _CalendarCell({
    required this.day,
    required this.meta,
    required this.isToday,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWeekend = status == AttStatus.weekend;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isToday
              ? _C.primary
              : isWeekend
                  ? Colors.transparent
                  : meta.bg,
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? null
              : isWeekend
                  ? null
                  : Border.all(color: meta.color.withValues(alpha: .3), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$day',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isToday
                        ? Colors.white
                        : isWeekend
                            ? _C.textDisabled
                            : meta.color)),
            if (!isWeekend && !isToday)
              Text(meta.short,
                  style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: meta.color.withValues(alpha: .8))),
            if (isToday)
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DAY LOG ROW
// ─────────────────────────────────────────────
class _DayLogRow extends StatelessWidget {
  final DayRecord record;
  final bool isExpanded;
  final bool isLast;
  final VoidCallback onTap;

  const _DayLogRow({
    required this.record,
    required this.isExpanded,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final meta = _statusMeta(record.status);
    final weekday = _weekdayShort(record.date.weekday);
    final dayStr = '${record.date.day.toString().padLeft(2, '0')} '
        '${_monthShort(record.date.month)}';

    return Column(children: [
      InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                // Date
                SizedBox(
                  width: 56,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(weekday,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: _C.textSec)),
                      Text(dayStr,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _C.textPrimary)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Status chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                const Spacer(),
                // Hours
                if (record.hours != null)
                  Text(record.hours!,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _C.textPrimary)),
                const SizedBox(width: 8),
                // Chevron
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color:
                        record.inTime != null ? _C.textSec : Colors.transparent,
                  ),
                ),
              ]),
              // Expanded detail
              if (isExpanded && record.inTime != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _C.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _detailRow('In Time', record.inTime!, _C.successDark),
                      const SizedBox(height: 8),
                      _detailRow('Out Time', record.outTime ?? '—', _C.error),
                      const SizedBox(height: 8),
                      _detailRow('Total Hours', record.hours!, _C.primary),
                      if (record.overtime != null) ...[
                        const SizedBox(height: 8),
                        _detailRow('Overtime', record.overtime!, _C.orange),
                      ],
                    ],
                  ),
                ),
              ],
              if (isExpanded && record.leaveType != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _C.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    const Icon(Icons.event_busy_outlined,
                        size: 16, color: _C.primary),
                    const SizedBox(width: 8),
                    Text(record.leaveType!,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _C.primary)),
                  ]),
                ),
              ],
              if (isExpanded && record.holidayName != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _C.purpleLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    const Icon(Icons.celebration_outlined,
                        size: 16, color: _C.purple),
                    const SizedBox(width: 8),
                    Text(record.holidayName!,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _C.purple)),
                  ]),
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

  Widget _detailRow(String label, String value, Color color) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: _C.textSec)),
          Text(value,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ],
      );

  String _weekdayShort(int w) =>
      ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][w];

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
}

// ─────────────────────────────────────────────
// RING PAINTER
// ─────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color bgColor;
  final double strokeWidth;

  const _RingPainter({
    required this.progress,
    required this.color,
    required this.bgColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background ring
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi,
      false,
      Paint()
        ..color = bgColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Progress ring
    if (progress > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}

// ─────────────────────────────────────────────
// LEGEND SHEET
// ─────────────────────────────────────────────
class _LegendSheet extends StatelessWidget {
  final _statuses = const [
    AttStatus.present,
    AttStatus.absent,
    AttStatus.leave,
    AttStatus.overtime,
    AttStatus.holiday,
    AttStatus.halfDay,
    AttStatus.weekend,
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
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
                    color: _C.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            const Text('Attendance Legend',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary)),
            const SizedBox(height: 4),
            const Text('Color codes used in the calendar',
                style: TextStyle(fontSize: 13, color: _C.textSec)),
            const SizedBox(height: 16),
            ..._statuses.map((s) {
              final m = _statusMeta(s);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [
                  // Color circle with short label
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: m.bg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: m.color.withValues(alpha: .3))),
                    child: Center(
                      child: Text(m.short,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: m.color)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.label,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: m.color)),
                        Text(_legendDesc(s),
                            style:
                                const TextStyle(fontSize: 12, color: _C.textSec)),
                      ],
                    ),
                  ),
                ]),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _legendDesc(AttStatus s) {
    switch (s) {
      case AttStatus.present:
        return 'Full day attendance recorded';
      case AttStatus.absent:
        return 'No attendance logged';
      case AttStatus.leave:
        return 'Approved leave application';
      case AttStatus.overtime:
        return 'Worked beyond standard hours';
      case AttStatus.holiday:
        return 'Company / public holiday';
      case AttStatus.halfDay:
        return 'Partial day attendance';
      case AttStatus.weekend:
        return 'Saturday or Sunday';
    }
  }
}

// ─────────────────────────────────────────────
// EXPORT SHEET
// ─────────────────────────────────────────────
class _ExportSheet extends StatefulWidget {
  final String monthLabel;
  final void Function(String format) onExport;

  const _ExportSheet({required this.monthLabel, required this.onExport});

  @override
  State<_ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<_ExportSheet> {
  bool _exporting = false;
  String? _selectedFormat;

  final _formats = const [
    (
      Icons.picture_as_pdf_outlined,
      'PDF Report',
      'Full attendance report with summary',
      _C.error,
      _C.errorLight
    ),
    (
      Icons.table_chart_outlined,
      'Excel Sheet',
      'Spreadsheet with daily log data',
      _C.successDark,
      _C.successLight
    ),
    (
      Icons.code_outlined,
      'CSV Export',
      'Raw data for custom analysis',
      _C.accent,
      _C.accentLight
    ),
  ];

  Future<void> _export(String format) async {
    setState(() {
      _selectedFormat = format;
      _exporting = true;
    });
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) {
      setState(() => _exporting = false);
      widget.onExport(format);
    }
  }

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
                  color: _C.border, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Export Report',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary)),
          const SizedBox(height: 2),
          Text('Download ${widget.monthLabel} attendance report',
              style: const TextStyle(fontSize: 13, color: _C.textSec)),
          const SizedBox(height: 16),
          ..._formats.map((f) {
            final (icon, title, sub, color, bg) = f;
            final isLoading = _exporting && _selectedFormat == title;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: _exporting ? null : () => _export(title),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _C.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _selectedFormat == title && _exporting
                          ? color
                          : _C.border,
                      width: _selectedFormat == title && _exporting ? 1.5 : 1,
                    ),
                  ),
                  child: Row(children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                          color: bg, borderRadius: BorderRadius.circular(12)),
                      child: isLoading
                          ? Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: color, strokeWidth: 2.5),
                              ),
                            )
                          : Icon(icon, color: color, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _C.textPrimary)),
                          Text(sub,
                              style: const TextStyle(
                                  fontSize: 11, color: _C.textSec)),
                        ],
                      ),
                    ),
                    Icon(
                      isLoading
                          ? Icons.hourglass_empty_rounded
                          : Icons.download_outlined,
                      size: 18,
                      color: isLoading ? color : _C.textSec,
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
