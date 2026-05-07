// ============================================================
// ISF HR Portal — Payslip Screen
// File: lib/screens/payroll/payslip_screen.dart
//
// Features:
//   - Horizontal month cards (scroll, tap to select)
//   - Selected payslip detail:
//       • Employee mini-summary row
//       • 3-column Gross / Deductions / Net Pay cards
//       • Earnings breakdown (expandable)
//       • Deductions breakdown (expandable)
//       • Visual salary bar (proportional green/red)
//       • Year-to-date summary
//   - Download PDF with animated progress
//   - Email payslip action
//   - Full-screen payslip preview bottom sheet
//   - All payslips list (past months)
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
  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFEF9C3);
  static const warningDark = Color(0xFFCA8A04);
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFEF2F2);
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
class _SalaryItem {
  final String label;
  final double amount;
  final String? note;
  const _SalaryItem(this.label, this.amount, {this.note});
}

class _Payslip {
  final String id;
  final String month;
  final String monthShort;
  final int year;
  final double grossPay;
  final double netPay;
  final double totalDeductions;
  final String paidOn;
  final String status; // 'paid' | 'pending'
  final List<_SalaryItem> earnings;
  final List<_SalaryItem> deductions;

  const _Payslip({
    required this.id,
    required this.month,
    required this.monthShort,
    required this.year,
    required this.grossPay,
    required this.netPay,
    required this.totalDeductions,
    required this.paidOn,
    required this.status,
    required this.earnings,
    required this.deductions,
  });
}

