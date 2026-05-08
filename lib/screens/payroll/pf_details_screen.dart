// ============================================================
// ISF HR Portal — PF Details Screen
// File: lib/screens/payroll/pf_details_screen.dart
//
// Features:
//   - PF Account dark card (PF No, UAN, member since)
//   - Balance summary (Employee / Employer / Total) with animation
//   - Custom animated stacked bar chart (no external lib)
//   - Monthly contribution history table
//   - Quick action cards (Withdraw / Transfer / Nomination / Passbook)
//   - Withdrawal eligibility alert
//   - PF Transfer form (bottom sheet)
//   - Nomination update form (bottom sheet)
//   - Passbook download with progress
//
// Dependencies: none beyond flutter/material
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  static const teal = Color(0xFF0D9488);
  static const tealLight = Color(0xFFF0FDFA);
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
class _MonthContrib {
  final String month;
  final double employee; // 12% of basic
  final double employer; // 3.67% to PF, rest to EPS
  final double eps; // 8.33% employer to EPS
  const _MonthContrib(this.month, this.employee, this.employer, this.eps);
  double get pfTotal => employee + employer;
}

// ─────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────
const _monthlyContribs = [
  _MonthContrib('Apr 2026', 5100, 1561, 3539),
  _MonthContrib('Mar 2026', 5100, 1561, 3539),
  _MonthContrib('Feb 2026', 5100, 1561, 3539),
  _MonthContrib('Jan 2026', 5100, 1561, 3539),
  _MonthContrib('Dec 2025', 5100, 1561, 3539),
  _MonthContrib('Nov 2025', 5100, 1561, 3539),
];

// Cumulative balance since joining (Mar 2024)
const _employeeBalance = 71400.0; // 14 months × ₹5,100
const _employerBalance = 21854.0; // 14 months × ₹1,561
const _epsBalance = 49546.0; // 14 months × ₹3,539
const _totalPFBalance = _employeeBalance + _employerBalance;

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────
String _fmtCurrency(double v) {
  if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(2)}L';
  if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(1)}K';
  return '₹${v.toStringAsFixed(0)}';
}

