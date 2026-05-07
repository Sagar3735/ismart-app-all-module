// ============================================================
// ISF HR Portal — ESIC Form Screen
// File: lib/screens/payroll/esic_screen.dart
//
// Features:
//   - ESIC digital card (styled, downloadable)
//   - Contribution summary table (monthly, 6 months)
//   - Coverage details with dependents management
//   - Add / Edit dependent form (bottom sheet)
//   - Downloadable forms list (Form 11, 12A, 1, ESI Card)
//   - Dispensary & hospital info
//   - Claim history section
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
  static const success = Color(0xFF22C55E);
  static const successLight = Color(0xFFDCFCE7);
  static const successDark = Color(0xFF16A34A);
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
  static const textDisabled = Color(0xFFCBD5E1);
  static const border = Color(0xFFE2E8F0);
}

// ─────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────
class _Dependent {
  final String id;
  String name;
  String relation;
  String dob;
  String gender;

  _Dependent({
    required this.id,
    required this.name,
    required this.relation,
    required this.dob,
    required this.gender,
  });
}

class _Contribution {
  final String month;
  final double employeeShare;
  final double employerShare;
  final double total;
  const _Contribution(this.month, this.employeeShare, this.employerShare)
      : total = employeeShare + employerShare;
}

class _ESICClaim {
  final String id;
  final String type;
  final String date;
  final double amount;
  final String status;
  const _ESICClaim(this.id, this.type, this.date, this.amount, this.status);
}

// ─────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────
final _dependents = <_Dependent>[
  _Dependent(
    id: 'd1',
    name: 'Sunita Patil',
    relation: 'Spouse',
    dob: '15 Jun 1998',
    gender: 'Female',
  ),
  _Dependent(
    id: 'd2',
    name: 'Aryan Patil',
    relation: 'Child',
    dob: '10 Mar 2020',
    gender: 'Male',
  ),
];

const _contributions = [
  _Contribution('Apr 2026', 638, 1489),
  _Contribution('Mar 2026', 638, 1489),
  _Contribution('Feb 2026', 638, 1489),
  _Contribution('Jan 2026', 638, 1489),
  _Contribution('Dec 2025', 638, 1489),
  _Contribution('Nov 2025', 638, 1489),
];

const _claims = [
  _ESICClaim(
      'CLM-001', 'Medical Reimbursement', '15 Mar 2026', 4200, 'Settled'),
  _ESICClaim('CLM-002', 'Dependent Medical', '28 Jan 2026', 1800, 'Settled'),
  _ESICClaim('CLM-003', 'Sickness Benefit', '10 Nov 2025', 6300, 'Settled'),
];

const _downloadForms = [
  (
    icon: Icons.description_outlined,
    name: 'Form 11',
    desc: 'Employee Declaration Form',
    fileType: 'PDF · 124 KB',
    color: _C.primary,
    bg: _C.primaryLight,
  ),
  (
    icon: Icons.report_outlined,
    name: 'Form 12A',
    desc: 'Accident Report Form',
    fileType: 'PDF · 98 KB',
    color: _C.error,
    bg: _C.errorLight,
  ),
  (
    icon: Icons.assignment_outlined,
    name: 'Form 1',
    desc: 'Employer / Employee Registration',
    fileType: 'PDF · 86 KB',
    color: _C.teal,
    bg: _C.tealLight,
  ),
  (
    icon: Icons.credit_card_outlined,
    name: 'ESI Card',
    desc: 'Employee Insurance Card',
    fileType: 'PDF · 210 KB',
    color: _C.purple,
    bg: _C.purpleLight,
  ),
];

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────
String _fmtCurrency(double v) {
  if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(1)}K';
  return '₹${v.toStringAsFixed(0)}';
}

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class ESICScreen extends StatefulWidget {
  const ESICScreen({super.key});

  @override
  State<ESICScreen> createState() => _ESICScreenState();
}

class _ESICScreenState extends State<ESICScreen> {
  final List<_Dependent> _deps = List.from(_dependents);
  bool _isDownloading = false;
  String? _downloadingForm;

  // ── Snackbar ─────────────────────────────────
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

  // ── Download form ────────────────────────────
  Future<void> _downloadForm(String name) async {
    setState(() {
      _isDownloading = true;
      _downloadingForm = name;
    });
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    setState(() {
      _isDownloading = false;
      _downloadingForm = null;
    });
    _snack('$name downloaded ✅', _C.successDark);
  }

  // ── Copy to clipboard ─────────────────────────
  void _copy(String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    _snack('$label copied', _C.textSec);
  }

