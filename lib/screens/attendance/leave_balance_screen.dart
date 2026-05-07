// ============================================================
// ISF HR Portal — Leave Balance Screen
// File: lib/screens/leave/leave_balance_screen.dart
//
// Features:
//   - Annual summary hero card with total leave days
//   - 4 leave type balance cards (Casual / Sick / Earned / Comp Off)
//     each with circular arc progress, used/remaining breakdown
//   - Monthly usage bar chart (custom painter, no external lib)
//   - Leave encashment eligibility card
//   - Upcoming leave preview section
//   - Leave rules quick reference
//   - Export / share button
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
class _LeaveType {
  final String id;
  final String label;
  final String shortLabel;
  final int total;
  final int used;
  final int pending; // applied but not yet approved
  final Color color;
  final Color bg;
  final IconData icon;
  final String description;
  final bool encashable;
  final String expiryNote;

  const _LeaveType({
    required this.id,
    required this.label,
    required this.shortLabel,
    required this.total,
    required this.used,
    required this.pending,
    required this.color,
    required this.bg,
    required this.icon,
    required this.description,
    this.encashable = false,
    required this.expiryNote,
  });

  int get balance => total - used - pending;
  double get usedPct => total == 0 ? 0 : used / total;
  double get pendingPct => total == 0 ? 0 : pending / total;
}

class _UpcomingLeave {
  final String type;
  final Color typeColor;
  final Color typeBg;
  final String dateRange;
  final int days;
  final String status;
  final Color statusColor;
  final Color statusBg;

  const _UpcomingLeave({
    required this.type,
    required this.typeColor,
    required this.typeBg,
    required this.dateRange,
    required this.days,
    required this.status,
    required this.statusColor,
    required this.statusBg,
  });
}

// ─────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────
const _leaveTypes = [
  _LeaveType(
    id: 'casual',
    label: 'Casual Leave',
    shortLabel: 'Casual',
    total: 15,
    used: 3,
    pending: 0,
    color: _C.primary,
    bg: _C.primaryLight,
    icon: Icons.calendar_today_outlined,
    description:
        'For personal errands and short breaks. Apply 1 day in advance.',
    expiryNote: 'Lapses on 31 Dec 2026',
  ),
  _LeaveType(
    id: 'sick',
    label: 'Sick Leave',
    shortLabel: 'Sick',
    total: 10,
    used: 4,
    pending: 0,
    color: _C.error,
    bg: _C.errorLight,
    icon: Icons.local_hospital_outlined,
    description:
        'For illness & medical needs. Certificate required for >2 days.',
    expiryNote: 'Lapses on 31 Dec 2026',
  ),
  _LeaveType(
    id: 'earned',
    label: 'Earned Leave',
    shortLabel: 'Earned',
    total: 21,
    used: 3,
    pending: 3,
    color: _C.successDark,
    bg: _C.successLight,
    icon: Icons.event_available_outlined,
    description: 'Accumulated over time. Encashable up to 15 days per year.',
    encashable: true,
    expiryNote: 'Carry forward up to 30 days',
  ),
  _LeaveType(
    id: 'compoff',
    label: 'Comp Off',
    shortLabel: 'Comp Off',
    total: 2,
    used: 0,
    pending: 0,
    color: _C.purple,
    bg: _C.purpleLight,
    icon: Icons.swap_horiz_rounded,
    description: 'Earned for working on weekends or public holidays.',
    expiryNote: 'Must use within 30 days of accrual',
  ),
];

// Monthly usage data (Jan–Apr 2026, days taken per month per type)
final _monthlyUsage = [
  // [casual, sick, earned, compoff]
  [1, 2, 0, 0], // Jan
  [0, 1, 3, 0], // Feb
  [2, 1, 0, 0], // Mar
  [0, 0, 3, 0], // Apr (incl. pending)
];

const _monthLabels = ['Jan', 'Feb', 'Mar', 'Apr'];

const _upcomingLeaves = [
  _UpcomingLeave(
    type: 'Earned',
    typeColor: _C.successDark,
    typeBg: _C.successLight,
    dateRange: '05 – 07 May 2026',
    days: 3,
    status: 'Pending',
    statusColor: _C.warningDark,
    statusBg: _C.warningLight,
  ),
];

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class LeaveBalanceScreen extends StatefulWidget {
  const LeaveBalanceScreen({super.key});

  @override
  State<LeaveBalanceScreen> createState() => _LeaveBalanceScreenState();
}

