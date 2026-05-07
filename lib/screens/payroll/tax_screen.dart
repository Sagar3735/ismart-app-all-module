// ============================================================
// ISF HR Portal — Tax / IT Declaration Screen
// File: lib/screens/payroll/tax_screen.dart
//
// Features:
//   - Tax regime selector (Old vs New) with comparison
//   - Annual income summary card
//   - Section-wise declaration (80C / 80D / HRA / 80G / others)
//   - Each section expandable with individual investment fields
//   - Real-time tax liability calculation as user fills
//   - Submit declaration with confirmation dialog
//   - TDS history table (monthly)
//   - Form 16 download
//   - Tax tips info card
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
// MODELS
// ─────────────────────────────────────────────
enum _Regime { old, newRegime }

class _InvestmentField {
  final String id;
  final String label;
  final String hint;
  final double maxLimit;
  final TextEditingController ctrl;

  _InvestmentField({
    required this.id,
    required this.label,
    required this.hint,
    required this.maxLimit,
  }) : ctrl = TextEditingController();

  double get value => double.tryParse(ctrl.text.replaceAll(',', '')) ?? 0;

  void dispose() => ctrl.dispose();
}

class _DeclarationSection {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bg;
  final double maxLimit;
  final List<_InvestmentField> fields;
  bool expanded = false;

  _DeclarationSection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bg,
    required this.maxLimit,
    required this.fields,
  });

  double get totalDeclared => fields.fold(0.0, (s, f) => s + f.value);
  double get claimedAmount => totalDeclared.clamp(0, maxLimit);
}

class _TDSRecord {
  final String month;
  final double gross;
  final double tds;
  const _TDSRecord(this.month, this.gross, this.tds);
}

// ─────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────
const _annualGross = 1020000.0; // ₹10.2L
const _annualBasic = 510000.0;
const _annualHRA = 204000.0;
const _standardDeduct = 50000.0;

const _tdsHistory = [
  _TDSRecord('Apr 2026', 85000, 6612),
  _TDSRecord('Mar 2026', 85000, 6612),
  _TDSRecord('Feb 2026', 85000, 6612),
  _TDSRecord('Jan 2026', 85000, 6962),
  _TDSRecord('Dec 2025', 85000, 6612),
  _TDSRecord('Nov 2025', 85000, 6612),
];

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────
String _fmtCurrency(double v) {
  if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(2)}L';
  if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(1)}K';
  return '₹${v.toStringAsFixed(0)}';
}

