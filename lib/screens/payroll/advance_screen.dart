// ============================================================
// ISF HR Portal — Advance Screen
// File: lib/screens/payroll/advance_screen.dart
//
// Features:
//   - Eligibility hero card (animated, shows eligible amount)
//   - Apply for Advance form:
//       • Amount field + interactive slider (₹5K–₹42.5K, step ₹1K)
//       • Real-time EMI calculation
//       • Repayment tenure chips (1/2/3/6 months)
//       • Reason chip selector
//       • Optional description
//       • Repayment schedule preview table
//       • Confirmation dialog before submit
//   - Advance history list
//       • Status filter chips
//       • Expandable cards with repayment breakdown
//   - Info card (policy details)
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
  static const successLight = Color(0xFFDCFCE7);
  static const successDark = Color(0xFF16A34A);
  static const warningLight = Color(0xFFFEF9C3);
  static const warningDark = Color(0xFFCA8A04);
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFEF2F2);
  static const errorDark = Color(0xFFDC2626);
  static const teal = Color(0xFF0D9488);
  static const tealLight = Color(0xFFF0FDFA);
  static const orange = Color(0xFFEA580C);
  static const orangeLight = Color(0xFFFFF7ED);
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
enum _AdvanceStatus { pending, approved, disbursed, repaying, repaid, rejected }

enum _AdvanceReason { medical, education, emergency, travel, other }

class _Advance {
  final String id;
  final double amount;
  final int tenureMonths;
  final double emi;
  final _AdvanceReason reason;
  final String? description;
  final _AdvanceStatus status;
  final String appliedOn;
  final String? disbursedOn;
  final int paidEmis;
  final String? managerComment;
  bool expanded = false;

  _Advance({
    required this.id,
    required this.amount,
    required this.tenureMonths,
    required this.emi,
    required this.reason,
    this.description,
    required this.status,
    required this.appliedOn,
    this.disbursedOn,
    this.paidEmis = 0,
    this.managerComment,
  });

  double get outstanding => amount - (paidEmis * emi);
  double get repaidSoFar => paidEmis * emi;
}

// ─────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────
final _mockHistory = [
  _Advance(
    id: 'ADV-2026-002',
    amount: 20000,
    tenureMonths: 2,
    emi: 10000,
    reason: _AdvanceReason.medical,
    description: 'Medical emergency — hospital admission for parent.',
    status: _AdvanceStatus.repaying,
    appliedOn: '01 Apr 2026',
    disbursedOn: '03 Apr 2026',
    paidEmis: 1,
    managerComment: 'Approved. EMI will be deducted from April & May salary.',
  ),
  _Advance(
    id: 'ADV-2025-005',
    amount: 20000,
    tenureMonths: 2,
    emi: 10000,
    reason: _AdvanceReason.medical,
    description: 'Urgent medical expenses.',
    status: _AdvanceStatus.repaid,
    appliedOn: '15 Jan 2025',
    disbursedOn: '17 Jan 2025',
    paidEmis: 2,
    managerComment: 'Approved.',
  ),
  _Advance(
    id: 'ADV-2024-003',
    amount: 10000,
    tenureMonths: 1,
    emi: 10000,
    reason: _AdvanceReason.education,
    description: 'AWS certification fee.',
    status: _AdvanceStatus.repaid,
    appliedOn: '10 Oct 2024',
    disbursedOn: '12 Oct 2024',
    paidEmis: 1,
    managerComment: 'Approved. Deducted in November salary.',
  ),
];

// ─────────────────────────────────────────────
// CONSTANTS
// ─────────────────────────────────────────────
const _grossSalary = 85000.0;
const _maxEligible = 42500.0; // 50% of gross
const _minAmount = 5000.0;
const _sliderStep = 1000.0;
const _tenures = [1, 2, 3, 6];

const _reasons = [
  (
    label: 'Medical',
    value: _AdvanceReason.medical,
    icon: Icons.local_hospital_outlined
  ),
  (
    label: 'Education',
    value: _AdvanceReason.education,
    icon: Icons.school_outlined
  ),
  (
    label: 'Emergency',
    value: _AdvanceReason.emergency,
    icon: Icons.warning_amber_outlined
  ),
  (label: 'Travel', value: _AdvanceReason.travel, icon: Icons.flight_outlined),
  (label: 'Other', value: _AdvanceReason.other, icon: Icons.more_horiz_rounded),
];

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────
String _fmtCurrency(double v) {
  if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
  if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(0)}K';
  return '₹${v.toStringAsFixed(0)}';
}