class _LeaveBalanceScreenState extends State<LeaveBalanceScreen>
    with TickerProviderStateMixin {
  late final List<AnimationController> _arcControllers;
  late final List<Animation<double>> _arcAnimations;
  late final AnimationController _barController;
  late final Animation<double> _barAnimation;

  @override
  void initState() {
    super.initState();

    // Arc animations for each leave type card
    _arcControllers = List.generate(
      _leaveTypes.length,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 900 + i * 120),
      ),
    );
    _arcAnimations = _arcControllers
        .map(
            (ctrl) => CurvedAnimation(parent: ctrl, curve: Curves.easeOutCubic))
        .toList();

    // Bar chart animation
    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _barAnimation =
        CurvedAnimation(parent: _barController, curve: Curves.easeOutCubic);

    // Stagger start
    for (int i = 0; i < _arcControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 100 + i * 80), () {
        if (mounted) _arcControllers[i].forward();
      });
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _barController.forward();
    });
  }

  @override
  void dispose() {
    for (final c in _arcControllers) {
      c.dispose();
    }
    _barController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
        children: [
          _buildHeroSummary(),
          const SizedBox(height: 16),
          _buildBalanceGrid(),
          const SizedBox(height: 16),
          _buildMonthlyChart(),
          const SizedBox(height: 16),
          if (_upcomingLeaves.isNotEmpty) ...[
            _buildUpcoming(),
            const SizedBox(height: 16),
          ],
          _buildEncashmentCard(),
          const SizedBox(height: 16),
          _buildLeaveRules(),
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
        title: const Text('Leave Balance',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            color: _C.textSec,
            onPressed: _shareBalance,
            tooltip: 'Share',
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined, size: 21),
            color: _C.textSec,
            onPressed: _downloadReport,
            tooltip: 'Download',
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _C.border),
        ),
      );

  // ─────────────────────────────────────────────
  // HERO SUMMARY
  // ─────────────────────────────────────────────
  Widget _buildHeroSummary() {
    final totalBalance = _leaveTypes.fold(0, (sum, lt) => sum + lt.balance);
    final totalAllotted = _leaveTypes.fold(0, (sum, lt) => sum + lt.total);
    final totalUsed = _leaveTypes.fold(0, (sum, lt) => sum + lt.used);
    final totalPending = _leaveTypes.fold(0, (sum, lt) => sum + lt.pending);
    final usagePct = totalAllotted == 0 ? 0.0 : totalUsed / totalAllotted;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.date_range_outlined,
                  size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Leave Balance',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                Text('FY 2026 · Jan – Dec 2026',
                    style: TextStyle(fontSize: 11, color: Colors.white60)),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('ISF-2024-0042',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70)),
            ),
          ]),
          const SizedBox(height: 20),

          // Big number row
          Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: '$totalBalance',
                    style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1),
                  ),
                  const TextSpan(
                    text: ' days',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white60),
                  ),
                ]),
              ),
              const Text('Available Balance',
                  style: TextStyle(fontSize: 12, color: Colors.white60)),
            ]),
            const Spacer(),
            // Mini stats column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _heroStat('$totalAllotted', 'Allotted'),
                const SizedBox(height: 8),
                _heroStat('$totalUsed', 'Used'),
                const SizedBox(height: 8),
                _heroStat('$totalPending', 'Pending'),
              ],
            ),
          ]),
          const SizedBox(height: 16),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(usagePct * 100).round()}% used',
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                  Text(
                    '$totalUsed of $totalAllotted days',
                    style: const TextStyle(fontSize: 11, color: Colors.white60),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: usagePct,
                  minHeight: 7,
                  backgroundColor: Colors.white.withValues(alpha: .2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String value, String label) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          Text(label,
              style: const TextStyle(fontSize: 10, color: Colors.white60)),
        ],
      );

  // ─────────────────────────────────────────────
  // BALANCE GRID  (2×2)
  // ─────────────────────────────────────────────
  Widget _buildBalanceGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.85,
      children: List.generate(_leaveTypes.length, (i) {
        return _BalanceCard(
          leaveType: _leaveTypes[i],
          animation: _arcAnimations[i],
          onTap: () => _showLeaveDetail(_leaveTypes[i]),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────
  // MONTHLY CHART
  // ─────────────────────────────────────────────
  Widget _buildMonthlyChart() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Monthly Usage',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: _C.surface, borderRadius: BorderRadius.circular(20)),
                child: const Text('Jan – Apr 2026',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _C.textSec)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Chart
          AnimatedBuilder(
            animation: _barAnimation,
            builder: (_, __) => SizedBox(
              height: 140,
              child: CustomPaint(
                size: const Size(double.infinity, 140),
                painter: _BarChartPainter(
                  data: _monthlyUsage,
                  labels: _monthLabels,
                  colors: [
                    _C.primary,
                    _C.error,
                    _C.successDark,
                    _C.purple,
                  ],
                  progress: _barAnimation.value,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: List.generate(_leaveTypes.length, (i) {
              final lt = _leaveTypes[i];
              return Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: lt.color,
                        borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 5),
                Text(lt.shortLabel,
                    style: const TextStyle(fontSize: 11, color: _C.textSec)),
              ]);
            }),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // UPCOMING LEAVES
  // ─────────────────────────────────────────────
  Widget _buildUpcoming() {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Column(children: [
        _SectionHeader(
            title: 'Upcoming Leaves',
            icon: Icons.event_outlined,
            trailing: Text(
              '${_upcomingLeaves.length} pending',
              style: const TextStyle(fontSize: 12, color: _C.textSec),
            )),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
          child: Column(
            children: _upcomingLeaves.asMap().entries.map((e) {
              final ul = e.value;
              final isLast = e.key == _upcomingLeaves.length - 1;
              return Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                          color: ul.typeBg,
                          borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.event_available_outlined,
                          size: 20, color: ul.typeColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ul.type,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: ul.typeColor)),
                        Text(ul.dateRange,
                            style: const TextStyle(
                                fontSize: 12, color: _C.textSec)),
                        Text('${ul.days} day${ul.days != 1 ? "s" : ""}',
                            style: const TextStyle(
                                fontSize: 11, color: _C.textTert)),
                      ],
                    )),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                          color: ul.statusBg,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(ul.status,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: ul.statusColor)),
                    ),
                  ]),
                ),
                if (!isLast) Container(height: 1, color: _C.border),
              ]);
            }).toList(),
          ),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────
  // ENCASHMENT CARD
  // ─────────────────────────────────────────────
  Widget _buildEncashmentCard() {
    final earned = _leaveTypes.firstWhere((lt) => lt.id == 'earned');
    final encashableDays = math.min(earned.balance, 15); // max 15/yr
    // Assume ₹5,700/day (CTC / 260 working days)
    const ratePerDay = 5700;
    final encashAmount = encashableDays * ratePerDay;

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
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: _C.successLight,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.currency_rupee_rounded,
                  size: 20, color: _C.successDark),
            ),
            const SizedBox(width: 12),
            const Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Leave Encashment',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _C.textPrimary)),
                Text('Earned leave only · Max 15 days/year',
                    style: TextStyle(fontSize: 11, color: _C.textSec)),
              ],
            )),
          ]),
          const SizedBox(height: 16),

          // Stats row
          Row(children: [
            Expanded(
                child: _encashStat(
              '$encashableDays days',
              'Encashable',
              _C.successDark,
              _C.successLight,
            )),
            const SizedBox(width: 10),
            Expanded(
                child: _encashStat(
              '₹${_formatAmount(encashAmount.toDouble())}',
              'Approx Value',
              _C.primary,
              _C.primaryLight,
            )),
            const SizedBox(width: 10),
            Expanded(
                child: _encashStat(
              '₹${_formatAmount(ratePerDay.toDouble())}',
              'Per Day Rate',
              _C.accent,
              _C.accentLight,
            )),
          ]),
          const SizedBox(height: 14),

          // Info note
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _C.warningLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _C.warning.withValues(alpha: .3)),
            ),
            child: const Row(children: [
              Icon(Icons.info_outline_rounded,
                  size: 15, color: _C.warningDark),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Encashment is processed annually in December. Submit request to HR by 30 Nov.',
                  style: TextStyle(
                      fontSize: 11, color: _C.warningDark, height: 1.4),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 14),

          // Encash button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () =>
                  _showEncashmentSheet(encashableDays, encashAmount.toDouble()),
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.successDark,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.currency_rupee_rounded, size: 17),
                  SizedBox(width: 6),
                  Text('Request Encashment',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _encashStat(String value, String label, Color color, Color bg) =>
      Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [
          Text(value,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800, color: color),
              textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 9, fontWeight: FontWeight.w500, color: _C.textSec),
              textAlign: TextAlign.center),
        ]),
      );

  // ─────────────────────────────────────────────
  // LEAVE RULES
  // ─────────────────────────────────────────────
  Widget _buildLeaveRules() {
    const rules = [
      (
        Icons.schedule_outlined,
        'Application Timing',
        'Casual: 1 day prior · Earned: 3 days prior · Emergency: same day (sick)'
      ),
      (
        Icons.rule_outlined,
        'Minimum Duration',
        'All leave types: minimum 0.5 days (half day)'
      ),
      (
        Icons.cached_rounded,
        'Carry Forward',
        'Earned leave: up to 30 days carry forward · Casual & Sick: lapse on 31 Dec'
      ),
      (
        Icons.people_outline_rounded,
        'Weekend Exclusion',
        'Saturdays and Sundays are not counted in leave duration'
      ),
      (
        Icons.assignment_outlined,
        'Documentation',
        'Sick leave > 2 days requires medical certificate. Earned > 5 days requires HR approval'
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Column(children: [
        const _SectionHeader(
            title: 'Leave Policy Quick Ref', icon: Icons.gavel_outlined),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Column(
            children: rules.asMap().entries.map((e) {
              final i = e.key;
              final (icon, title, desc) = e.value;
              return Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                            color: _C.primaryLight,
                            borderRadius: BorderRadius.circular(9)),
                        child: Icon(icon, size: 16, color: _C.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _C.textPrimary)),
                          const SizedBox(height: 2),
                          Text(desc,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: _C.textSec,
                                  height: 1.4)),
                        ],
                      )),
                    ],
                  ),
                ),
                if (i < rules.length - 1)
                  Container(height: 1, color: _C.border),
              ]);
            }).toList(),
          ),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────
  // BOTTOM SHEETS
  // ─────────────────────────────────────────────
  void _showLeaveDetail(_LeaveType lt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _LeaveDetailSheet(leaveType: lt),
    );
  }

  void _showEncashmentSheet(int days, double amount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _EncashmentSheet(
        days: days,
        amount: amount,
        onSubmit: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Encashment request submitted ✅',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.white)),
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

  void _shareBalance() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Share feature coming soon'),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
    ));
  }

  void _downloadReport() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Leave balance PDF downloaded ✅',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
      backgroundColor: _C.successDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  String _formatAmount(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toInt().toString();
  }
}