// ─────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────
const _mockPayslips = [
  _Payslip(
    id: 'PAY-2026-04',
    month: 'April',
    monthShort: 'Apr',
    year: 2026,
    grossPay: 85000,
    netPay: 72450,
    totalDeductions: 12550,
    paidOn: '30 Apr 2026',
    status: 'paid',
    earnings: [
      _SalaryItem('Basic Salary', 42500, note: '50% of CTC'),
      _SalaryItem('HRA', 17000, note: '40% of Basic'),
      _SalaryItem('Special Allowance', 12750),
      _SalaryItem('Medical Allowance', 1250),
      _SalaryItem('Travel Allowance', 11500),
    ],
    deductions: [
      _SalaryItem('PF (Employee)', 5100, note: '12% of Basic'),
      _SalaryItem('ESIC', 638, note: '0.75% of Gross'),
      _SalaryItem('Professional Tax', 200),
      _SalaryItem('TDS', 6612, note: 'As per IT declaration'),
    ],
  ),
  _Payslip(
    id: 'PAY-2026-03',
    month: 'March',
    monthShort: 'Mar',
    year: 2026,
    grossPay: 85000,
    netPay: 72450,
    totalDeductions: 12550,
    paidOn: '31 Mar 2026',
    status: 'paid',
    earnings: [
      _SalaryItem('Basic Salary', 42500),
      _SalaryItem('HRA', 17000),
      _SalaryItem('Special Allowance', 12750),
      _SalaryItem('Medical Allowance', 1250),
      _SalaryItem('Travel Allowance', 11500),
    ],
    deductions: [
      _SalaryItem('PF (Employee)', 5100),
      _SalaryItem('ESIC', 638),
      _SalaryItem('Professional Tax', 200),
      _SalaryItem('TDS', 6612),
    ],
  ),
  _Payslip(
    id: 'PAY-2026-02',
    month: 'February',
    monthShort: 'Feb',
    year: 2026,
    grossPay: 85000,
    netPay: 72450,
    totalDeductions: 12550,
    paidOn: '28 Feb 2026',
    status: 'paid',
    earnings: [
      _SalaryItem('Basic Salary', 42500),
      _SalaryItem('HRA', 17000),
      _SalaryItem('Special Allowance', 12750),
      _SalaryItem('Medical Allowance', 1250),
      _SalaryItem('Travel Allowance', 11500),
    ],
    deductions: [
      _SalaryItem('PF (Employee)', 5100),
      _SalaryItem('ESIC', 638),
      _SalaryItem('Professional Tax', 200),
      _SalaryItem('TDS', 6612),
    ],
  ),
  _Payslip(
    id: 'PAY-2026-01',
    month: 'January',
    monthShort: 'Jan',
    year: 2026,
    grossPay: 85000,
    netPay: 72100,
    totalDeductions: 12900,
    paidOn: '31 Jan 2026',
    status: 'paid',
    earnings: [
      _SalaryItem('Basic Salary', 42500),
      _SalaryItem('HRA', 17000),
      _SalaryItem('Special Allowance', 12750),
      _SalaryItem('Medical Allowance', 1250),
      _SalaryItem('Travel Allowance', 11500),
    ],
    deductions: [
      _SalaryItem('PF (Employee)', 5100),
      _SalaryItem('ESIC', 638),
      _SalaryItem('Professional Tax', 200),
      _SalaryItem('TDS', 6962),
    ],
  ),
  _Payslip(
    id: 'PAY-2025-12',
    month: 'December',
    monthShort: 'Dec',
    year: 2025,
    grossPay: 85000,
    netPay: 72450,
    totalDeductions: 12550,
    paidOn: '31 Dec 2025',
    status: 'paid',
    earnings: [
      _SalaryItem('Basic Salary', 42500),
      _SalaryItem('HRA', 17000),
      _SalaryItem('Special Allowance', 12750),
      _SalaryItem('Medical Allowance', 1250),
      _SalaryItem('Travel Allowance', 11500),
    ],
    deductions: [
      _SalaryItem('PF (Employee)', 5100),
      _SalaryItem('ESIC', 638),
      _SalaryItem('Professional Tax', 200),
      _SalaryItem('TDS', 6612),
    ],
  ),
  _Payslip(
    id: 'PAY-2025-11',
    month: 'November',
    monthShort: 'Nov',
    year: 2025,
    grossPay: 85000,
    netPay: 72450,
    totalDeductions: 12550,
    paidOn: '30 Nov 2025',
    status: 'paid',
    earnings: [
      _SalaryItem('Basic Salary', 42500),
      _SalaryItem('HRA', 17000),
      _SalaryItem('Special Allowance', 12750),
      _SalaryItem('Medical Allowance', 1250),
      _SalaryItem('Travel Allowance', 11500),
    ],
    deductions: [
      _SalaryItem('PF (Employee)', 5100),
      _SalaryItem('ESIC', 638),
      _SalaryItem('Professional Tax', 200),
      _SalaryItem('TDS', 6612),
    ],
  ),
];

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────
String _fmtCurrency(double v) {
  if (v >= 100000) {
    return '₹${(v / 100000).toStringAsFixed(2)}L';
  }
  final parts = v.toInt().toString().split('');
  final result = StringBuffer();
  for (int i = 0; i < parts.length; i++) {
    if (i > 0) {
      final fromEnd = parts.length - i;
      if (fromEnd == 3 || (fromEnd > 3 && (fromEnd - 3) % 2 == 0)) {
        result.write(',');
      }
    }
    result.write(parts[i]);
  }
  return '₹$result';
}

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class PayslipScreen extends StatefulWidget {
  const PayslipScreen({super.key});

  @override
  State<PayslipScreen> createState() => _PayslipScreenState();
}