String _fmtFull(double v) {
  // Indian number formatting
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

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class PFDetailsScreen extends StatefulWidget {
  const PFDetailsScreen({super.key});

  @override
  State<PFDetailsScreen> createState() => _PFDetailsScreenState();
}

class _PFDetailsScreenState extends State<PFDetailsScreen>
    with TickerProviderStateMixin {
  // ── Animations ──────────────────────────────
  late final AnimationController _balCtrl;
  late final AnimationController _barCtrl;
  late final Animation<double> _balAnim;
  late final Animation<double> _barAnim;

  // ── Download state ──────────────────────────
  bool _downloading = false;
  double _downloadProgress = 0;

  @override
  void initState() {
    super.initState();

    _balCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _barCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));

    _balAnim = CurvedAnimation(parent: _balCtrl, curve: Curves.easeOutCubic);
    _barAnim = CurvedAnimation(parent: _barCtrl, curve: Curves.easeOutCubic);

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        _balCtrl.forward();
        _barCtrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _balCtrl.dispose();
    _barCtrl.dispose();
    super.dispose();
  }

  // ── Copy ─────────────────────────────────────
  void _copy(String v, String lbl) {
    Clipboard.setData(ClipboardData(text: v));
    _snack('$lbl copied', _C.textSec);
  }

  // ── Snack ─────────────────────────────────────
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

  // ── Download passbook ────────────────────────
  Future<void> _downloadPassbook() async {
    if (_downloading) return;
    setState(() {
      _downloading = true;
      _downloadProgress = 0;
    });
    for (int i = 1; i <= 30; i++) {
      await Future.delayed(const Duration(milliseconds: 60));
      if (!mounted) return;
      setState(() => _downloadProgress = i / 30);
    }
    setState(() {
      _downloading = false;
      _downloadProgress = 0;
    });
    _snack('PF Passbook downloaded ✅', _C.successDark);
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
          _buildAccountCard(),
          const SizedBox(height: 16),
          _buildBalanceSummary(),
          const SizedBox(height: 16),
          _buildBarChart(),
          const SizedBox(height: 16),
          _buildContribTable(),
          const SizedBox(height: 16),
          _buildQuickActions(),
          const SizedBox(height: 16),
          _buildPassbookButton(),
          const SizedBox(height: 16),
          _buildInfoCard(),
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
        title: const Text('PF Details',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            color: _C.textSec,
            onPressed: () => _snack('PF statement shared', _C.textSec),
            tooltip: 'Share',
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _C.border),
        ),
      );

  // ─────────────────────────────────────────────
  // PF ACCOUNT CARD
  // ─────────────────────────────────────────────
  Widget _buildAccountCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(children: [
        // Decorative circles
        Positioned(right: -24, top: -24, child: _circle(120, .05)),
        Positioned(right: 40, bottom: -30, child: _circle(80, .04)),
        Positioned(left: -10, bottom: -10, child: _circle(60, .03)),

        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.account_balance_rounded,
                        size: 15, color: Colors.white),
                    SizedBox(width: 6),
                    Text('EPFO',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1)),
                  ]),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _C.success.withValues(alpha: .2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: .15)),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.circle, size: 7, color: _C.success),
                    SizedBox(width: 5),
                    Text('Active',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ]),
                ),
              ]),
              const SizedBox(height: 20),

              // Employee info
              const Text('AMIT PATIL',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5)),
              const Text('Full Stack Developer · ISF Solutions Pvt. Ltd.',
                  style: TextStyle(fontSize: 11, color: Colors.white54)),
              const SizedBox(height: 18),

              // PF Account Number
              _accountRow('PF ACCOUNT NO', 'MH/BAN/1234567',
                  () => _copy('MH/BAN/1234567', 'PF Account Number')),
              const SizedBox(height: 12),

              // UAN
              _accountRow('UAN NUMBER', '100987654321',
                  () => _copy('100987654321', 'UAN')),
              const SizedBox(height: 16),

              // Bottom row
              Row(children: [
                _cardMeta('Member Since', 'Mar 2024'),
                const SizedBox(width: 24),
                _cardMeta('Employer Code', 'MH/BAN/123'),
                const Spacer(),
                // Member years badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Column(children: [
                    Text('1 yr',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    Text('tenure',
                        style: TextStyle(fontSize: 9, color: Colors.white54)),
                  ]),
                ),
              ]),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _circle(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      );

  Widget _accountRow(String label, String value, VoidCallback onCopy) =>
      GestureDetector(
        onTap: onCopy,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white54,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 3),
            Row(children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.copy_outlined,
                    size: 12, color: Colors.white60),
              ),
            ]),
          ],
        ),
      );

  Widget _cardMeta(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white54,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ],
      );

  // ─────────────────────────────────────────────
  // BALANCE SUMMARY
  // ─────────────────────────────────────────────
  Widget _buildBalanceSummary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Column(children: [
        // Total balance hero
        Row(children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total PF Balance',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _C.textSec)),
              const SizedBox(height: 4),
              AnimatedBuilder(
                animation: _balAnim,
                builder: (_, __) => Text(
                  _fmtFull(_totalPFBalance * _balAnim.value),
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _C.primary,
                      letterSpacing: -1),
                ),
              ),
              const SizedBox(height: 2),
              const Text('As of Apr 2026',
                  style: TextStyle(fontSize: 11, color: _C.textTert)),
            ],
          )),
          // Growth indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _C.successLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Column(children: [
              Icon(Icons.trending_up_rounded,
                  size: 22, color: _C.successDark),
              SizedBox(height: 4),
              Text('+8.25%',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _C.successDark)),
              Text('Interest\np.a.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 9, color: _C.textSec, height: 1.3)),
            ]),
          ),
        ]),
        const SizedBox(height: 18),

        // 3 stat boxes
        Row(children: [
          Expanded(
              child: _balBox('Employee\nShare', _employeeBalance, 'Your 12%',
                  _C.primary, _C.primaryLight, _balAnim)),
          const SizedBox(width: 8),
          Expanded(
              child: _balBox('Employer\nShare', _employerBalance, 'Co. 3.67%',
                  _C.teal, _C.tealLight, _balAnim)),
          const SizedBox(width: 8),
          Expanded(
              child: _balBox('EPS\nBalance', _epsBalance, 'Co. 8.33%',
                  _C.purple, _C.purpleLight, _balAnim)),
        ]),
        const SizedBox(height: 12),

        // Note
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _C.warningLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _C.warning.withValues(alpha: .25)),
          ),
          child: const Row(children: [
            Icon(Icons.info_outline_rounded, size: 14, color: _C.warningDark),
            SizedBox(width: 7),
            Expanded(
              child: Text(
                'EPS (Employee Pension Scheme) balance cannot be withdrawn separately.',
                style:
                    TextStyle(fontSize: 11, color: _C.warningDark, height: 1.4),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _balBox(String label, double amount, String sub, Color color, Color bg,
          Animation<double> anim) =>
      Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
        child: Column(children: [
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: _C.textSec,
                  height: 1.3)),
          const SizedBox(height: 6),
          AnimatedBuilder(
            animation: anim,
            builder: (_, __) => Text(
              _fmtCurrency(amount * anim.value),
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: -0.5),
            ),
          ),
          const SizedBox(height: 2),
          Text(sub,
              style: TextStyle(fontSize: 9, color: color.withValues(alpha: .7))),
        ]),
      );

  // ─────────────────────────────────────────────
  // BAR CHART
  // ─────────────────────────────────────────────
  Widget _buildBarChart() {
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
              const Text('Monthly Contributions',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: _C.surface, borderRadius: BorderRadius.circular(20)),
                child: const Text('Nov 25 – Apr 26',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _C.textSec)),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Chart
          AnimatedBuilder(
            animation: _barAnim,
            builder: (_, __) => SizedBox(
              height: 160,
              child: CustomPaint(
                size: const Size(double.infinity, 160),
                painter: _StackedBarPainter(
                  data: _monthlyContribs,
                  progress: _barAnim.value,
                  empColor: _C.primary,
                  erColor: _C.teal,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Legend
          Row(children: [
            _legend('Employee (12%)', _C.primary),
            const SizedBox(width: 16),
            _legend('Employer (3.67% PF)', _C.teal),
          ]),
        ],
      ),
    );
  }

  Widget _legend(String label, Color color) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 11, color: _C.textSec)),
        ],
      );

  // ─────────────────────────────────────────────
  // CONTRIBUTION TABLE
  // ─────────────────────────────────────────────
  Widget _buildContribTable() {
    return _SectionCard(
      title: 'Contribution History',
      icon: Icons.receipt_long_outlined,
      iconColor: _C.primary,
      iconBg: _C.primaryLight,
      child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
              color: _C.surface, borderRadius: BorderRadius.circular(8)),
          child: const Row(children: [
            Expanded(
                flex: 3,
                child: Text('Month',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _C.textSec))),
            Expanded(
                flex: 2,
                child: Text('Employee',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _C.primary))),
            Expanded(
                flex: 2,
                child: Text('Employer',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _C.teal))),
            Expanded(
                flex: 2,
                child: Text('EPS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _C.purple))),
            Expanded(
                flex: 2,
                child: Text('Total PF',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _C.textPrimary))),
          ]),
        ),
        const SizedBox(height: 4),

        // Rows
        ..._monthlyContribs.asMap().entries.map((e) {
          final i = e.key;
          final c = e.value;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            decoration: BoxDecoration(
              color: i.isEven ? Colors.transparent : _C.surface.withValues(alpha: .4),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(children: [
              Expanded(
                  flex: 3,
                  child: Text(c.month,
                      style: const TextStyle(
                          fontSize: 12,
                          color: _C.textPrimary,
                          fontWeight: FontWeight.w500))),
              Expanded(
                  flex: 2,
                  child: Text(_fmtCurrency(c.employee),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _C.primary))),
              Expanded(
                  flex: 2,
                  child: Text(_fmtCurrency(c.employer),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _C.teal))),
              Expanded(
                  flex: 2,
                  child: Text(_fmtCurrency(c.eps),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _C.purple))),
              Expanded(
                  flex: 2,
                  child: Text(_fmtCurrency(c.pfTotal),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _C.textPrimary))),
            ]),
          );
        }),

        Container(
            height: 1,
            color: _C.border,
            margin: const EdgeInsets.symmetric(vertical: 8)),

        // Total row
        Row(children: [
          const Expanded(
              flex: 3,
              child: Text('Total (6 mo.)',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary))),
          Expanded(
              flex: 2,
              child: Text(_fmtCurrency(5100 * 6),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _C.primary))),
          Expanded(
              flex: 2,
              child: Text(_fmtCurrency(1561 * 6),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _C.teal))),
          Expanded(
              flex: 2,
              child: Text(_fmtCurrency(3539 * 6),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _C.purple))),
          Expanded(
              flex: 2,
              child: Text(_fmtCurrency((5100 + 1561) * 6),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _C.textPrimary))),
        ]),
      ]),
    );
  }

  // ─────────────────────────────────────────────
  // QUICK ACTIONS
  // ─────────────────────────────────────────────
  Widget _buildQuickActions() {
    final actions = [
      (
        icon: Icons.account_balance_wallet_outlined,
        label: 'Withdraw\nPF',
        color: _C.error,
        bg: _C.errorLight,
        onTap: () => _showWithdrawAlert(),
      ),
      (
        icon: Icons.swap_horiz_rounded,
        label: 'Transfer\nPF',
        color: _C.primary,
        bg: _C.primaryLight,
        onTap: () => _showTransferSheet(),
      ),
      (
        icon: Icons.person_add_alt_1_outlined,
        label: 'Update\nNomination',
        color: _C.teal,
        bg: _C.tealLight,
        onTap: () => _showNominationSheet(),
      ),
      (
        icon: Icons.book_outlined,
        label: 'Download\nPassbook',
        color: _C.purple,
        bg: _C.purpleLight,
        onTap: () => _downloadPassbook(),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _C.textPrimary)),
        const SizedBox(height: 12),
        Row(
          children: actions.map((a) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: a != actions.last ? 10 : 0),
                child: _ActionCard(
                  icon: a.icon,
                  label: a.label,
                  color: a.color,
                  bg: a.bg,
                  onTap: a.onTap,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // PASSBOOK DOWNLOAD BUTTON
  // ─────────────────────────────────────────────
  Widget _buildPassbookButton() {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        const Row(children: [
          Icon(Icons.book_outlined, size: 20, color: _C.primary),
          SizedBox(width: 10),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PF Passbook',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary)),
              Text('Complete transaction history from EPFO',
                  style: TextStyle(fontSize: 11, color: _C.textSec)),
            ],
          )),
        ]),
        const SizedBox(height: 14),
        if (_downloading) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Downloading…',
                      style: TextStyle(
                          fontSize: 12,
                          color: _C.primary,
                          fontWeight: FontWeight.w500)),
                  Text(
                    '${(_downloadProgress * 100).toInt()}%',
                    style: const TextStyle(
                        fontSize: 12,
                        color: _C.primary,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _downloadProgress,
                  minHeight: 6,
                  backgroundColor: _C.primaryLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(_C.primary),
                ),
              ),
            ],
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _downloadPassbook,
              icon: const Icon(Icons.download_outlined, size: 18),
              label: const Text('Download PDF Passbook',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ]),
    );
  }

  // ─────────────────────────────────────────────
  // INFO CARD
  // ─────────────────────────────────────────────
  Widget _buildInfoCard() {
    final items = [
      (
        'PF Rate',
        'Employee: 12% of Basic · Employer: 12% (3.67% PF + 8.33% EPS)'
      ),
      ('Interest Rate', '8.25% p.a. for FY 2025-26 (declared by EPFO)'),
      ('Withdrawal', 'Full withdrawal: After 2 months of unemployment'),
      ('Partial', 'After 5 years for housing, medical, marriage, education'),
      ('EPS Pension', 'Eligible after 10 years of service at age 58'),
      ('Nomination', 'Nominee receives balance in case of member\'s death'),
    ];

    return _SectionCard(
      title: 'PF Rules & Information',
      icon: Icons.policy_outlined,
      iconColor: _C.accent,
      iconBg: _C.accentLight,
      child: Column(
        children: items.asMap().entries.map((e) {
          final i = e.key;
          final (label, desc) = e.value;
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
                    decoration:
                        const BoxDecoration(color: _C.accent, shape: BoxShape.circle),
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _C.textPrimary)),
                      const SizedBox(height: 2),
                      Text(desc,
                          style: const TextStyle(
                              fontSize: 11, color: _C.textSec, height: 1.4)),
                    ],
                  )),
                ],
              ),
            ),
            if (i < items.length - 1) Container(height: 1, color: _C.border),
          ]);
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // DIALOGS & SHEETS
  // ─────────────────────────────────────────────
  void _showWithdrawAlert() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('PF Withdrawal',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _C.errorLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(children: [
                Icon(Icons.warning_amber_rounded, size: 18, color: _C.error),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You are currently employed. PF withdrawal is only available after 2 months of unemployment.',
                    style:
                        TextStyle(fontSize: 12, color: _C.error, height: 1.4),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 12),
            const Text(
              'For partial withdrawal (medical, housing, marriage), please contact HR at payroll@isf.com.',
              style: TextStyle(fontSize: 13, color: _C.textSec, height: 1.5),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  void _showTransferSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _TransferSheet(
        onSubmit: () {
          Navigator.pop(context);
          _snack('PF transfer request submitted ✅', _C.successDark);
        },
      ),
    );
  }

  void _showNominationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _NominationSheet(
        onSubmit: () {
          Navigator.pop(context);
          _snack('Nomination updated successfully ✅', _C.successDark);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STACKED BAR CHART PAINTER
// ─────────────────────────────────────────────
class _StackedBarPainter extends CustomPainter {
  final List<_MonthContrib> data;
  final double progress;
  final Color empColor;
  final Color erColor;

  const _StackedBarPainter({
    required this.data,
    required this.progress,
    required this.empColor,
    required this.erColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const bottomPad = 22.0;
    const topPad = 8.0;
    const barGap = 8.0;
    final chartH = size.height - bottomPad - topPad;
    const maxVal = 8000.0;
    final barW = (size.width / data.length) - barGap;

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 0.5;
    for (int g = 0; g <= 4; g++) {
      final y = topPad + chartH - (g / 4) * chartH;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      // Y-axis label
      final tp = TextPainter(
        text: TextSpan(
          text: '₹${(maxVal * g / 4 / 1000).toStringAsFixed(0)}K',
          style: const TextStyle(fontSize: 8, color: Color(0xFF94A3B8)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height - 1));
    }

    for (int i = 0; i < data.length; i++) {
      final c = data[i];
      final x = (size.width / data.length) * i + barGap / 2;

      // Employee bar
      final empH = (c.employee / maxVal) * chartH * progress;
      final erH = (c.employer / maxVal) * chartH * progress;

      // Employer (bottom)
      final erRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, topPad + chartH - erH, barW, erH),
        bottomLeft: const Radius.circular(3),
        bottomRight: const Radius.circular(3),
      );
      canvas.drawRRect(erRect, Paint()..color = erColor);

      // Employee (stacked on top)
      final empRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, topPad + chartH - erH - empH, barW, empH),
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
      );
      canvas.drawRRect(empRect, Paint()..color = empColor);

      // Month label
      final tp = TextPainter(
        text: TextSpan(
          text: c.month.substring(0, 3),
          style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas,
          Offset(x + barW / 2 - tp.width / 2, size.height - bottomPad + 5));
    }
  }

  @override
  bool shouldRepaint(_StackedBarPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────
// ACTION CARD
// ─────────────────────────────────────────────
class _ActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color, bg;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: widget.bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: widget.color.withValues(alpha: .2)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(widget.icon, size: 22, color: widget.color),
            const SizedBox(height: 6),
            Text(widget.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: widget.color,
                    height: 1.3)),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TRANSFER SHEET
// ─────────────────────────────────────────────
class _TransferSheet extends StatefulWidget {
  final VoidCallback onSubmit;
  const _TransferSheet({required this.onSubmit});

  @override
  State<_TransferSheet> createState() => _TransferSheetState();
}

class _TransferSheetState extends State<_TransferSheet> {
  final _prevPFCtrl = TextEditingController();
  final _prevUANCtrl = TextEditingController();
  final _prevEmpCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _prevPFCtrl.dispose();
    _prevUANCtrl.dispose();
    _prevEmpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, 32 + MediaQuery.of(context).viewInsets.bottom),
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
            const SizedBox(height: 18),
            const Text('Transfer PF Account',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary)),
            const SizedBox(height: 4),
            const Text(
                'Transfer your previous employer\'s PF to current account',
                style: TextStyle(fontSize: 13, color: _C.textSec)),
            const SizedBox(height: 18),
            _label('Previous PF Account Number'),
            const SizedBox(height: 6),
            _field(_prevPFCtrl, 'e.g. MH/MUM/123456'),
            const SizedBox(height: 10),
            _label('Previous UAN (if different)'),
            const SizedBox(height: 6),
            _field(_prevUANCtrl, 'e.g. 100123456789'),
            const SizedBox(height: 10),
            _label('Previous Employer Name'),
            const SizedBox(height: 6),
            _field(_prevEmpCtrl, 'e.g. ABC Technologies Pvt Ltd'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitting
                    ? null
                    : () async {
                        setState(() => _submitting = true);
                        await Future.delayed(
                            const Duration(milliseconds: 1300));
                        if (mounted) widget.onSubmit();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _C.textDisabled,
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
                    : const Text('Submit Transfer Request',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
    );
  }

  Widget _label(String t) => Text(t,
      style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600, color: _C.textPrimary));

  Widget _field(TextEditingController c, String hint) => TextField(
        controller: c,
        style: const TextStyle(fontSize: 14, color: _C.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: _C.textTert),
          filled: true,
          fillColor: _C.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.border, width: 1.5)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.border, width: 1.5)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.primary, width: 1.5)),
        ),
      );
}