String _fmtFull(double v) {
  if (v == 0) return '₹0';
  final s = v.abs().toInt().toString();
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

// Tax calculation (simplified old regime)
double _calcTax(double taxableIncome) {
  if (taxableIncome <= 250000) return 0;
  if (taxableIncome <= 500000) return (taxableIncome - 250000) * 0.05;
  if (taxableIncome <= 1000000) {
    return 12500 + (taxableIncome - 500000) * 0.20;
  }
  return 112500 + (taxableIncome - 1000000) * 0.30;
}

double _calcNewTax(double taxableIncome) {
  // New regime FY 2025-26 slabs
  if (taxableIncome <= 300000) return 0;
  if (taxableIncome <= 700000) return (taxableIncome - 300000) * 0.05;
  if (taxableIncome <= 1000000) return 20000 + (taxableIncome - 700000) * 0.10;
  if (taxableIncome <= 1200000) return 50000 + (taxableIncome - 1000000) * 0.15;
  if (taxableIncome <= 1500000) return 80000 + (taxableIncome - 1200000) * 0.20;
  return 140000 + (taxableIncome - 1500000) * 0.30;
}

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class TaxScreen extends StatefulWidget {
  const TaxScreen({super.key});

  @override
  State<TaxScreen> createState() => _TaxScreenState();
}

class _TaxScreenState extends State<TaxScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  _Regime _regime = _Regime.old;
  bool _submitting = false;
  bool _submitted = false;

  // ── Declaration sections ─────────────────────
  late final List<_DeclarationSection> _sections;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _sections = _buildSections();
    // Prefill some mock values
    _sections[0].fields[0].ctrl.text = '75000'; // PPF
    _sections[0].fields[1].ctrl.text = '50000'; // ELSS
    _sections[0].fields[2].ctrl.text = '20000'; // LIC
    _sections[1].fields[0].ctrl.text = '15000'; // Mediclaim self
    _sections[2].fields[0].ctrl.text = '204000'; // HRA exemption
  }

  List<_DeclarationSection> _buildSections() => [
        _DeclarationSection(
          id: '80c',
          title: 'Section 80C',
          subtitle: 'Investments & savings',
          icon: Icons.savings_outlined,
          color: _C.primary,
          bg: _C.primaryLight,
          maxLimit: 150000,
          fields: [
            _InvestmentField(
                id: 'ppf',
                label: 'PPF',
                hint: 'Amount invested',
                maxLimit: 150000),
            _InvestmentField(
                id: 'elss',
                label: 'ELSS Mutual Fund',
                hint: 'Amount invested',
                maxLimit: 150000),
            _InvestmentField(
                id: 'lic',
                label: 'LIC / Term Premium',
                hint: 'Annual premium',
                maxLimit: 150000),
            _InvestmentField(
                id: 'nsc',
                label: 'NSC',
                hint: 'Amount invested',
                maxLimit: 150000),
            _InvestmentField(
                id: 'epf',
                label: 'Employee PF (auto)',
                hint: 'Auto-populated',
                maxLimit: 150000),
            _InvestmentField(
                id: 'tuition',
                label: 'Tuition Fees',
                hint: 'Children\'s fees',
                maxLimit: 150000),
            _InvestmentField(
                id: 'homeloan80c',
                label: 'Home Loan Principal',
                hint: 'Principal repaid',
                maxLimit: 150000),
          ],
        ),
        _DeclarationSection(
          id: '80d',
          title: 'Section 80D',
          subtitle: 'Health insurance premium',
          icon: Icons.health_and_safety_outlined,
          color: _C.error,
          bg: _C.errorLight,
          maxLimit: 50000,
          fields: [
            _InvestmentField(
                id: 'medself',
                label: 'Mediclaim – Self & Family',
                hint: 'Annual premium',
                maxLimit: 25000),
            _InvestmentField(
                id: 'medparent',
                label: 'Mediclaim – Parents',
                hint: 'Annual premium',
                maxLimit: 25000),
            _InvestmentField(
                id: 'prevcheck',
                label: 'Preventive Health Check',
                hint: 'Max ₹5,000',
                maxLimit: 5000),
          ],
        ),
        _DeclarationSection(
          id: 'hra',
          title: 'HRA Exemption',
          subtitle: 'House Rent Allowance',
          icon: Icons.home_outlined,
          color: _C.teal,
          bg: _C.tealLight,
          maxLimit: 204000,
          fields: [
            _InvestmentField(
                id: 'hraexempt',
                label: 'HRA Exemption Claimed',
                hint: 'Auto-calculated',
                maxLimit: 204000),
            _InvestmentField(
                id: 'rentpaid',
                label: 'Annual Rent Paid',
                hint: 'Total rent paid',
                maxLimit: 999999),
          ],
        ),
        _DeclarationSection(
          id: '80e',
          title: 'Section 80E',
          subtitle: 'Education loan interest',
          icon: Icons.school_outlined,
          color: _C.purple,
          bg: _C.purpleLight,
          maxLimit: 999999,
          fields: [
            _InvestmentField(
                id: 'edloan',
                label: 'Education Loan Interest',
                hint: 'Interest paid (no limit)',
                maxLimit: 999999),
          ],
        ),
        _DeclarationSection(
          id: '80g',
          title: 'Section 80G',
          subtitle: 'Donations to charities',
          icon: Icons.volunteer_activism_outlined,
          color: _C.orange,
          bg: _C.orangeLight,
          maxLimit: 999999,
          fields: [
            _InvestmentField(
                id: 'donation100',
                label: 'Donations (100% deduction)',
                hint: 'Amount donated',
                maxLimit: 999999),
            _InvestmentField(
                id: 'donation50',
                label: 'Donations (50% deduction)',
                hint: 'Amount donated',
                maxLimit: 999999),
          ],
        ),
        _DeclarationSection(
          id: '80tta',
          title: 'Section 80TTA / 24B',
          subtitle: 'Interest & home loan',
          icon: Icons.account_balance_outlined,
          color: _C.accent,
          bg: _C.accentLight,
          maxLimit: 200000,
          fields: [
            _InvestmentField(
                id: 'savingint',
                label: 'Savings A/C Interest (80TTA)',
                hint: 'Max ₹10,000',
                maxLimit: 10000),
            _InvestmentField(
                id: 'homeloan24',
                label: 'Home Loan Interest (24B)',
                hint: 'Max ₹2,00,000',
                maxLimit: 200000),
          ],
        ),
      ];

  @override
  void dispose() {
    _tabCtrl.dispose();
    for (final s in _sections) {
      for (final f in s.fields) {
        f.dispose();
      }
    }
    super.dispose();
  }

  // ── Tax calculation ───────────────────────────
  double get _totalDeductions {
    final deduct80c = _sections.firstWhere((s) => s.id == '80c').claimedAmount;
    final deduct80d = _sections.firstWhere((s) => s.id == '80d').claimedAmount;
    final deductHRA = _sections.firstWhere((s) => s.id == 'hra').claimedAmount;
    final deduct80e = _sections.firstWhere((s) => s.id == '80e').claimedAmount;
    final deduct80g = _sections.firstWhere((s) => s.id == '80g').claimedAmount;
    final deduct80tt =
        _sections.firstWhere((s) => s.id == '80tta').claimedAmount;
    return deduct80c +
        deduct80d +
        deductHRA +
        deduct80e +
        deduct80g +
        deduct80tt +
        _standardDeduct;
  }

  double get _taxableIncome =>
      (_annualGross - _totalDeductions).clamp(0, double.infinity);

  double get _estimatedTax => _regime == _Regime.old
      ? _calcTax(_taxableIncome)
      : _calcNewTax(_annualGross - _standardDeduct);

  double get _estimatedCess => _estimatedTax * 0.04;
  double get _totalTaxLiability => _estimatedTax + _estimatedCess;
  double get _tdsPaid => _tdsHistory.fold(0.0, (s, t) => s + t.tds);
  double get _taxBalance => _totalTaxLiability - _tdsPaid;

  // New regime (simplified)
  double get _newRegimeTax =>
      _calcNewTax(_annualGross - _standardDeduct) * 1.04;

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

  void _showSubmitDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Submit IT Declaration?',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _dialogRow(
              'Regime', _regime == _Regime.old ? 'Old Regime' : 'New Regime'),
          _dialogRow('Gross Income', _fmtFull(_annualGross)),
          _dialogRow('Deductions', _fmtFull(_totalDeductions)),
          _dialogRow('Taxable Income', _fmtFull(_taxableIncome)),
          _dialogRow('Tax Liability', _fmtFull(_totalTaxLiability)),
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
                'Once submitted, changes require HR approval. Deadline: 15 Dec.',
                style:
                    TextStyle(fontSize: 11, color: _C.warningDark, height: 1.4),
              )),
            ]),
          ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: _C.textSec))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitDeclaration();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _dialogRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(fontSize: 13, color: _C.textSec)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary)),
        ]),
      );

  Future<void> _submitDeclaration() async {
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _submitted = true;
    });
    _snack('IT Declaration submitted ✅ — Processing by HR', _C.successDark);
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
              _buildDeclarationTab(),
              _buildTDSTab(),
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
        title: const Text('Tax / IT Declaration',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        actions: [
          if (_submitted)
            Container(
              margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: _C.successLight,
                  borderRadius: BorderRadius.circular(20)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.check_circle_outline_rounded,
                    size: 12, color: _C.successDark),
                SizedBox(width: 4),
                Text('Submitted',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _C.successDark)),
              ]),
            ),
          IconButton(
            icon: const Icon(Icons.download_outlined, size: 21),
            color: _C.textSec,
            onPressed: () => _snack('Form 16 downloaded ✅', _C.successDark),
            tooltip: 'Download Form 16',
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
          tabs: const [Tab(text: 'IT Declaration'), Tab(text: 'TDS Summary')],
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
  // TAB 1: DECLARATION
  // ─────────────────────────────────────────────
  Widget _buildDeclarationTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
      children: [
        // FY badge + deadline
        _DeadlineBanner(submitted: _submitted),
        const SizedBox(height: 14),

        // Regime selector
        _buildRegimeSelector(),
        const SizedBox(height: 16),

        // Income summary
        _buildIncomeSummary(),
        const SizedBox(height: 16),

        // Tax estimate live card
        _buildTaxEstimateCard(),
        const SizedBox(height: 16),

        // Section declarations
        const Text('Declare Investments',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _C.textPrimary)),
        const SizedBox(height: 10),
        ..._sections.asMap().entries.map((e) => Column(children: [
              _buildSectionCard(e.value),
              const SizedBox(height: 10),
            ])),

        // Submit button
        _buildSubmitButton(),
        const SizedBox(height: 16),

        // Tax tips
        _buildTaxTips(),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // REGIME SELECTOR
  // ─────────────────────────────────────────────
  Widget _buildRegimeSelector() {
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
                  color: _C.primaryLight,
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.compare_arrows_rounded,
                  size: 16, color: _C.primary),
            ),
            const SizedBox(width: 10),
            const Text('Choose Tax Regime',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                  color: _C.orangeLight,
                  borderRadius: BorderRadius.circular(20)),
              child: const Text('FY 2026-27',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _C.orange)),
            ),
          ]),
        ),
        Container(height: 1, color: _C.border),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            Row(children: [
              Expanded(
                  child: _regimeCard(
                _Regime.old,
                'Old Regime',
                'With Deductions',
                Icons.receipt_long_outlined,
                _totalTaxLiability,
                _C.primary,
                _C.primaryLight,
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: _regimeCard(
                _Regime.newRegime,
                'New Regime',
                'No Deductions',
                Icons.flash_on_outlined,
                _newRegimeTax,
                _C.teal,
                _C.tealLight,
              )),
            ]),
            const SizedBox(height: 10),
            // Recommendation banner
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: _totalTaxLiability < _newRegimeTax
                    ? _C.primaryLight
                    : _C.tealLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _totalTaxLiability < _newRegimeTax
                      ? _C.primary.withValues(alpha: .3)
                      : _C.teal.withValues(alpha: .3),
                ),
              ),
              child: Row(children: [
                Icon(Icons.tips_and_updates_outlined,
                    size: 15,
                    color: _totalTaxLiability < _newRegimeTax
                        ? _C.primary
                        : _C.teal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _totalTaxLiability < _newRegimeTax
                        ? 'Old Regime saves you ${_fmtFull(_newRegimeTax - _totalTaxLiability)} more — keep your current choice.'
                        : 'New Regime saves you ${_fmtFull(_totalTaxLiability - _newRegimeTax)} — consider switching!',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.4,
                      color: _totalTaxLiability < _newRegimeTax
                          ? _C.primary
                          : _C.teal,
                    ),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _regimeCard(_Regime regime, String title, String sub, IconData icon,
      double tax, Color color, Color bg) {
    final active = _regime == regime;
    return GestureDetector(
      onTap: () => setState(() => _regime = regime),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active ? color : _C.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? color : _C.border,
            width: active ? 0 : 1,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                      color: color.withValues(alpha: .3),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, size: 18, color: active ? Colors.white : color),
            const Spacer(),
            if (active)
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.check_rounded, size: 11, color: color),
              ),
          ]),
          const SizedBox(height: 10),
          Text(title,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : _C.textPrimary)),
          Text(sub,
              style: TextStyle(
                  fontSize: 9, color: active ? Colors.white60 : _C.textSec)),
          const SizedBox(height: 8),
          Text(_fmtFull(tax),
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: active ? Colors.white : color,
                  letterSpacing: -0.5)),
          Text('Est. Tax + Cess',
              style: TextStyle(
                  fontSize: 9, color: active ? Colors.white60 : _C.textTert)),
        ]),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // INCOME SUMMARY
  // ─────────────────────────────────────────────
  Widget _buildIncomeSummary() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 16, color: Colors.white70),
          SizedBox(width: 8),
          Text('Annual Income Summary',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 12),
        Text(_fmtFull(_annualGross),
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -1,
                height: 1)),
        const Text('Gross Annual Income',
            style: TextStyle(fontSize: 11, color: Colors.white54)),
        const SizedBox(height: 14),
        Row(children: [
          _incomeRow('Basic Salary', _fmtFull(_annualBasic)),
          _incomeDivider(),
          _incomeRow('HRA', _fmtFull(_annualHRA)),
          _incomeDivider(),
          _incomeRow('Other Allow.',
              _fmtFull(_annualGross - _annualBasic - _annualHRA)),
        ]),
      ]),
    );
  }

  Widget _incomeRow(String label, String value) => Expanded(
        child: Column(children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9, color: Colors.white54)),
        ]),
      );

  Widget _incomeDivider() => Container(
      width: 1,
      height: 28,
      color: Colors.white.withValues(alpha: .2),
      margin: const EdgeInsets.symmetric(horizontal: 4));

  // ─────────────────────────────────────────────
  // TAX ESTIMATE CARD (live)
  // ─────────────────────────────────────────────
  Widget _buildTaxEstimateCard() {
    final taxable = _taxableIncome;
    final tax = _estimatedTax;
    final cess = _estimatedCess;
    final total = _totalTaxLiability;
    final balance = _taxBalance;
    final isRefund = balance < 0;

    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Column(children: [
        const _SectionHdr('Tax Liability Estimate', Icons.calculate_outlined,
            _C.accent, _C.accentLight),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            // Computation rows
            _computeRow('Gross Income', _annualGross, _C.textPrimary,
                isBold: true),
            _computeRow('Standard Deduction', -_standardDeduct, _C.successDark),
            _computeRow(
                '80C Deductions', -_sections[0].claimedAmount, _C.successDark),
            _computeRow(
                '80D Deductions', -_sections[1].claimedAmount, _C.successDark),
            _computeRow(
                'HRA Exemption', -_sections[2].claimedAmount, _C.successDark),
            if (_sections[3].claimedAmount > 0)
              _computeRow(
                  '80E / Other',
                  -(_sections[3].claimedAmount +
                      _sections[4].claimedAmount +
                      _sections[5].claimedAmount),
                  _C.successDark),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Divider(color: _C.border),
            ),
            _computeRow('Taxable Income', taxable, _C.textPrimary,
                isBold: true),
            const SizedBox(height: 10),
            _computeRow('Income Tax', tax, _C.error),
            _computeRow('Health & Edu. Cess (4%)', cess, _C.error),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Divider(color: _C.border),
            ),
            _computeRow('Total Tax Liability', total, _C.primary, isBold: true),
            _computeRow('TDS Already Deducted', -_tdsPaid, _C.successDark),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Divider(color: _C.border, thickness: 2),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isRefund
                    ? _C.successLight
                    : balance < 1
                        ? _C.successLight
                        : _C.errorLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isRefund
                        ? '🎉 Refund Due'
                        : balance < 1
                            ? '✅ No Tax Due'
                            : '⚠️ Tax Payable',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isRefund || balance < 1
                          ? _C.successDark
                          : _C.errorDark,
                    ),
                  ),
                  Text(
                    isRefund
                        ? _fmtFull(balance.abs())
                        : _fmtFull(balance.clamp(0, double.infinity)),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isRefund || balance < 1
                          ? _C.successDark
                          : _C.errorDark,
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _computeRow(String label, double amount, Color color,
          {bool isBold = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
                  color: isBold ? _C.textPrimary : _C.textSec)),
          Text(
            '${amount < 0 ? '– ' : ''}${_fmtFull(amount.abs())}',
            style: TextStyle(
                fontSize: 12,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                color: color),
          ),
        ]),
      );

  // ─────────────────────────────────────────────
  // SECTION CARD (each 80C, 80D etc.)
  // ─────────────────────────────────────────────
  Widget _buildSectionCard(_DeclarationSection sec) {
    final claimed = sec.claimedAmount;
    final declared = sec.totalDeclared;
    final isMaxed = declared >= sec.maxLimit;
    final fillPct =
        sec.maxLimit > 0 ? (declared / sec.maxLimit).clamp(0.0, 1.0) : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: Column(children: [
        // Header (always visible)
        InkWell(
          onTap: () => setState(() => sec.expanded = !sec.expanded),
          borderRadius: BorderRadius.vertical(
              top: const Radius.circular(16),
              bottom: sec.expanded ? Radius.zero : const Radius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              Row(children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: sec.bg, borderRadius: BorderRadius.circular(10)),
                  child: Icon(sec.icon, size: 18, color: sec.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(sec.title,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _C.textPrimary)),
                      Text(sec.subtitle,
                          style:
                              const TextStyle(fontSize: 11, color: _C.textSec)),
                    ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(_fmtFull(claimed),
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: sec.color)),
                  if (sec.maxLimit < 999999)
                    Text('of ${_fmtFull(sec.maxLimit)}',
                        style:
                            const TextStyle(fontSize: 9, color: _C.textTert)),
                ]),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: sec.expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 220),
                  child: const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 20, color: _C.textSec),
                ),
              ]),
              if (sec.maxLimit < 999999) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fillPct,
                    minHeight: 5,
                    backgroundColor: sec.bg,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        isMaxed ? _C.successDark : sec.color),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${(fillPct * 100).toInt()}% utilized',
                          style: TextStyle(fontSize: 9, color: sec.color)),
                      if (isMaxed)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: _C.successLight,
                              borderRadius: BorderRadius.circular(8)),
                          child: const Text('Maxed ✓',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: _C.successDark)),
                        ),
                    ]),
              ],
            ]),
          ),
        ),

        // Expanded fields
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          child: sec.expanded
              ? Column(children: [
                  Container(height: 1, color: _C.border),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    child: Column(
                      children: sec.fields.asMap().entries.map((e) {
                        final f = e.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _InvestmentFieldWidget(
                            field: f,
                            sectionColor: sec.color,
                            onChanged: () => setState(() {}),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ])
              : const SizedBox.shrink(),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────
  // SUBMIT BUTTON
  // ─────────────────────────────────────────────
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _submitting || _submitted ? null : _showSubmitDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: _submitted ? _C.successDark : _C.primary,
          disabledBackgroundColor:
              _submitted ? _C.successLight : _C.textDisabled,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _submitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(
                    _submitted
                        ? Icons.check_circle_outline_rounded
                        : Icons.send_outlined,
                    size: 17),
                const SizedBox(width: 8),
                Text(
                  _submitted
                      ? 'Declaration Submitted'
                      : 'Submit IT Declaration',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ]),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TAX TIPS
  // ─────────────────────────────────────────────
  Widget _buildTaxTips() {
    final tips = [
      (
        'Maximize 80C',
        'Invest ₹1.5L in PPF/ELSS/LIC to save up to ₹46,800 in tax.'
      ),
      (
        '80D Top-up',
        'Pay health insurance for parents (60+) to claim extra ₹50,000 deduction.'
      ),
      (
        'NPS Sec 80CCD',
        'Additional ₹50,000 deduction via NPS (Section 80CCD(1B)).'
      ),
      (
        'HRA Docs',
        'Keep rent receipts if annual rent > ₹1L. Landlord PAN required.'
      ),
      (
        'Deadline',
        'Submit revised declaration by 15 Dec for accurate TDS adjustment.'
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Column(children: [
        const _SectionHdr('Tax Saving Tips', Icons.tips_and_updates_outlined,
            _C.warningDark, _C.warningLight),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Column(
            children: tips.asMap().entries.map((e) {
              final i = e.key;
              final (title, desc) = e.value;
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
                              color: _C.warningDark, shape: BoxShape.circle),
                        ),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(title,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: _C.textPrimary)),
                              const SizedBox(height: 2),
                              Text(desc,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: _C.textSec,
                                      height: 1.4)),
                            ])),
                      ]),
                ),
                if (i < tips.length - 1) Container(height: 1, color: _C.border),
              ]);
            }).toList(),
          ),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────
  // TAB 2: TDS SUMMARY
  // ─────────────────────────────────────────────
  Widget _buildTDSTab() {
    final totalTDS = _tdsHistory.fold(0.0, (s, t) => s + t.tds);
    final totalGross = _tdsHistory.fold(0.0, (s, t) => s + t.gross);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
      children: [
        // Summary card
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1D4ED8), Color(0xFF0D9488)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(18),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [
              Icon(Icons.receipt_long_outlined,
                  size: 16, color: Colors.white70),
              SizedBox(width: 8),
              Text('TDS Deducted (Nov 25 – Apr 26)',
                  style: TextStyle(fontSize: 12, color: Colors.white60)),
            ]),
            const SizedBox(height: 10),
            Text(_fmtFull(totalTDS),
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                    height: 1)),
            const Text('Total TDS Deducted (6 months)',
                style: TextStyle(fontSize: 11, color: Colors.white54)),
            const SizedBox(height: 14),
            Row(children: [
              _tdsHeroStat('Gross Income', _fmtFull(totalGross)),
              _tdsDivider(),
              _tdsHeroStat(
                  'Monthly TDS', _fmtFull(totalTDS / _tdsHistory.length)),
              _tdsDivider(),
              _tdsHeroStat('Eff. Rate',
                  '${(totalTDS / totalGross * 100).toStringAsFixed(1)}%'),
            ]),
          ]),
        ),
        const SizedBox(height: 16),

        // Form 16 download
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _C.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _C.border),
          ),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: _C.errorLight,
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.picture_as_pdf_outlined,
                  size: 22, color: _C.error),
            ),
            const SizedBox(width: 12),
            const Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Form 16',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _C.textPrimary)),
                  Text('TDS Certificate from Employer (FY 2025-26)',
                      style: TextStyle(fontSize: 11, color: _C.textSec)),
                ])),
            ElevatedButton.icon(
              onPressed: () => _snack('Form 16 downloaded ✅', _C.successDark),
              icon: const Icon(Icons.download_outlined, size: 15),
              label: const Text('Download'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.error,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                textStyle:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // Monthly TDS table
        Container(
          decoration: BoxDecoration(
            color: _C.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _C.border),
          ),
          child: Column(children: [
            const _SectionHdr('Monthly TDS History', Icons.table_chart_outlined,
                _C.primary, _C.primaryLight),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(children: [
                // Table header
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                      color: _C.surface,
                      borderRadius: BorderRadius.circular(8)),
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
                        child: Text('Gross',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _C.textSec))),
                    Expanded(
                        flex: 2,
                        child: Text('TDS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _C.primary))),
                    Expanded(
                        flex: 2,
                        child: Text('Net',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _C.successDark))),
                  ]),
                ),
                const SizedBox(height: 4),

                ..._tdsHistory.asMap().entries.map((e) {
                  final i = e.key;
                  final t = e.value;
                  final net = t.gross - t.tds;
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    decoration: BoxDecoration(
                      color: i.isEven
                          ? Colors.transparent
                          : _C.surface.withValues(alpha: .4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(children: [
                      Expanded(
                          flex: 3,
                          child: Text(t.month,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _C.textPrimary))),
                      Expanded(
                          flex: 2,
                          child: Text(_fmtCurrency(t.gross),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 11, color: _C.textSec))),
                      Expanded(
                          flex: 2,
                          child: Text(_fmtCurrency(t.tds),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _C.primary))),
                      Expanded(
                          flex: 2,
                          child: Text(_fmtCurrency(net),
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _C.successDark))),
                    ]),
                  );
                }),

                Container(
                    height: 1,
                    color: _C.border,
                    margin: const EdgeInsets.symmetric(vertical: 8)),
                Row(children: [
                  const Expanded(
                      flex: 3,
                      child: Text('Total',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _C.textPrimary))),
                  Expanded(
                      flex: 2,
                      child: Text(_fmtCurrency(totalGross),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _C.textSec))),
                  Expanded(
                      flex: 2,
                      child: Text(_fmtCurrency(totalTDS),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _C.primary))),
                  Expanded(
                      flex: 2,
                      child: Text(_fmtCurrency(totalGross - totalTDS),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _C.successDark))),
                ]),
              ]),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _tdsHeroStat(String lbl, String val) => Expanded(
          child: Column(children: [
        Text(val,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        Text(lbl,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, color: Colors.white54)),
      ]));

  Widget _tdsDivider() => Container(
      width: 1,
      height: 28,
      color: Colors.white.withValues(alpha: .2),
      margin: const EdgeInsets.symmetric(horizontal: 4));
}