class _PayslipScreenState extends State<PayslipScreen>
    with TickerProviderStateMixin {
  int _selectedIdx = 0;
  bool _earningsExpanded = true;
  bool _deductionsExpanded = true;
  bool _downloading = false;
  double _downloadProgress = 0;

  // Bar animation
  late final AnimationController _barCtrl;
  late final Animation<double> _barAnim;

  _Payslip get _selected => _mockPayslips[_selectedIdx];

  @override
  void initState() {
    super.initState();
    _barCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _barAnim = CurvedAnimation(parent: _barCtrl, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _barCtrl.forward();
    });
  }

  @override
  void dispose() {
    _barCtrl.dispose();
    super.dispose();
  }

  void _selectPayslip(int idx) {
    if (idx == _selectedIdx) return;
    setState(() => _selectedIdx = idx);
    _barCtrl.reset();
    _barCtrl.forward();
  }

  // ── Download ────────────────────────────────
  Future<void> _download() async {
    if (_downloading) return;
    setState(() {
      _downloading = true;
      _downloadProgress = 0;
    });
    for (int i = 1; i <= 30; i++) {
      await Future.delayed(const Duration(milliseconds: 55));
      if (!mounted) return;
      setState(() => _downloadProgress = i / 30);
    }
    setState(() {
      _downloading = false;
      _downloadProgress = 0;
    });
    _snack('${_selected.month} ${_selected.year} payslip downloaded ✅',
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 48),
        children: [
          _buildMonthSelector(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(children: [
              _buildPayslipCard(),
              const SizedBox(height: 14),
              _buildEarningsCard(),
              const SizedBox(height: 10),
              _buildDeductionsCard(),
              const SizedBox(height: 14),
              _buildSalaryBar(),
              const SizedBox(height: 14),
              _buildYTDCard(),
              const SizedBox(height: 14),
              _buildActionButtons(),
            ]),
          ),
          const SizedBox(height: 16),
          _buildAllPayslipsList(),
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
        title: const Text('Payslip',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility_outlined, size: 20),
            color: _C.textSec,
            onPressed: () => _showPayslipPreview(),
            tooltip: 'Preview',
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            color: _C.textSec,
            onPressed: () => _snack('Payslip shared via email', _C.textSec),
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
  // MONTH SELECTOR
  // ─────────────────────────────────────────────
  Widget _buildMonthSelector() {
    return Container(
      color: _C.card,
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
      child: SizedBox(
        height: 86,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _mockPayslips.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final p = _mockPayslips[i];
            final active = i == _selectedIdx;
            return GestureDetector(
              onTap: () => _selectPayslip(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 80,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? _C.primary : _C.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: active ? _C.primary : _C.border,
                    width: active ? 0 : 1,
                  ),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: _C.primary.withValues(alpha: .3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(p.monthShort,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: active ? Colors.white : _C.textPrimary)),
                    const SizedBox(height: 2),
                    Text('${p.year}',
                        style: TextStyle(
                            fontSize: 10,
                            color: active ? Colors.white70 : _C.textSec)),
                    const SizedBox(height: 6),
                    // Net pay
                    Text(
                      p.status == 'paid' ? 'Paid' : 'Pending',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: active
                              ? Colors.white60
                              : p.status == 'paid'
                                  ? _C.successDark
                                  : _C.warningDark),
                    ),
                    // Paid dot
                    const SizedBox(height: 3),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active
                            ? Colors.white
                            : p.status == 'paid'
                                ? _C.success
                                : _C.warning,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MAIN PAYSLIP CARD
  // ─────────────────────────────────────────────
  Widget _buildPayslipCard() {
    final p = _selected;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${p.month} ${p.year}',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.3)),
              const SizedBox(height: 2),
              Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(children: [
                    const Icon(Icons.check_circle_outline_rounded,
                        size: 11, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text('Paid on ${p.paidOn}',
                        style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500)),
                  ]),
                ),
              ]),
            ]),
            const Spacer(),
            // Employee mini info
            const Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('Amit Patil',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              Text('ISF-2024-0042',
                  style: TextStyle(fontSize: 10, color: Colors.white60)),
              Text('Full Stack Developer',
                  style: TextStyle(fontSize: 10, color: Colors.white60)),
            ]),
          ]),
        ),

        // 3 stat cards
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
          child: Row(children: [
            _payCard('Gross Pay', p.grossPay, Colors.white.withValues(alpha: .12),
                Colors.white,
                icon: Icons.account_balance_wallet_outlined),
            const SizedBox(width: 8),
            _payCard('Deductions', p.totalDeductions,
                Colors.red.withValues(alpha: .25), Colors.redAccent.shade100,
                icon: Icons.remove_circle_outline_rounded),
            const SizedBox(width: 8),
            _payCard('Net Pay', p.netPay, Colors.white.withValues(alpha: .18),
                Colors.white,
                icon: Icons.payments_outlined, isMain: true),
          ]),
        ),
      ]),
    );
  }

  Widget _payCard(String label, double amount, Color bg, Color textColor,
          {IconData? icon, bool isMain = false}) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null)
                Icon(icon, size: 15, color: textColor.withValues(alpha: .7)),
              if (icon != null) const SizedBox(height: 6),
              Text(
                _fmtCurrency(amount),
                style: TextStyle(
                    fontSize: isMain ? 15 : 13,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.5),
              ),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: textColor.withValues(alpha: .7))),
            ],
          ),
        ),
      );

  // ─────────────────────────────────────────────
  // EARNINGS CARD
  // ─────────────────────────────────────────────
  Widget _buildEarningsCard() {
    final p = _selected;
    return _BreakdownCard(
      title: 'Earnings',
      total: p.grossPay,
      items: p.earnings,
      color: _C.successDark,
      bg: _C.successLight,
      icon: Icons.add_circle_outline_rounded,
      totalLabel: 'Total Earnings',
      expanded: _earningsExpanded,
      onToggle: () => setState(() => _earningsExpanded = !_earningsExpanded),
    );
  }

  // ─────────────────────────────────────────────
  // DEDUCTIONS CARD
  // ─────────────────────────────────────────────
  Widget _buildDeductionsCard() {
    final p = _selected;
    return _BreakdownCard(
      title: 'Deductions',
      total: p.totalDeductions,
      items: p.deductions,
      color: _C.error,
      bg: _C.errorLight,
      icon: Icons.remove_circle_outline_rounded,
      totalLabel: 'Total Deductions',
      expanded: _deductionsExpanded,
      onToggle: () =>
          setState(() => _deductionsExpanded = !_deductionsExpanded),
    );
  }

  // ─────────────────────────────────────────────
  // SALARY BAR
  // ─────────────────────────────────────────────
  Widget _buildSalaryBar() {
    final p = _selected;
    final netPct = p.grossPay > 0 ? p.netPay / p.grossPay : 0.0;
    final dedPct = p.grossPay > 0 ? p.totalDeductions / p.grossPay : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Salary Breakdown',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary)),
          const SizedBox(height: 14),

          // Animated bar
          AnimatedBuilder(
            animation: _barAnim,
            builder: (_, __) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 20,
                child: Row(children: [
                  Expanded(
                    flex: (netPct * 100 * _barAnim.value).round(),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: netPct > 0.3
                          ? const Text('Net',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white))
                          : null,
                    ),
                  ),
                  Expanded(
                    flex: (dedPct * 100 * _barAnim.value).round(),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: dedPct > 0.1
                          ? const Text('Ded.',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white))
                          : null,
                    ),
                  ),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _barLegend(
                  'Net Pay',
                  '${(netPct * 100).round()}%  (${_fmtCurrency(p.netPay)})',
                  _C.successDark,
                  _C.successLight),
              _barLegend(
                  'Deductions',
                  '${(dedPct * 100).round()}%  (${_fmtCurrency(p.totalDeductions)})',
                  _C.error,
                  _C.errorLight),
            ],
          ),
        ],
      ),
    );
  }

  Widget _barLegend(String label, String value, Color color, Color bg) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 10, color: _C.textSec)),
          Text(value,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ]),
      ]);

  // ─────────────────────────────────────────────
  // YEAR-TO-DATE CARD
  // ─────────────────────────────────────────────
  Widget _buildYTDCard() {
    // Sum all 2026 payslips
    final ytdSlips = _mockPayslips.where((p) => p.year == 2026).toList();
    final ytdGross = ytdSlips.fold(0.0, (s, p) => s + p.grossPay);
    final ytdNet = ytdSlips.fold(0.0, (s, p) => s + p.netPay);
    final ytdTDS = ytdSlips.fold(0.0, (s, p) {
      final tds = p.deductions.firstWhere((d) => d.label.contains('TDS'),
          orElse: () => const _SalaryItem('TDS', 0));
      return s + tds.amount;
    });
    final ytdPF = ytdSlips.fold(0.0, (s, p) {
      final pf = p.deductions.firstWhere((d) => d.label.contains('PF'),
          orElse: () => const _SalaryItem('PF', 0));
      return s + pf.amount;
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                  color: _C.primaryLight,
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.bar_chart_rounded,
                  size: 16, color: _C.primary),
            ),
            const SizedBox(width: 8),
            const Text('Year to Date (2026)',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary)),
            const Spacer(),
            Text('${ytdSlips.length} months',
                style: const TextStyle(fontSize: 11, color: _C.textSec)),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            _ytdStat('Gross Income', ytdGross, _C.primary, _C.primaryLight),
            const SizedBox(width: 8),
            _ytdStat('Net Income', ytdNet, _C.successDark, _C.successLight),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            _ytdStat('TDS Paid', ytdTDS, _C.error, _C.errorLight),
            const SizedBox(width: 8),
            _ytdStat('PF Paid', ytdPF, _C.warningDark, _C.warningLight),
          ]),
        ],
      ),
    );
  }

  Widget _ytdStat(String label, double amount, Color color, Color bg) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration:
              BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_fmtCurrency(amount),
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: -0.5)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 10, color: _C.textSec)),
          ]),
        ),
      );

  // ─────────────────────────────────────────────
  // ACTION BUTTONS
  // ─────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Column(children: [
      // Download button
      SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _downloading ? null : _download,
          style: ElevatedButton.styleFrom(
            backgroundColor: _C.primary,
            disabledBackgroundColor: _C.primaryLight,
            foregroundColor: Colors.white,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _downloading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: _downloadProgress,
                        minHeight: 5,
                        backgroundColor: Colors.white.withValues(alpha: .3),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(_downloadProgress * 100).toInt()}%  Downloading…',
                      style: const TextStyle(fontSize: 11, color: _C.primary),
                    ),
                  ],
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.download_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Download PDF',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ],
                ),
        ),
      ),
      const SizedBox(height: 10),

      // Email + Preview row
      Row(children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () =>
                _snack('Payslip emailed to amit.patil@isf.com', _C.textSec),
            icon: const Icon(Icons.email_outlined, size: 17),
            label: const Text('Email'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _C.textSec,
              side: const BorderSide(color: _C.border, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showPayslipPreview,
            icon: const Icon(Icons.visibility_outlined, size: 17),
            label: const Text('Preview'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _C.primary,
              side: const BorderSide(color: _C.primary, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ]),
    ]);
  }

  // ─────────────────────────────────────────────
  // ALL PAYSLIPS LIST
  // ─────────────────────────────────────────────
  Widget _buildAllPayslipsList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                  color: _C.primaryLight,
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.receipt_long_outlined,
                  size: 15, color: _C.primary),
            ),
            const SizedBox(width: 8),
            const Text('All Payslips',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary)),
            const Spacer(),
            Text('${_mockPayslips.length} records',
                style: const TextStyle(fontSize: 11, color: _C.textSec)),
          ]),
        ),
        Container(height: 1, color: _C.border),

        // Payslip rows
        ..._mockPayslips.asMap().entries.map((e) {
          final i = e.key;
          final p = e.value;
          final isSelected = i == _selectedIdx;
          final isLast = i == _mockPayslips.length - 1;

          return Column(children: [
            InkWell(
              onTap: () {
                _selectPayslip(i);
                // Scroll to top
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: isSelected ? _C.primaryLight : Colors.transparent,
                child: Row(children: [
                  // Month badge
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected ? _C.primary : _C.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(p.monthShort,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color:
                                    isSelected ? Colors.white : _C.textPrimary,
                                height: 1.1)),
                        Text('${p.year}',
                            style: TextStyle(
                                fontSize: 9,
                                color:
                                    isSelected ? Colors.white70 : _C.textSec)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Info
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${p.month} ${p.year}',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? _C.primary : _C.textPrimary)),
                      const SizedBox(height: 2),
                      Text('Net: ${_fmtCurrency(p.netPay)}',
                          style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? _C.primary : _C.textSec)),
                    ],
                  )),

                  // Status + paid on
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: p.status == 'paid'
                            ? _C.successLight
                            : _C.warningLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        p.status == 'paid' ? 'Paid ✓' : 'Pending',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: p.status == 'paid'
                                ? _C.successDark
                                : _C.warningDark),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(p.paidOn,
                        style:
                            const TextStyle(fontSize: 9, color: _C.textTert)),
                  ]),

                  const SizedBox(width: 8),
                  // Download icon
                  GestureDetector(
                    onTap: () {
                      _selectPayslip(i);
                      _download();
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isSelected ? _C.primary : _C.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.download_outlined,
                          size: 16,
                          color: isSelected ? Colors.white : _C.textSec),
                    ),
                  ),
                ]),
              ),
            ),
            if (!isLast)
              Container(
                  height: 1,
                  color: _C.border,
                  margin: const EdgeInsets.symmetric(horizontal: 16)),
          ]);
        }),
      ]),
    );
  }

  // ─────────────────────────────────────────────
  // PAYSLIP PREVIEW SHEET
  // ─────────────────────────────────────────────
  void _showPayslipPreview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, ctrl) => _PayslipPreview(
          payslip: _selected,
          scrollCtrl: ctrl,
          onDownload: () {
            Navigator.pop(context);
            _download();
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BREAKDOWN CARD (Earnings / Deductions)
// ─────────────────────────────────────────────
class _BreakdownCard extends StatelessWidget {
  final String title;
  final double total;
  final List<_SalaryItem> items;
  final Color color;
  final Color bg;
  final IconData icon;
  final String totalLabel;
  final bool expanded;
  final VoidCallback onToggle;

  const _BreakdownCard({
    required this.title,
    required this.total,
    required this.items,
    required this.color,
    required this.bg,
    required this.icon,
    required this.totalLabel,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: Column(children: [
        // Header (always visible)
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.vertical(
              top: const Radius.circular(16),
              bottom: expanded ? Radius.zero : const Radius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    color: bg, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _C.textPrimary)),
                    Text('${items.length} components',
                        style:
                            const TextStyle(fontSize: 11, color: _C.textSec)),
                  ],
                ),
              ),
              Text(_fmtCurrency(total),
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800, color: color)),
              const SizedBox(width: 8),
              AnimatedRotation(
                turns: expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.keyboard_arrow_down_rounded,
                    size: 20, color: _C.textSec),
              ),
            ]),
          ),
        ),

        // Expandable content
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          child: expanded
              ? Column(children: [
                  Container(height: 1, color: _C.border),
                  ...items.asMap().entries.map((e) {
                    final i = e.key;
                    final item = e.value;
                    final pct = total > 0 ? item.amount / total : 0.0;
                    final isLast = i == items.length - 1;

                    return Column(children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 11),
                        child: Column(children: [
                          Row(children: [
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.label,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: _C.textPrimary)),
                                if (item.note != null)
                                  Text(item.note!,
                                      style: const TextStyle(
                                          fontSize: 10, color: _C.textTert)),
                              ],
                            )),
                            Text(_fmtCurrency(item.amount),
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: color)),
                          ]),
                          const SizedBox(height: 6),
                          Row(children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  minHeight: 4,
                                  backgroundColor: bg,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      color.withValues(alpha: .6)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${(pct * 100).round()}%',
                                style: const TextStyle(
                                    fontSize: 10, color: _C.textTert)),
                          ]),
                        ]),
                      ),
                      if (!isLast)
                        Container(
                            height: 1,
                            color: _C.border,
                            margin: const EdgeInsets.symmetric(horizontal: 16)),
                    ]);
                  }),

                  // Total footer
                  Container(height: 1, color: _C.border),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(totalLabel,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _C.textPrimary)),
                        Text(_fmtCurrency(total),
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: color)),
                      ],
                    ),
                  ),
                ])
              : const SizedBox.shrink(),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// PAYSLIP PREVIEW SHEET