String _fmtFull(double v) {
  final s = v.toInt().toString();
  final buf = StringBuffer('₹');
  for (int i = 0; i < s.length; i++) {
    final fromEnd = s.length - i;
    if (i > 0 && (fromEnd == 3 || (fromEnd > 3 && (fromEnd - 3) % 2 == 0))) {
      buf.write(',');
    }
    buf.write(s[i]);
  }
  return buf.toString();
}

({String label, Color color, Color bg, IconData icon}) _statusMeta(
    _AdvanceStatus s) {
  switch (s) {
    case _AdvanceStatus.pending:
      return (
        label: 'Pending',
        color: _C.warningDark,
        bg: _C.warningLight,
        icon: Icons.hourglass_top_rounded
      );
    case _AdvanceStatus.approved:
      return (
        label: 'Approved',
        color: _C.primary,
        bg: _C.primaryLight,
        icon: Icons.check_rounded
      );
    case _AdvanceStatus.disbursed:
      return (
        label: 'Disbursed',
        color: _C.teal,
        bg: _C.tealLight,
        icon: Icons.payments_outlined
      );
    case _AdvanceStatus.repaying:
      return (
        label: 'Repaying',
        color: _C.orange,
        bg: _C.orangeLight,
        icon: Icons.loop_rounded
      );
    case _AdvanceStatus.repaid:
      return (
        label: 'Repaid ✓',
        color: _C.successDark,
        bg: _C.successLight,
        icon: Icons.verified_outlined
      );
    case _AdvanceStatus.rejected:
      return (
        label: 'Rejected',
        color: _C.errorDark,
        bg: _C.errorLight,
        icon: Icons.cancel_outlined
      );
  }
}

String _reasonLabel(_AdvanceReason r) =>
    _reasons.firstWhere((x) => x.value == r).label;

IconData _reasonIcon(_AdvanceReason r) =>
    _reasons.firstWhere((x) => x.value == r).icon;

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class AdvanceScreen extends StatefulWidget {
  const AdvanceScreen({super.key});

  @override
  State<AdvanceScreen> createState() => _AdvanceScreenState();
}