// ─────────────────────────────────────────────
// INVESTMENT FIELD WIDGET
// ─────────────────────────────────────────────
class _InvestmentFieldWidget extends StatelessWidget {
  final _InvestmentField field;
  final Color sectionColor;
  final VoidCallback onChanged;

  const _InvestmentFieldWidget({
    required this.field,
    required this.sectionColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(field.label,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _C.textPrimary)),
      if (field.maxLimit < 999999)
        Text('Max: ${_fmtFull(field.maxLimit)}',
            style: const TextStyle(fontSize: 10, color: _C.textTert)),
      const SizedBox(height: 5),
      TextField(
        controller: field.ctrl,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (_) => onChanged(),
        style: const TextStyle(
            fontSize: 14, color: _C.textPrimary, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: field.hint,
          hintStyle: const TextStyle(fontSize: 13, color: _C.textTert),
          prefixText: '₹ ',
          prefixStyle: TextStyle(
              fontSize: 14, color: sectionColor, fontWeight: FontWeight.w600),
          filled: true,
          fillColor: _C.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _C.border, width: 1.5)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _C.border, width: 1.5)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: sectionColor, width: 1.5)),
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────
// DEADLINE BANNER
// ─────────────────────────────────────────────
class _DeadlineBanner extends StatelessWidget {
  final bool submitted;
  const _DeadlineBanner({required this.submitted});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: submitted ? _C.successLight : _C.warningLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: submitted
                  ? _C.success.withValues(alpha: .3)
                  : _C.warning.withValues(alpha: .3)),
        ),
        child: Row(children: [
          Icon(
            submitted
                ? Icons.check_circle_outline_rounded
                : Icons.access_time_rounded,
            size: 15,
            color: submitted ? _C.successDark : _C.warningDark,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              submitted
                  ? 'Declaration submitted for FY 2026-27. You can revise until 15 Dec 2026.'
                  : 'FY 2026-27 Declaration open · Deadline: 15 Dec 2026',
              style: TextStyle(
                  fontSize: 12,
                  color: submitted ? _C.successDark : _C.warningDark,
                  height: 1.4),
            ),
          ),
        ]),
      );
}

// ─────────────────────────────────────────────
// SHARED SECTION HEADER
// ─────────────────────────────────────────────
class _SectionHdr extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color, bg;
  const _SectionHdr(this.title, this.icon, this.color, this.bg);

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