// ─────────────────────────────────────────────
// BALANCE CARD  (single leave type)
// ─────────────────────────────────────────────
class _BalanceCard extends StatelessWidget {
  final _LeaveType leaveType;
  final Animation<double> animation;
  final VoidCallback onTap;

  const _BalanceCard({
    required this.leaveType,
    required this.animation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lt = leaveType;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _C.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: type icon + encashable badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: lt.bg, borderRadius: BorderRadius.circular(10)),
                  child: Icon(lt.icon, size: 18, color: lt.color),
                ),
                if (lt.encashable)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: _C.successLight,
                        borderRadius: BorderRadius.circular(20)),
                    child: const Text('Encashable',
                        style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: _C.successDark)),
                  )
                else
                  const Icon(Icons.chevron_right_rounded,
                      size: 16, color: _C.textTert),
              ],
            ),
            const SizedBox(height: 12),

            // Arc progress + number
            Center(
              child: AnimatedBuilder(
                animation: animation,
                builder: (_, __) => SizedBox(
                  width: 84,
                  height: 84,
                  child: Stack(alignment: Alignment.center, children: [
                    CustomPaint(
                      size: const Size(84, 84),
                      painter: _ArcPainter(
                        usedPct: lt.usedPct,
                        pendingPct: lt.pendingPct,
                        color: lt.color,
                        pendingColor: lt.color.withValues(alpha: .35),
                        bgColor: lt.bg,
                        progress: animation.value,
                        strokeWidth: 8,
                      ),
                    ),
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('${lt.balance}',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: lt.color,
                              height: 1)),
                      Text('left',
                          style: TextStyle(
                              fontSize: 10, color: lt.color.withValues(alpha: .7))),
                    ]),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Label
            Text(lt.shortLabel,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary)),
            const SizedBox(height: 6),

            // Used / Pending / Total row
            _miniStat('Used', '${lt.used}', lt.color),
            if (lt.pending > 0)
              _miniStat('Pending', '${lt.pending}', lt.color.withValues(alpha: .5)),
            _miniStat('Total', '${lt.total}', _C.textSec),

            const SizedBox(height: 8),

            // Linear bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (lt.used + lt.pending) / lt.total,
                minHeight: 5,
                backgroundColor: lt.bg,
                valueColor: AlwaysStoppedAnimation<Color>(lt.color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String val, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(fontSize: 10, color: _C.textSec)),
          Text(val,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700, color: color)),
        ]),
      );
}