class _AdvanceScreenState extends State<AdvanceScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  // ── Eligibility ─────────────────────────────
  // Check if there's an outstanding advance
  bool get _hasOutstanding => _history.any((a) =>
      a.status == _AdvanceStatus.repaying ||
      a.status == _AdvanceStatus.disbursed ||
      a.status == _AdvanceStatus.approved);

  double get _outstandingBalance => _history
      .where((a) =>
          a.status == _AdvanceStatus.repaying ||
          a.status == _AdvanceStatus.disbursed)
      .fold(0.0, (s, a) => s + a.outstanding);

  bool get _isEligible => !_hasOutstanding;

  // ── Form state ──────────────────────────────
  double _amount = 15000;
  int _tenure = 2;
  _AdvanceReason? _reason;
  final _descCtrl = TextEditingController();
  bool _submitting = false;

  double get _emi => _amount / _tenure;

  // ── History state ───────────────────────────
  _AdvanceStatus? _filterStatus;
  final List<_Advance> _history = List.from(_mockHistory);

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ── Submit ───────────────────────────────────
  void _showConfirmation() {
    if (_reason == null) {
      _snack('Please select a reason', _C.error);
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Advance Request',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _confirmRow('Amount', _fmtFull(_amount)),
          _confirmRow('Tenure', '$_tenure month${_tenure != 1 ? "s" : ""}'),
          _confirmRow('EMI', '${_fmtFull(_emi)}/month'),
          _confirmRow('Reason', _reasonLabel(_reason!)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _C.warningLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(children: [
              Icon(Icons.info_outline_rounded, size: 14, color: _C.warningDark),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'EMI will be deducted automatically from your salary.',
                  style: TextStyle(
                      fontSize: 11, color: _C.warningDark, height: 1.4),
                ),
              ),
            ]),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: _C.textSec)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submit();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _confirmRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 13, color: _C.textSec)),
            Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary)),
          ],
        ),
      );

  Future<void> _submit() async {
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final newAdv = _Advance(
      id: 'ADV-2026-0${10 + _history.length}',
      amount: _amount,
      tenureMonths: _tenure,
      emi: _emi,
      reason: _reason!,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      status: _AdvanceStatus.pending,
      appliedOn: 'Today',
    );

    setState(() {
      _submitting = false;
      _history.insert(0, newAdv);
      _amount = 15000;
      _tenure = 2;
      _reason = null;
      _descCtrl.clear();
      _tabCtrl.animateTo(1);
    });

    _snack('Advance request ADV-2026-0${10 + _history.length - 1} submitted ✅',
        _C.successDark);
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
        title: const Text('Salary Advance',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        actions: [
          if (_hasOutstanding)
            Container(
              margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _C.orangeLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.loop_rounded, size: 12, color: _C.orange),
                const SizedBox(width: 4),
                Text(_fmtCurrency(_outstandingBalance),
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _C.orange)),
                const Text(' due',
                    style: TextStyle(fontSize: 11, color: _C.orange)),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
      children: [
        _buildEligibilityCard(),
        const SizedBox(height: 16),
        if (_isEligible) ...[
          _buildFormCard(),
          const SizedBox(height: 16),
          if (_amount > 0) _buildRepaymentPreview(),
          const SizedBox(height: 16),
        ],
        _buildPolicyCard(),
      ],
    );
  }

  // ─── Eligibility card ────────────────────────
  Widget _buildEligibilityCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isEligible
              ? [const Color(0xFF16A34A), const Color(0xFF0D9488)]
              : [const Color(0xFFCA8A04), const Color(0xFFEA580C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                (_isEligible ? _C.successDark : _C.warningDark).withValues(alpha: .3),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(children: [
        // Decorative circles
        Positioned(
            right: -20,
            top: -20,
            child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: .07)))),
        Positioned(
            left: -10,
            bottom: -20,
            child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: .05)))),

        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status badge
              Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      _isEligible
                          ? Icons.check_circle_outline_rounded
                          : Icons.info_outline_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _isEligible ? 'Eligible ✓' : 'Outstanding Balance',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ]),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('FY 2026-27',
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500)),
                ),
              ]),
              const SizedBox(height: 16),

              // Main amount
              const Text('Eligible Advance Amount',
                  style: TextStyle(fontSize: 12, color: Colors.white60)),
              const SizedBox(height: 4),
              Text(
                _isEligible
                    ? _fmtFull(_maxEligible)
                    : _fmtFull(_outstandingBalance),
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1.5,
                    height: 1),
              ),
              const SizedBox(height: 4),
              Text(
                _isEligible
                    ? '50% of gross salary (₹${(_grossSalary / 1000).toInt()}K)'
                    : 'Outstanding balance — clear before applying',
                style: const TextStyle(fontSize: 11, color: Colors.white60),
              ),
              const SizedBox(height: 16),

              // Stats row
              Row(children: [
                _eligStat('Gross Salary', _fmtCurrency(_grossSalary)),
                _eligDivider(),
                _eligStat('Max 50%', _fmtCurrency(_maxEligible)),
                _eligDivider(),
                _eligStat(
                  _isEligible ? 'Outstanding' : 'EMI Due',
                  _isEligible ? '₹0' : _fmtCurrency(_outstandingBalance),
                ),
              ]),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _eligStat(String lbl, String val) => Expanded(
        child: Column(children: [
          Text(val,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          Text(lbl,
              style: const TextStyle(fontSize: 9, color: Colors.white54),
              textAlign: TextAlign.center),
        ]),
      );

  Widget _eligDivider() => Container(
      width: 1,
      height: 28,
      color: Colors.white.withValues(alpha: .2),
      margin: const EdgeInsets.symmetric(horizontal: 4));

  // ─── Form card ───────────────────────────────
  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Column(children: [
        const _CardHdr('New Advance Request', Icons.payments_outlined, _C.primary,
            _C.primaryLight),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Amount ──────────────────────────
              const _FieldLabel('Advance Amount *'),
              const SizedBox(height: 12),

              // Amount display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _C.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _C.primary.withValues(alpha: .3)),
                ),
                child: Column(children: [
                  Text(_fmtFull(_amount),
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: _C.primary,
                          letterSpacing: -1.5)),
                  Text('of ${_fmtFull(_maxEligible)} eligible',
                      style: const TextStyle(fontSize: 11, color: _C.textSec)),
                ]),
              ),
              const SizedBox(height: 12),

              // Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _C.primary,
                  inactiveTrackColor: _C.primaryLight,
                  thumbColor: _C.primaryDark,
                  overlayColor: _C.primary.withValues(alpha: .15),
                  trackHeight: 5,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 10),
                ),
                child: Slider(
                  value: _amount,
                  min: _minAmount,
                  max: _maxEligible,
                  divisions:
                      ((_maxEligible - _minAmount) / _sliderStep).round(),
                  onChanged: (v) => setState(
                      () => _amount = (v / _sliderStep).round() * _sliderStep),
                ),
              ),

              // Min / Max labels
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_fmtCurrency(_minAmount),
                        style:
                            const TextStyle(fontSize: 11, color: _C.textTert)),
                    Text(_fmtCurrency(_maxEligible),
                        style:
                            const TextStyle(fontSize: 11, color: _C.textTert)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Repayment tenure ─────────────────
              const _FieldLabel('Repayment Tenure *'),
              const SizedBox(height: 8),
              Row(
                children: _tenures.map((t) {
                  final active = t == _tenure;
                  return Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.only(right: t != _tenures.last ? 8 : 0),
                      child: GestureDetector(
                        onTap: () => setState(() => _tenure = t),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          height: 52,
                          decoration: BoxDecoration(
                            color: active ? _C.primary : _C.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: active ? _C.primary : _C.border,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('$t',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: active
                                          ? Colors.white
                                          : _C.textPrimary,
                                      height: 1)),
                              Text(t == 1 ? 'Month' : 'Months',
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                      color: active
                                          ? Colors.white70
                                          : _C.textSec)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // ── EMI display ──────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _C.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _C.border),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_month_outlined,
                      size: 18, color: _C.textSec),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 13),
                        children: [
                          const TextSpan(
                              text: 'Monthly EMI: ',
                              style: TextStyle(color: _C.textSec)),
                          TextSpan(
                            text: _fmtFull(_emi),
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: _C.primary,
                                fontSize: 15),
                          ),
                          TextSpan(
                            text:
                                '  ×  $_tenure month${_tenure != 1 ? "s" : ""}',
                            style: const TextStyle(
                                fontSize: 12, color: _C.textSec),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 16),

              // ── Reason chips ─────────────────────
              const _FieldLabel('Reason *'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _reasons.map((r) {
                  final active = _reason == r.value;
                  return GestureDetector(
                    onTap: () => setState(() => _reason = r.value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: active ? _C.primary : _C.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active ? _C.primary : _C.border,
                          width: 1.5,
                        ),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(r.icon,
                            size: 13,
                            color: active ? Colors.white : _C.textSec),
                        const SizedBox(width: 6),
                        Text(r.label,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: active ? Colors.white : _C.textSec)),
                      ]),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // ── Description ──────────────────────
              const _FieldLabel('Description (optional)'),
              const SizedBox(height: 8),
              TextField(
                controller: _descCtrl,
                maxLines: 3,
                maxLength: 200,
                style: const TextStyle(fontSize: 13, color: _C.textPrimary),
                decoration:
                    _inputDeco('Briefly describe why you need this advance…'),
              ),
              const SizedBox(height: 20),

              // ── Submit ───────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitting ? null : () => _showConfirmation(),
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
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.send_outlined, size: 17),
                            const SizedBox(width: 8),
                            Text(
                              'Apply for ${_fmtFull(_amount)} Advance',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  // ─── Repayment preview ───────────────────────
  Widget _buildRepaymentPreview() {
    // Generate future months
    final now = DateTime.now();
    final months = <String>[];
    for (int i = 0; i < _tenure; i++) {
      final m = DateTime(now.year, now.month + i + 1, 1);
      const names = [
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
      months.add('${names[m.month]} ${m.year}');
    }

    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Column(children: [
        const _CardHdr('Repayment Schedule', Icons.event_repeat_rounded, _C.teal,
            _C.tealLight),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Column(children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                  color: _C.surface, borderRadius: BorderRadius.circular(8)),
              child: const Row(children: [
                Expanded(
                    flex: 1,
                    child: Text('#',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _C.textSec))),
                Expanded(
                    flex: 3,
                    child: Text('Month',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _C.textSec))),
                Expanded(
                    flex: 2,
                    child: Text('EMI',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _C.primary))),
                Expanded(
                    flex: 2,
                    child: Text('Outstanding',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _C.textSec))),
              ]),
            ),
            const SizedBox(height: 4),

            ...List.generate(_tenure, (i) {
              final outstanding = _amount - (_emi * (i + 1));
              final isLast = i == _tenure - 1;
              return Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                decoration: BoxDecoration(
                  color: isLast
                      ? _C.successLight.withValues(alpha: .6)
                      : i.isEven
                          ? Colors.transparent
                          : _C.surface.withValues(alpha: .4),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(children: [
                  Expanded(
                      flex: 1,
                      child: Text('${i + 1}',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isLast ? _C.successDark : _C.textSec))),
                  Expanded(
                      flex: 3,
                      child: Text(months[i],
                          style: const TextStyle(
                              fontSize: 12,
                              color: _C.textPrimary,
                              fontWeight: FontWeight.w500))),
                  Expanded(
                      flex: 2,
                      child: Text(_fmtFull(_emi),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _C.primary))),
                  Expanded(
                      flex: 2,
                      child: Text(
                        isLast ? '₹0' : _fmtFull(outstanding),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isLast ? _C.successDark : _C.textPrimary),
                      )),
                ]),
              );
            }),

            Container(
                height: 1,
                color: _C.border,
                margin: const EdgeInsets.symmetric(vertical: 8)),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Repayment',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _C.textPrimary)),
                Text(_fmtFull(_amount),
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _C.primary)),
              ],
            ),
          ]),
        ),
      ]),
    );
  }

  // ─── Policy card ─────────────────────────────
  Widget _buildPolicyCard() {
    final items = [
      ('Eligibility', '50% of gross salary (₹${_fmtCurrency(_maxEligible)})'),
      ('Outstanding', 'No advance if existing balance unpaid'),
      ('Max Tenure', '6 months repayment'),
      ('Repayment', 'Auto-deducted from monthly salary'),
      ('Interest', 'Zero interest — no extra charges'),
      ('Approval Time', '2–3 working days after submission'),
      ('Disbursement', 'Credited to salary account'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Column(children: [
        const _CardHdr(
            'Advance Policy', Icons.policy_outlined, _C.accent, _C.accentLight),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Column(
            children: items.asMap().entries.map((e) {
              final i = e.key;
              final (label, value) = e.value;
              return Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 5, right: 10),
                        decoration: const BoxDecoration(
                            color: _C.accent, shape: BoxShape.circle),
                      ),
                      SizedBox(
                        width: 100,
                        child: Text(label,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _C.textPrimary)),
                      ),
                      Expanded(
                        child: Text(value,
                            style: const TextStyle(
                                fontSize: 12, color: _C.textSec, height: 1.4)),
                      ),
                    ],
                  ),
                ),
                if (i < items.length - 1)
                  Container(height: 1, color: _C.border),
              ]);
            }).toList(),
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
        : _history.where((a) => a.status == _filterStatus).toList();

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
            ...[
              _AdvanceStatus.pending,
              _AdvanceStatus.repaying,
              _AdvanceStatus.repaid,
              _AdvanceStatus.rejected,
            ].map((s) {
              final m = _statusMeta(s);
              final cnt = _history.where((a) => a.status == s).length;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _FChip(
                    m.label,
                    _filterStatus == s,
                    cnt,
                    () => setState(
                        () => _filterStatus = _filterStatus == s ? null : s),
                    color: m.color,
                    bg: m.bg),
              );
            }),
          ]),
        ),
      ),
      Container(height: 1, color: _C.border),

      // List
      Expanded(
        child: filtered.isEmpty
            ? _EmptyHistory()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 48),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _AdvanceCard(
                  advance: filtered[i],
                  onToggle: () => setState(
                      () => filtered[i].expanded = !filtered[i].expanded),
                ),
              ),
      ),
    ]);
  }

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
            borderSide: const BorderSide(color: _C.primary, width: 1.5)),
        errorStyle: const TextStyle(fontSize: 11, color: _C.error),
      );
}