  // ── Add/Edit dependent sheet ──────────────────
  void _showDependentSheet({_Dependent? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _DependentSheet(
        existing: existing,
        onSave: (dep) {
          setState(() {
            if (existing != null) {
              final idx = _deps.indexWhere((d) => d.id == existing.id);
              if (idx != -1) {
                _deps[idx].name = dep.name;
                _deps[idx].relation = dep.relation;
                _deps[idx].dob = dep.dob;
                _deps[idx].gender = dep.gender;
              }
            } else {
              _deps.add(dep);
            }
          });
          _snack(
            existing != null
                ? '${dep.name} updated ✅'
                : '${dep.name} added as dependent ✅',
            _C.successDark,
          );
        },
      ),
    );
  }

  // ── Remove dependent ──────────────────────────
  void _removeDependent(_Dependent dep) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Dependent?',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        content: Text(
            'Remove ${dep.name} (${dep.relation}) from ESIC coverage?',
            style: const TextStyle(fontSize: 14, color: _C.textSec)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: _C.textSec))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _deps.removeWhere((d) => d.id == dep.id));
              _snack('${dep.name} removed from dependents', _C.textSec);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Remove'),
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
        children: [
          _buildESICCard(),
          const SizedBox(height: 16),
          _buildContributionTable(),
          const SizedBox(height: 16),
          _buildCoverageSection(),
          const SizedBox(height: 16),
          _buildDispensaryCard(),
          const SizedBox(height: 16),
          _buildClaimsSection(),
          const SizedBox(height: 16),
          _buildDownloadForms(),
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
        title: const Text('ESIC Details',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined, size: 21),
            color: _C.textSec,
            onPressed: () => _downloadForm('ESI Card'),
            tooltip: 'Download ESI Card',
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _C.border),
        ),
      );

  // ─────────────────────────────────────────────
  // ESIC DIGITAL CARD
  // ─────────────────────────────────────────────
  Widget _buildESICCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _C.primary.withValues(alpha: .3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(children: [
        // Background pattern
        Positioned(
          right: -20,
          top: -20,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: .06),
            ),
          ),
        ),
        Positioned(
          right: 30,
          bottom: -30,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: .05),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row — logo + card type
              Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.shield_outlined,
                        size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Text('ESIC',
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
                    color: _C.success.withValues(alpha: .25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: .2)),
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
              const SizedBox(height: 18),

              // Employee name
              const Text('AMIT PATIL',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5)),
              const SizedBox(height: 2),
              const Text('Full Stack Developer · ISF Solutions Pvt. Ltd.',
                  style: TextStyle(fontSize: 11, color: Colors.white60)),
              const SizedBox(height: 16),

              // IP number (main) — copyable
              GestureDetector(
                onTap: () => _copy('MH-1234567890', 'ESIC IP Number'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('IP NUMBER',
                        style: TextStyle(
                            fontSize: 9,
                            color: Colors.white54,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Row(children: [
                      const Text('MH-1234567890',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.copy_outlined,
                            size: 13, color: Colors.white70),
                      ),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Bottom row — valid from + employer code
              Row(children: [
                _cardInfo('VALID FROM', '01 Apr 2024'),
                const SizedBox(width: 24),
                _cardInfo('EMPLOYER CODE', 'MH-MUM-000123'),
                const Spacer(),
                GestureDetector(
                  onTap: () => _downloadForm('ESI Card'),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.download_outlined,
                        size: 18, color: Colors.white),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _cardInfo(String label, String value) => Column(
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
  // CONTRIBUTION TABLE
  // ─────────────────────────────────────────────
  Widget _buildContributionTable() {
    final totalEmployee =
        _contributions.fold(0.0, (s, c) => s + c.employeeShare);
    final totalEmployer =
        _contributions.fold(0.0, (s, c) => s + c.employerShare);
    final grandTotal = totalEmployee + totalEmployer;

    return _SectionCard(
      title: 'FY 2025-26 Contributions',
      icon: Icons.account_balance_outlined,
      iconColor: _C.teal,
      iconBg: _C.tealLight,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
            color: _C.tealLight, borderRadius: BorderRadius.circular(20)),
        child: const Text('6 months',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: _C.teal)),
      ),
      child: Column(children: [
        // Table header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
          decoration: BoxDecoration(
              color: _C.surface, borderRadius: BorderRadius.circular(8)),
          child: const Row(children: [
            Expanded(
                flex: 3,
                child: Text('Month',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _C.textSec))),
            Expanded(
                flex: 2,
                child: Text('Employee',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _C.textSec))),
            Expanded(
                flex: 2,
                child: Text('Employer',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _C.textSec))),
            Expanded(
                flex: 2,
                child: Text('Total',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _C.textSec))),
          ]),
        ),
        const SizedBox(height: 4),

        // Rows
        ..._contributions.asMap().entries.map((e) {
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
                  child: Text(
                    '₹${c.employeeShare.toStringAsFixed(0)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 12,
                        color: _C.error,
                        fontWeight: FontWeight.w600),
                  )),
              Expanded(
                  flex: 2,
                  child: Text(
                    '₹${c.employerShare.toStringAsFixed(0)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 12,
                        color: _C.teal,
                        fontWeight: FontWeight.w600),
                  )),
              Expanded(
                  flex: 2,
                  child: Text(
                    '₹${c.total.toStringAsFixed(0)}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontSize: 12,
                        color: _C.textPrimary,
                        fontWeight: FontWeight.w700),
                  )),
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
              child: Text('Total',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _C.textPrimary))),
          Expanded(
              flex: 2,
              child: Text(
                '₹${totalEmployee.toStringAsFixed(0)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: _C.error, fontWeight: FontWeight.w800),
              )),
          Expanded(
              flex: 2,
              child: Text(
                '₹${totalEmployer.toStringAsFixed(0)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: _C.teal, fontWeight: FontWeight.w800),
              )),
          Expanded(
              flex: 2,
              child: Text(
                '₹${grandTotal.toStringAsFixed(0)}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 13,
                    color: _C.textPrimary,
                    fontWeight: FontWeight.w800),
              )),
        ]),
        const SizedBox(height: 12),

        // Rate note
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _C.tealLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _C.teal.withValues(alpha: .2)),
          ),
          child: const Row(children: [
            Icon(Icons.info_outline_rounded, size: 13, color: _C.teal),
            SizedBox(width: 7),
            Expanded(
              child: Text(
                'Employee: 0.75% of gross  ·  Employer: 3.25% of gross',
                style: TextStyle(fontSize: 11, color: _C.teal),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────
  // COVERAGE & DEPENDENTS
  // ─────────────────────────────────────────────
  Widget _buildCoverageSection() {
    return _SectionCard(
      title: 'Coverage Details',
      icon: Icons.family_restroom_outlined,
      iconColor: _C.purple,
      iconBg: _C.purpleLight,
      trailing: GestureDetector(
        onTap: () => _showDependentSheet(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              color: _C.primaryLight, borderRadius: BorderRadius.circular(20)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.add_rounded, size: 14, color: _C.primary),
            SizedBox(width: 4),
            Text('Add',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _C.primary)),
          ]),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Coverage type banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _C.purpleLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.purple.withValues(alpha: .2)),
          ),
          child: Row(children: [
            const Icon(Icons.verified_outlined, size: 20, color: _C.purple),
            const SizedBox(width: 10),
            const Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Self + Family Coverage',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _C.purple)),
                Text('All immediate family members are covered',
                    style: TextStyle(fontSize: 11, color: _C.textSec)),
              ],
            )),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: _C.purple.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(20)),
              child: Text('${_deps.length + 1} Covered',
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _C.purple)),
            ),
          ]),
        ),
        const SizedBox(height: 14),

        // Self row (always)
        const Text('Covered Members',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: _C.textSec)),
        const SizedBox(height: 8),

        // Self
        _coverageRow(
          initials: 'AP',
          color: _C.primary,
          name: 'Amit Patil',
          subLabel: 'Self · Employee',
          gender: 'Male',
          isEmployee: true,
        ),

        // Dependents
        ..._deps.map((d) => _DependentRow(
              dep: d,
              onEdit: () => _showDependentSheet(existing: d),
              onRemove: () => _removeDependent(d),
            )),

        if (_deps.isEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _C.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _C.border, style: BorderStyle.solid),
            ),
            child: Column(children: [
              const Icon(Icons.people_outline_rounded,
                  size: 28, color: _C.textDisabled),
              const SizedBox(height: 6),
              const Text('No dependents added',
                  style: TextStyle(fontSize: 13, color: _C.textSec)),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _showDependentSheet(),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add Dependent'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _C.primary,
                  side: const BorderSide(color: _C.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _coverageRow({
    required String initials,
    required Color color,
    required String name,
    required String subLabel,
    required String gender,
    bool isEmployee = false,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isEmployee ? _C.primaryLight : _C.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isEmployee ? _C.primary.withValues(alpha: .25) : _C.border,
            ),
          ),
          child: Row(children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Center(
                child: Text(initials,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _C.textPrimary)),
                Text(subLabel,
                    style: const TextStyle(fontSize: 11, color: _C.textSec)),
              ],
            )),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                  color: isEmployee ? _C.primary : _C.surface,
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: isEmployee ? _C.primary : _C.border)),
              child: Text(isEmployee ? 'Primary' : gender,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isEmployee ? Colors.white : _C.textSec)),
            ),
          ]),
        ),
      );

  // ─────────────────────────────────────────────
  // DISPENSARY CARD
  // ─────────────────────────────────────────────
  Widget _buildDispensaryCard() {
    return _SectionCard(
      title: 'Dispensary & Hospital',
      icon: Icons.local_hospital_outlined,
      iconColor: _C.error,
      iconBg: _C.errorLight,
      child: Column(children: [
        _infoTile(
          Icons.medical_services_outlined,
          'Empanelled Dispensary',
          'MH-ESI Dispensary, Wadala',
          'Mon–Sat · 9 AM – 5 PM',
          _C.error,
          _C.errorLight,
        ),
        const SizedBox(height: 10),
        _infoTile(
          Icons.local_hospital_outlined,
          'ESIC Hospital',
          'ESIC Model Hospital, K.E.M Road, Mumbai',
          '24×7 Emergency available',
          _C.primary,
          _C.primaryLight,
        ),
        const SizedBox(height: 12),
        // Map / Navigate action
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton.icon(
            onPressed: () => _snack('Opening maps…', _C.textSec),
            icon: const Icon(Icons.directions_outlined, size: 17),
            label: const Text('Get Directions'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _C.primary,
              side: const BorderSide(color: _C.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _infoTile(IconData icon, String title, String name, String sub,
          Color color, Color bg) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: .2)),
        ),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: color.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w600, color: color)),
              Text(name,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary)),
              Text(sub,
                  style: const TextStyle(fontSize: 10, color: _C.textSec)),
            ],
          )),
        ]),
      );

  // ─────────────────────────────────────────────
  // CLAIMS HISTORY
  // ─────────────────────────────────────────────
  Widget _buildClaimsSection() {
    return _SectionCard(
      title: 'Claim History',
      icon: Icons.receipt_long_outlined,
      iconColor: _C.orange,
      iconBg: _C.orangeLight,
      trailing: GestureDetector(
        onTap: () => _snack('Raise new claim — coming soon', _C.textSec),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              color: _C.orangeLight, borderRadius: BorderRadius.circular(20)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.add_rounded, size: 14, color: _C.orange),
            SizedBox(width: 4),
            Text('Raise Claim',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _C.orange)),
          ]),
        ),
      ),
      child: Column(
        children: _claims.asMap().entries.map((e) {
          final i = e.key;
          final c = e.value;
          final isLast = i == _claims.length - 1;
          return Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: _C.orangeLight,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.receipt_outlined,
                      size: 18, color: _C.orange),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.type,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _C.textPrimary)),
                    Text('${c.id} · ${c.date}',
                        style:
                            const TextStyle(fontSize: 10, color: _C.textSec)),
                  ],
                )),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(_fmtCurrency(c.amount),
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _C.textPrimary)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                        color: _C.successLight,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(c.status,
                        style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: _C.successDark)),
                  ),
                ]),
              ]),
            ),
            if (!isLast) Container(height: 1, color: _C.border),
          ]);
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // DOWNLOAD FORMS
  // ─────────────────────────────────────────────
  Widget _buildDownloadForms() {
    return _SectionCard(
      title: 'Download ESIC Forms',
      icon: Icons.folder_outlined,
      iconColor: _C.teal,
      iconBg: _C.tealLight,
      child: Column(
        children: _downloadForms.map((f) {
          final isLoading = _isDownloading && _downloadingForm == f.name;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: isLoading ? null : () => _downloadForm(f.name),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _C.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isLoading ? f.color.withValues(alpha: .5) : _C.border,
                    width: isLoading ? 1.5 : 1,
                  ),
                ),
                child: Row(children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: f.bg, borderRadius: BorderRadius.circular(12)),
                    child: isLoading
                        ? Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: f.color, strokeWidth: 2.5),
                            ),
                          )
                        : Icon(f.icon, size: 22, color: f.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.name,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _C.textPrimary)),
                      Text(f.desc,
                          style:
                              const TextStyle(fontSize: 11, color: _C.textSec)),
                      Text(f.fileType,
                          style: const TextStyle(
                              fontSize: 10, color: _C.textTert)),
                    ],
                  )),
                  isLoading
                      ? Text('Downloading…',
                          style: TextStyle(
                              fontSize: 11,
                              color: f.color,
                              fontWeight: FontWeight.w600))
                      : const Icon(Icons.download_outlined,
                          size: 20, color: _C.textSec),
                ]),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DEPENDENT ROW