// ─────────────────────────────────────────────
// ARC PAINTER
// ─────────────────────────────────────────────
class _ArcPainter extends CustomPainter {
  final double usedPct;
  final double pendingPct;
  final Color color;
  final Color pendingColor;
  final Color bgColor;
  final double progress;
  final double strokeWidth;

  const _ArcPainter({
    required this.usedPct,
    required this.pendingPct,
    required this.color,
    required this.pendingColor,
    required this.bgColor,
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -math.pi / 2;
    const fullArc = 2 * math.pi;

    final Paint basePaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final Paint usedPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final Paint pendingPaint = Paint()
      ..color = pendingColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Background full arc
    canvas.drawArc(rect, startAngle, fullArc, false, basePaint);

    // Used arc
    if (usedPct > 0) {
      canvas.drawArc(
          rect, startAngle, fullArc * usedPct * progress, false, usedPaint);
    }

    // Pending arc (stacked after used)
    if (pendingPct > 0) {
      canvas.drawArc(
        rect,
        startAngle + fullArc * usedPct * progress,
        fullArc * pendingPct * progress,
        false,
        pendingPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress ||
      old.usedPct != usedPct ||
      old.pendingPct != pendingPct;
}

// ─────────────────────────────────────────────
// BAR CHART PAINTER
// ─────────────────────────────────────────────
class _BarChartPainter extends CustomPainter {
  final List<List<int>> data;
  final List<String> labels;
  final List<Color> colors;
  final double progress;

  const _BarChartPainter({
    required this.data,
    required this.labels,
    required this.colors,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const bottomPad = 24.0;
    const topPad = 8.0;
    final chartH = size.height - bottomPad - topPad;

    // Find max value for y-axis scaling
    int maxVal = 1;
    for (final row in data) {
      final sum = row.fold(0, (a, b) => a + b);
      if (sum > maxVal) maxVal = sum;
    }

    final monthW = size.width / data.length;
    final groupW = monthW * 0.7;
    final barW = groupW / colors.length;

    for (int m = 0; m < data.length; m++) {
      final groupX = monthW * m + (monthW - groupW) / 2;

      for (int t = 0; t < colors.length; t++) {
        final val = data[m][t];
        if (val <= 0) continue;
        final barH = (val / maxVal) * chartH * progress;
        final x = groupX + t * barW;
        final y = topPad + chartH - barH;

        final rRect = RRect.fromRectAndCorners(
          Rect.fromLTWH(x + 1, y, barW - 2, barH),
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
        );
        canvas.drawRRect(rRect, Paint()..color = colors[t]);
      }

      // Month label
      final tp = TextPainter(
        text: TextSpan(
          text: labels[m],
          style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w500, color: _C.textSec),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(
          monthW * m + monthW / 2 - tp.width / 2,
          size.height - bottomPad + 6,
        ),
      );
    }

    // Y-axis grid lines
    final gridPaint = Paint()
      ..color = _C.border
      ..strokeWidth = 0.5;
    for (int g = 0; g <= maxVal; g++) {
      final y = topPad + chartH - (g / maxVal) * chartH;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);

      // Y label
      if (g > 0) {
        final tp = TextPainter(
          text: TextSpan(
            text: '$g',
            style: const TextStyle(fontSize: 9, color: _C.textTert),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(0, y - tp.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────
// LEAVE DETAIL SHEET
// ─────────────────────────────────────────────
class _LeaveDetailSheet extends StatelessWidget {
  final _LeaveType leaveType;
  const _LeaveDetailSheet({required this.leaveType});

  @override
  Widget build(BuildContext context) {
    final lt = leaveType;
    final usedPct = lt.total == 0 ? 0.0 : lt.used / lt.total;
    final balancePct = lt.total == 0 ? 0.0 : lt.balance / lt.total;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.85,
      minChildSize: 0.4,
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
                      color: _C.border,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 18),

            // Header
            Row(children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: lt.bg, borderRadius: BorderRadius.circular(14)),
                child: Icon(lt.icon, size: 24, color: lt.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lt.label,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _C.textPrimary)),
                  Text(lt.expiryNote,
                      style: TextStyle(fontSize: 12, color: lt.color)),
                ],
              )),
              if (lt.encashable)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: _C.successLight,
                      borderRadius: BorderRadius.circular(20)),
                  child: const Text('Encashable',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _C.successDark)),
                ),
            ]),
            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                controller: ctrl,
                children: [
                  // Stats
                  Row(children: [
                    Expanded(
                        child: _detailStat('${lt.total}', 'Total Allotted',
                            _C.textSec, _C.surface)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _detailStat(
                            '${lt.used}', 'Days Used', lt.color, lt.bg)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _detailStat('${lt.balance}', 'Remaining',
                            _C.successDark, _C.successLight)),
                  ]),
                  const SizedBox(height: 16),

                  // Progress bar detailed
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: _C.surface,
                        borderRadius: BorderRadius.circular(14)),
                    child: Column(children: [
                      _progressRow('Used', usedPct, lt.color, '${lt.used}d'),
                      const SizedBox(height: 10),
                      if (lt.pending > 0) ...[
                        _progressRow('Pending', lt.pendingPct,
                            lt.color.withValues(alpha: .45), '${lt.pending}d'),
                        const SizedBox(height: 10),
                      ],
                      _progressRow('Remaining', balancePct, _C.successDark,
                          '${lt.balance}d'),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: lt.bg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: lt.color.withValues(alpha: .2))),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 16, color: lt.color),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(lt.description,
                              style: TextStyle(
                                  fontSize: 13, color: lt.color, height: 1.5)),
                        ),
                      ],
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

  Widget _detailStat(String val, String label, Color color, Color bg) =>
      Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Text(val,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          Text(label,
              style: const TextStyle(fontSize: 10, color: _C.textSec),
              textAlign: TextAlign.center),
        ]),
      );

  Widget _progressRow(String label, double pct, Color color, String val) =>
      Row(children: [
        SizedBox(
          width: 64,
          child: Text(label,
              style: const TextStyle(fontSize: 11, color: _C.textSec)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct.clamp(0, 1),
              minHeight: 8,
              backgroundColor: _C.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(val,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: color)),
      ]);
}