// ─────────────────────────────────────────────
// ADVANCE HISTORY CARD
// ─────────────────────────────────────────────
class _AdvanceCard extends StatelessWidget {
  final _Advance advance;
  final VoidCallback onToggle;

  const _AdvanceCard({required this.advance, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final a = advance;
    final statusMeta = _statusMeta(a.status);
    final isRepaying = a.status == _AdvanceStatus.repaying;
    final repaidPct = isRepaying ? a.repaidSoFar / a.amount : 0.0;

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: a.expanded ? statusMeta.color.withValues(alpha: .4) : _C.border,
            width: a.expanded ? 1.5 : 1,
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
                // Top row
                Row(children: [
                  Text(a.id,
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
                    turns: a.expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 18, color: _C.textTert),
                  ),
                ]),
                const SizedBox(height: 10),

                // Amount + EMI row
                Row(children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Advance Amount',
                            style: TextStyle(fontSize: 10, color: _C.textSec)),
                        Text(_fmtFull(a.amount),
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: _C.textPrimary,
                                letterSpacing: -0.5)),
                      ]),
                  const Spacer(),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    const Text('Monthly EMI',
                        style: TextStyle(fontSize: 10, color: _C.textSec)),
                    Text(_fmtFull(a.emi),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _C.primary)),
                    Text('× ${a.tenureMonths} months',
                        style:
                            const TextStyle(fontSize: 10, color: _C.textTert)),
                  ]),
                ]),
                const SizedBox(height: 10),

                // Reason + date chips
                Row(children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: _C.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _C.primary.withValues(alpha: .2))),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(_reasonIcon(a.reason), size: 11, color: _C.primary),
                      const SizedBox(width: 4),
                      Text(_reasonLabel(a.reason),
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _C.primary)),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  Row(children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 11, color: _C.textTert),
                    const SizedBox(width: 3),
                    Text(a.appliedOn,
                        style:
                            const TextStyle(fontSize: 10, color: _C.textTert)),
                  ]),
                ]),

                // Repayment progress bar (if repaying)
                if (isRepaying) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Repaid: ${_fmtFull(a.repaidSoFar)}',
                          style:
                              const TextStyle(fontSize: 10, color: _C.textSec)),
                      Text('Outstanding: ${_fmtFull(a.outstanding)}',
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _C.orange)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: repaidPct,
                      minHeight: 7,
                      backgroundColor: _C.orangeLight,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(_C.orange),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text('${a.paidEmis} of ${a.tenureMonths} EMIs paid',
                      style: const TextStyle(fontSize: 10, color: _C.textTert)),
                ],
              ],
            ),
          ),

          // ── Expanded detail ──────────────────
          if (a.expanded) ...[
            Container(
                height: 1,
                color: _C.border,
                margin: const EdgeInsets.symmetric(horizontal: 14)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  if (a.description != null) ...[
                    const Text('Description',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _C.textSec)),
                    const SizedBox(height: 4),
                    Text(a.description!,
                        style: const TextStyle(
                            fontSize: 13, color: _C.textPrimary, height: 1.5)),
                    const SizedBox(height: 12),
                  ],

                  // Repayment mini table
                  const Text('Repayment Summary',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _C.textSec)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _C.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(children: [
                      _detailRow('Principal', _fmtFull(a.amount)),
                      _detailRow('Monthly EMI', _fmtFull(a.emi)),
                      _detailRow('Tenure',
                          '${a.tenureMonths} month${a.tenureMonths != 1 ? "s" : ""}'),
                      _detailRow('EMIs Paid', '${a.paidEmis}'),
                      _detailRow('Outstanding',
                          a.outstanding <= 0 ? '₹0' : _fmtFull(a.outstanding),
                          highlight: a.outstanding > 0),
                      if (a.disbursedOn != null)
                        _detailRow('Disbursed On', a.disbursedOn!),
                    ]),
                  ),

                  // Manager comment
                  if (a.managerComment != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _statusMeta(a.status).bg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: _statusMeta(a.status).color.withValues(alpha: .2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(Icons.comment_outlined,
                                size: 12, color: _statusMeta(a.status).color),
                            const SizedBox(width: 5),
                            Text('Manager Comment',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _statusMeta(a.status).color)),
                          ]),
                          const SizedBox(height: 5),
                          Text(a.managerComment!,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: _C.textPrimary,
                                  height: 1.4)),
                        ],
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

  Widget _detailRow(String label, String value, {bool highlight = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 12, color: _C.textSec)),
            Text(value,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: highlight ? _C.orange : _C.textPrimary)),
          ],
        ),
      );
}

// ─────────────────────────────────────────────
// SHARED SMALL WIDGETS
// ─────────────────────────────────────────────
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
    final ac = color ?? _C.primary;
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

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: _C.primaryLight,
                  borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.payments_outlined,
                  size: 36, color: _C.primary),
            ),
            const SizedBox(height: 16),
            const Text('No advance requests',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary)),
            const SizedBox(height: 6),
            const Text('Your advance applications will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: _C.textSec, height: 1.5)),
          ]),
        ),
      );
}