// ─────────────────────────────────────────────
class _PayslipPreview extends StatelessWidget {
  final _Payslip payslip;
  final ScrollController scrollCtrl;
  final VoidCallback onDownload;

  const _PayslipPreview({
    required this.payslip,
    required this.scrollCtrl,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final p = payslip;
    return Container(
      color: _C.card,
      child: Column(children: [
        // Handle + header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: _C.border,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 14),
            Row(children: [
              const Text('Payslip Preview',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary)),
              const Spacer(),
              TextButton.icon(
                onPressed: onDownload,
                icon: const Icon(Icons.download_outlined, size: 16),
                label: const Text('Download'),
                style: TextButton.styleFrom(foregroundColor: _C.primary),
              ),
            ]),
          ]),
        ),
        Container(height: 1, color: _C.border),

        // Payslip document
        Expanded(
          child: ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.all(20),
            children: [
              // Company header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _C.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: _C.primary,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Center(
                      child: Text('ISF',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ISF Solutions Pvt. Ltd.',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _C.textPrimary)),
                      Text('Wadala, Mumbai – 400037 | CIN: U72900MH2010',
                          style: TextStyle(fontSize: 10, color: _C.textSec)),
                    ],
                  )),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    const Text('PAYSLIP',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _C.primary,
                            letterSpacing: 1)),
                    Text('${p.month} ${p.year}',
                        style:
                            const TextStyle(fontSize: 11, color: _C.textSec)),
                  ]),
                ]),
              ),
              const SizedBox(height: 14),

              // Employee details grid
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: _C.surface, borderRadius: BorderRadius.circular(12)),
                child: Column(children: [
                  _previewRow('Employee Name', 'Amit Patil'),
                  _previewRow('Employee ID', 'ISF-2024-0042'),
                  _previewRow('Designation', 'Full Stack Developer'),
                  _previewRow('Department', 'Information Technology'),
                  _previewRow('Pay Period',
                      '01 ${p.month} ${p.year} – ${_lastDayOf(p.month, p.year)} ${p.month} ${p.year}'),
                  _previewRow('Payment Date', p.paidOn, isLast: true),
                ]),
              ),
              const SizedBox(height: 14),

              // Earnings table
              _previewSection(
                  'EARNINGS', p.earnings, _C.successDark, p.grossPay),
              const SizedBox(height: 10),

              // Deductions table
              _previewSection(
                  'DEDUCTIONS', p.deductions, _C.error, p.totalDeductions),
              const SizedBox(height: 14),

              // Net pay footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1D4ED8), Color(0xFF0D9488)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('NET PAY',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white70,
                                letterSpacing: 1)),
                        Text('Take-home salary',
                            style:
                                TextStyle(fontSize: 10, color: Colors.white54)),
                      ],
                    ),
                    Text(_fmtCurrency(p.netPay),
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -1)),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Note
              const Text(
                '* This is a computer-generated payslip and does not require a signature. '
                'For queries, contact payroll@isf.com',
                style: TextStyle(fontSize: 10, color: _C.textTert, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _previewRow(String label, String value, {bool isLast = false}) =>
      Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 12, color: _C.textSec)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _C.textPrimary)),
            ],
          ),
        ),
        if (!isLast) Container(height: 1, color: _C.border),
      ]);

  Widget _previewSection(
      String title, List<_SalaryItem> items, Color color, double total) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _C.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .08),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                      letterSpacing: 0.5)),
              const Text('Amount (₹)',
                  style: TextStyle(fontSize: 11, color: _C.textSec)),
            ],
          ),
        ),
        ...items.asMap().entries.map((e) {
          return Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.value.label,
                            style: const TextStyle(
                                fontSize: 12, color: _C.textPrimary)),
                        if (e.value.note != null)
                          Text(e.value.note!,
                              style: const TextStyle(
                                  fontSize: 10, color: _C.textTert)),
                      ]),
                  Text(_fmtCurrency(e.value.amount),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _C.textPrimary)),
                ],
              ),
            ),
            Container(
                height: 1,
                color: _C.border,
                margin: const EdgeInsets.symmetric(horizontal: 14)),
          ]);
        }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total ${title == 'EARNINGS' ? 'Earnings' : 'Deductions'}',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: color)),
              Text(_fmtCurrency(total),
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w800, color: color)),
            ],
          ),
        ),
      ]),
    );
  }

  String _lastDayOf(String month, int year) {
    const days = {
      'January': '31',
      'February': '28',
      'March': '31',
      'April': '30',
      'May': '31',
      'June': '30',
      'July': '31',
      'August': '31',
      'September': '30',
      'October': '31',
      'November': '30',
      'December': '31',
    };
    return days[month] ?? '30';
  }
}