// ─────────────────────────────────────────────
// ENCASHMENT SHEET
// ─────────────────────────────────────────────
class _EncashmentSheet extends StatefulWidget {
  final int days;
  final double amount;
  final VoidCallback onSubmit;

  const _EncashmentSheet({
    required this.days,
    required this.amount,
    required this.onSubmit,
  });

  @override
  State<_EncashmentSheet> createState() => _EncashmentSheetState();
}

class _EncashmentSheetState extends State<_EncashmentSheet> {
  late double _selectedDays;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _selectedDays = widget.days.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final ratePerDay = widget.amount / widget.days;
    final calcAmount = _selectedDays * ratePerDay;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, 36 + MediaQuery.of(context).viewInsets.bottom),
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
          const Text('Request Leave Encashment',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary)),
          const SizedBox(height: 4),
          const Text('Earned leave only · Processed in December',
              style: TextStyle(fontSize: 13, color: _C.textSec)),
          const SizedBox(height: 20),

          // Days slider
          Text('Select days to encash: ${_selectedDays.toInt()} days',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _C.textPrimary)),
          Slider(
            value: _selectedDays,
            min: 1,
            max: widget.days.toDouble(),
            divisions: widget.days - 1,
            activeColor: _C.successDark,
            onChanged: (v) => setState(() => _selectedDays = v),
          ),
          const SizedBox(height: 8),

          // Amount preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _C.successLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _C.success.withValues(alpha: .3)),
            ),
            child: Column(children: [
              const Text('Encashment Amount',
                  style: TextStyle(fontSize: 12, color: _C.textSec)),
              const SizedBox(height: 4),
              Text(
                '₹ ${calcAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: _C.successDark),
              ),
              Text(
                '₹ ${ratePerDay.toStringAsFixed(0)}/day × ${_selectedDays.toInt()} days',
                style: const TextStyle(fontSize: 11, color: _C.textSec),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          // Submit
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _submitting
                  ? null
                  : () async {
                      setState(() => _submitting = true);
                      await Future.delayed(const Duration(milliseconds: 1300));
                      if (mounted) widget.onSubmit();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.successDark,
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
                  : const Text('Submit Encashment Request',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;

  const _SectionHeader({
    required this.title,
    required this.icon,
    this.trailing,
  });

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
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary)),
          ),
          if (trailing != null) trailing!,
        ]),
      ),
      Container(height: 1, color: _C.border),
    ]);
  }
}