// ─────────────────────────────────────────────
class _DependentRow extends StatelessWidget {
  final _Dependent dep;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const _DependentRow({
    required this.dep,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFF7C3AED),
      const Color(0xFF0D9488),
      const Color(0xFFEC4899),
      const Color(0xFFEA580C),
    ];
    final color = colors[dep.id.hashCode.abs() % colors.length];
    final initials = dep.name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.border),
        ),
        child: Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(
              child: Text(initials,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dep.name,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _C.textPrimary)),
              Text('${dep.relation} · ${dep.dob}',
                  style: const TextStyle(fontSize: 11, color: _C.textSec)),
            ],
          )),
          // Edit + Remove
          Row(children: [
            GestureDetector(
              onTap: onEdit,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    color: _C.primaryLight,
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.edit_outlined,
                    size: 15, color: _C.primary),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    color: _C.errorLight,
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.remove_circle_outline_rounded,
                    size: 15, color: _C.error),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ADD / EDIT DEPENDENT SHEET
// ─────────────────────────────────────────────
class _DependentSheet extends StatefulWidget {
  final _Dependent? existing;
  final void Function(_Dependent) onSave;

  const _DependentSheet({this.existing, required this.onSave});

  @override
  State<_DependentSheet> createState() => _DependentSheetState();
}

class _DependentSheetState extends State<_DependentSheet> {
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _relation;
  String? _gender;
  bool _saving = false;

  static const _relations = ['Spouse', 'Child', 'Parent', 'Sibling', 'Other'];
  static const _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _nameCtrl.text = widget.existing!.name;
      _dobCtrl.text = widget.existing!.dob;
      _relation = widget.existing!.relation;
      _gender = widget.existing!.gender;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_relation == null) {
      _showErr('Select relationship');
      return;
    }
    if (_gender == null) {
      _showErr('Select gender');
      return;
    }
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final dep = _Dependent(
      id: widget.existing?.id ?? 'dep_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim(),
      relation: _relation!,
      dob: _dobCtrl.text.trim(),
      gender: _gender!,
    );
    Navigator.pop(context);
    widget.onSave(dep);
  }

  void _showErr(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: _C.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, 32 + MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _formKey,
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
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 18),
            Text(isEdit ? 'Edit Dependent' : 'Add Dependent',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary)),
            const SizedBox(height: 4),
            const Text('ESIC coverage will be extended to this member',
                style: TextStyle(fontSize: 13, color: _C.textSec)),
            const SizedBox(height: 18),

            // Full name
            _sheetLabel('Full Name *'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameCtrl,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
              style: const TextStyle(fontSize: 14, color: _C.textPrimary),
              decoration: _deco('e.g. Sunita Patil'),
            ),
            const SizedBox(height: 12),

            // DOB
            _sheetLabel('Date of Birth *'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _dobCtrl,
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Date of birth is required'
                  : null,
              style: const TextStyle(fontSize: 14, color: _C.textPrimary),
              decoration: _deco('e.g. 15 Jun 1998'),
            ),
            const SizedBox(height: 12),

            // Relation + Gender row
            Row(children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sheetLabel('Relationship *'),
                  const SizedBox(height: 6),
                  _dropdown(_relations, _relation, 'Select',
                      (v) => setState(() => _relation = v)),
                ],
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sheetLabel('Gender *'),
                  const SizedBox(height: 6),
                  _dropdown(_genders, _gender, 'Select',
                      (v) => setState(() => _gender = v)),
                ],
              )),
            ]),
            const SizedBox(height: 20),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.primary,
                  disabledBackgroundColor: _C.textDisabled,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : Text(isEdit ? 'Save Changes' : 'Add Dependent',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetLabel(String text) => Text(text,
      style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600, color: _C.textPrimary));

  InputDecoration _deco(String hint) => InputDecoration(
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
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _C.error, width: 1.5)),
        errorStyle: const TextStyle(fontSize: 11, color: _C.error),
      );

  Widget _dropdown(List<String> items, String? value, String hint,
          void Function(String?) onChanged) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.border, width: 1.5),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            hint: Text(hint,
                style: const TextStyle(fontSize: 13, color: _C.textTert)),
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                size: 18, color: _C.textSec),
            style: const TextStyle(
                fontSize: 13,
                color: _C.textPrimary,
                fontWeight: FontWeight.w500),
            onChanged: onChanged,
            items: items
                .map((i) => DropdownMenuItem(
                      value: i,
                      child: Text(i),
                    ))
                .toList(),
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// SECTION CARD WRAPPER
// ─────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}