// ─────────────────────────────────────────────
// NOMINATION SHEET
// ─────────────────────────────────────────────
class _NominationSheet extends StatefulWidget {
  final VoidCallback onSubmit;
  const _NominationSheet({required this.onSubmit});

  @override
  State<_NominationSheet> createState() => _NominationSheetState();
}

class _NominationSheetState extends State<_NominationSheet> {
  final _nameCtrl = TextEditingController(text: 'Sunita Patil');
  final _relCtrl = TextEditingController(text: 'Spouse');
  final _shareCtrl = TextEditingController(text: '100');
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _relCtrl.dispose();
    _shareCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, 32 + MediaQuery.of(context).viewInsets.bottom),
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
            const SizedBox(height: 18),
            const Text('Update Nomination',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary)),
            const SizedBox(height: 4),
            const Text('Nominee will receive your PF balance in your absence',
                style: TextStyle(fontSize: 13, color: _C.textSec)),
            const SizedBox(height: 18),
            _label('Nominee Full Name *'),
            const SizedBox(height: 6),
            _field(_nameCtrl, 'e.g. Sunita Patil'),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Relationship *'),
                  const SizedBox(height: 6),
                  _field(_relCtrl, 'e.g. Spouse'),
                ],
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Share (%) *'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _shareCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(fontSize: 14, color: _C.textPrimary),
                    decoration: InputDecoration(
                      hintText: '100',
                      filled: true,
                      fillColor: _C.surface,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: _C.border, width: 1.5)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: _C.border, width: 1.5)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: _C.teal, width: 1.5)),
                      suffixText: '%',
                      suffixStyle: const TextStyle(color: _C.textSec),
                    ),
                  ),
                ],
              )),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitting
                    ? null
                    : () async {
                        setState(() => _submitting = true);
                        await Future.delayed(
                            const Duration(milliseconds: 1200));
                        if (mounted) widget.onSubmit();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.teal,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _C.textDisabled,
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
                    : const Text('Save Nomination',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
    );
  }

  Widget _label(String t) => Text(t,
      style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600, color: _C.textPrimary));

  Widget _field(TextEditingController c, String hint) => TextField(
        controller: c,
        style: const TextStyle(fontSize: 14, color: _C.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: _C.textTert),
          filled: true,
          fillColor: _C.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.border, width: 1.5)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.border, width: 1.5)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.teal, width: 1.5)),
        ),
      );
}

// ─────────────────────────────────────────────
// SECTION CARD WRAPPER
// ─────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor, iconBg;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _C.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    color: iconBg, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 16, color: iconColor),
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
          Padding(padding: const EdgeInsets.all(16), child: child),
        ]),
      );
}
