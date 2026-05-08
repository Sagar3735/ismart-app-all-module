// ============================================================
// ISF HR Portal — Benefits Screen
// File: lib/screens/payroll/benefits_screen.dart
//
// Features:
//   - Total benefits hero card (gradient, animated count-up)
//   - Benefits grid (2-column, tap for detail sheet)
//   - Health insurance expandable card with claim CTA
//   - Gratuity projection card with timeline bar
//   - Allowances breakdown section
//   - Benefits comparison (CTC vs Take-home visual)
//   - Each benefit: detail bottom sheet with full info
//
// Dependencies: none beyond flutter/material
// ============================================================

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// INLINE THEME
// ─────────────────────────────────────────────
class _C {
  static const primary      = Color(0xFF2563EB);
  static const primaryLight = Color(0xFFEFF6FF);
  static const accent       = Color(0xFF6366F1);
  static const accentLight  = Color(0xFFEEF2FF);
  static const successLight = Color(0xFFDCFCE7);
  static const successDark  = Color(0xFF16A34A);
  static const error        = Color(0xFFEF4444);
  static const errorLight   = Color(0xFFFEF2F2);
  static const teal         = Color(0xFF0D9488);
  static const tealLight    = Color(0xFFF0FDFA);
  static const orange       = Color(0xFFEA580C);
  static const orangeLight  = Color(0xFFFFF7ED);
  static const purple       = Color(0xFF7C3AED);
  static const pink         = Color(0xFFEC4899);
  static const pinkLight    = Color(0xFFFDF2F8);
  static const sky          = Color(0xFF0EA5E9);
  static const skyLight     = Color(0xFFF0F9FF);
  static const bg           = Color(0xFFF8FAFC);
  static const card         = Color(0xFFFFFFFF);
  static const surface      = Color(0xFFF1F5F9);
  static const textPrimary  = Color(0xFF0F172A);
  static const textSec      = Color(0xFF64748B);
  static const textTert     = Color(0xFF94A3B8);
  static const border       = Color(0xFFE2E8F0);
}

// ─────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────
class _Benefit {
  final String id;
  final String title;
  final String subtitle;       // e.g. "₹5L coverage"
  final String value;          // display value
  final String category;       // Insurance / Financial / Allowance / Leave
  final IconData icon;
  final Color color;
  final Color bg;
  final String description;
  final List<_BenefitDetail> details;
  final String? ctaLabel;
  final bool highlighted;

  const _Benefit({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.category,
    required this.icon,
    required this.color,
    required this.bg,
    required this.description,
    required this.details,
    this.ctaLabel,
    this.highlighted = false,
  });
}

class _BenefitDetail {
  final String label;
  final String value;
  const _BenefitDetail(this.label, this.value);
}

// ─────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────
const _benefits = [
  _Benefit(
    id: 'health',
    title: 'Health Insurance',
    subtitle: '₹5L family floater',
    value: '₹5,00,000',
    category: 'Insurance',
    icon: Icons.health_and_safety_outlined,
    color: _C.error,
    bg: _C.errorLight,
    highlighted: true,
    description: 'Comprehensive group health insurance covering self, spouse, and 2 children. '
        'Includes pre & post hospitalization, day care procedures, and maternity benefits.',
    details: [
      _BenefitDetail('Insurer',           'Star Health Insurance'),
      _BenefitDetail('Policy Number',     'ISF-GHI-2024-0042'),
      _BenefitDetail('Sum Insured',       '₹5,00,000'),
      _BenefitDetail('Coverage Type',     'Family Floater'),
      _BenefitDetail('Covered Members',  'Self + Spouse + 2 Children'),
      _BenefitDetail('Renewal Date',     '31 Mar 2027'),
      _BenefitDetail('Network Hospitals', '10,000+ across India'),
      _BenefitDetail('Day Care',         'Yes — 586 procedures'),
      _BenefitDetail('Maternity',        '₹50,000 (after 9 months)'),
    ],
    ctaLabel: 'Raise a Claim',
  ),
  _Benefit(
    id: 'life',
    title: 'Group Life Insurance',
    subtitle: '₹25L term cover',
    value: '₹25,00,000',
    category: 'Insurance',
    icon: Icons.shield_outlined,
    color: _C.primary,
    bg: _C.primaryLight,
    description: 'Group term life insurance covering death due to any cause. '
        'Nominee receives the entire sum insured as a lump sum.',
    details: [
      _BenefitDetail('Insurer',       'LIC of India'),
      _BenefitDetail('Policy Type',   'Group Term Life'),
      _BenefitDetail('Sum Assured',   '₹25,00,000'),
      _BenefitDetail('Coverage',      'Death due to any cause'),
      _BenefitDetail('Nominee',       'Sunita Patil (Spouse)'),
      _BenefitDetail('Premium',       'Paid by employer'),
    ],
  ),
  _Benefit(
    id: 'gratuity',
    title: 'Gratuity',
    subtitle: 'Accrued: ₹14,583',
    value: '₹14,583',
    category: 'Financial',
    icon: Icons.savings_outlined,
    color: _C.successDark,
    bg: _C.successLight,
    description: 'Gratuity is a statutory benefit paid to employees completing 5+ years. '
        'It accrues monthly and is paid as a lump sum on exit.',
    details: [
      _BenefitDetail('Accrued So Far',    '₹14,583'),
      _BenefitDetail('At 5 Years',        '₹87,500 (projected)'),
      _BenefitDetail('Formula',           'Basic × 15/26 × Years'),
      _BenefitDetail('Tax Exempt',        'Up to ₹20,00,000'),
      _BenefitDetail('Eligibility',       '5 years of continuous service'),
      _BenefitDetail('Monthly Accrual',   '₹1,042'),
    ],
  ),
  _Benefit(
    id: 'leaveencash',
    title: 'Leave Encashment',
    subtitle: '12 days eligible',
    value: '12 days',
    category: 'Financial',
    icon: Icons.event_available_outlined,
    color: _C.accent,
    bg: _C.accentLight,
    description: 'Unused earned leave can be encashed annually (max 15 days). '
        'Payment is processed in December payroll.',
    details: [
      _BenefitDetail('Max Encashable',    '15 days per year'),
      _BenefitDetail('Currently Eligible','12 days'),
      _BenefitDetail('Rate',              '₹5,700/day (Basic ÷ 26)'),
      _BenefitDetail('Approx Payout',     '₹68,400'),
      _BenefitDetail('Processed',         'December payroll'),
      _BenefitDetail('Tax',               'Taxable as salary income'),
    ],
  ),
  _Benefit(
    id: 'medical',
    title: 'Medical Allowance',
    subtitle: '₹1,250/month',
    value: '₹15,000/yr',
    category: 'Allowance',
    icon: Icons.local_hospital_outlined,
    color: _C.teal,
    bg: _C.tealLight,
    description: 'Monthly medical allowance for OPD expenses not covered under health insurance. '
        'Reimbursed via salary, partially tax-exempt.',
    details: [
      _BenefitDetail('Monthly Amount',   '₹1,250'),
      _BenefitDetail('Annual Amount',    '₹15,000'),
      _BenefitDetail('Tax Exemption',    'Up to ₹15,000 p.a.'),
      _BenefitDetail('Disbursement',     'Monthly with salary'),
      _BenefitDetail('Usage',            'OPD, medicines, diagnostics'),
    ],
  ),
  _Benefit(
    id: 'travel',
    title: 'Travel Allowance',
    subtitle: '₹11,500/month',
    value: '₹1.38L/yr',
    category: 'Allowance',
    icon: Icons.directions_bus_outlined,
    color: _C.orange,
    bg: _C.orangeLight,
    description: 'Monthly conveyance allowance for commuting to and from the workplace. '
        'Partially tax-exempt under Section 10.',
    details: [
      _BenefitDetail('Monthly Amount',   '₹11,500'),
      _BenefitDetail('Annual Amount',    '₹1,38,000'),
      _BenefitDetail('Tax Exemption',    '₹1,600/month (₹19,200 p.a.)'),
      _BenefitDetail('Disbursement',     'Monthly with salary'),
    ],
  ),
  _Benefit(
    id: 'meal',
    title: 'Meal Allowance',
    subtitle: '₹2,000/month',
    value: '₹24,000/yr',
    category: 'Allowance',
    icon: Icons.restaurant_outlined,
    color: _C.pink,
    bg: _C.pinkLight,
    description: 'Monthly meal allowance via meal vouchers or wallet. '
        'Tax-exempt up to ₹50 per meal for 2 meals a day.',
    details: [
      _BenefitDetail('Monthly Amount',   '₹2,000'),
      _BenefitDetail('Mode',             'Zeta / Sodexo vouchers'),
      _BenefitDetail('Tax Benefit',      '₹26,400 p.a. tax-free'),
      _BenefitDetail('Validity',         'Vouchers expire in 12 months'),
    ],
  ),
  _Benefit(
    id: 'mobile',
    title: 'Mobile Reimbursement',
    subtitle: '₹500/month',
    value: '₹6,000/yr',
    category: 'Allowance',
    icon: Icons.phone_android_outlined,
    color: _C.sky,
    bg: _C.skyLight,
    description: 'Monthly mobile and internet reimbursement for business-related usage. '
        'Submit bills at the end of each month.',
    details: [
      _BenefitDetail('Monthly Limit',    '₹500'),
      _BenefitDetail('Annual Limit',     '₹6,000'),
      _BenefitDetail('Claim Process',    'Submit bill via ESS portal'),
      _BenefitDetail('Tax Treatment',    'Actual expenses exempt from tax'),
    ],
  ),
];

// Total benefits value
const _totalBenefitsValue = 142000.0;  // ₹1,42,000/year

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────
String _fmtCurrency(double v) {
  if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(2)}L';
  if (v >= 1000)   return '₹${(v / 1000).toStringAsFixed(0)}K';
  return '₹${v.toStringAsFixed(0)}';
}

const _categories = ['All', 'Insurance', 'Financial', 'Allowance'];

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class BenefitsScreen extends StatefulWidget {
  const BenefitsScreen({super.key});

  @override
  State<BenefitsScreen> createState() => _BenefitsScreenState();
}

class _BenefitsScreenState extends State<BenefitsScreen>
    with TickerProviderStateMixin {

  late final AnimationController _heroCtrl;
  late final Animation<double>   _heroAnim;
  String _activeCategory = 'All';
  bool   _healthExpanded = true;

  List<_Benefit> get _filtered => _activeCategory == 'All'
      ? _benefits
      : _benefits.where((b) => b.category == _activeCategory).toList();

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _heroAnim = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 200),
        () { if (mounted) _heroCtrl.forward(); });
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: bg,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ));
  }

  void _showBenefitDetail(_Benefit b) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _BenefitDetailSheet(
        benefit: b,
        onCta: b.ctaLabel != null
            ? () {
                Navigator.pop(context);
                _snack('Claim raised via HR portal', _C.successDark);
              }
            : null,
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
          _buildHeroCard(),
          const SizedBox(height: 16),
          _buildCategoryFilter(),
          const SizedBox(height: 14),
          _buildBenefitsGrid(),
          const SizedBox(height: 16),
          if (_activeCategory == 'All' || _activeCategory == 'Insurance') ...[
            _buildHealthInsuranceCard(),
            const SizedBox(height: 16),
          ],
          if (_activeCategory == 'All' || _activeCategory == 'Financial') ...[
            _buildGratuityCard(),
            const SizedBox(height: 16),
          ],
          _buildCTCBreakdown(),
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
    title: const Text('Benefits',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
            color: _C.textPrimary)),
    actions: [
      IconButton(
        icon: const Icon(Icons.download_outlined, size: 21),
        color: _C.textSec,
        onPressed: () => _snack('Benefits summary downloaded ✅', _C.successDark),
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
  // HERO CARD
  // ─────────────────────────────────────────────
  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _C.primary.withValues(alpha: .3),
            blurRadius: 16, offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(children: [
        // Decorative circles
        Positioned(right: -20, top: -20,
            child: _circle(100, .06)),
        Positioned(right: 50, bottom: -30,
            child: _circle(70, .04)),

        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header row
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.card_giftcard_rounded, size: 15, color: Colors.white),
                SizedBox(width: 6),
                Text('BENEFITS PACKAGE',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                        color: Colors.white, letterSpacing: 0.8)),
              ]),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('FY 2026-27',
                  style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: .8))),
            ),
          ]),
          const SizedBox(height: 18),

          // Main value
          const Text('Total Benefits Value',
              style: TextStyle(fontSize: 12, color: Colors.white60)),
          const SizedBox(height: 4),
          AnimatedBuilder(
            animation: _heroAnim,
            builder: (_, __) => Text(
              _fmtCurrency(_totalBenefitsValue * _heroAnim.value),
              style: const TextStyle(
                  fontSize: 36, fontWeight: FontWeight.w800,
                  color: Colors.white, letterSpacing: -1.5, height: 1),
            ),
          ),
          const Text('per year',
              style: TextStyle(fontSize: 11, color: Colors.white54)),
          const SizedBox(height: 16),

          // Stats row
          Row(children: [
            _heroStat('${_benefits.length}', 'Benefits'),
            _heroDivider(),
            _heroStat('3', 'Insurance\nCovers'),
            _heroDivider(),
            _heroStat('Family', 'Coverage\nType'),
            _heroDivider(),
            _heroStat('₹30K', 'Tax\nSavings'),
          ]),
        ]),
      ]),
    );
  }

  Widget _circle(double size, double opacity) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity)),
  );

  Widget _heroStat(String val, String lbl) => Expanded(
    child: Column(children: [
      Text(val,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w800,
              color: Colors.white)),
      Text(lbl, textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 9, color: Colors.white60, height: 1.3)),
    ]),
  );

  Widget _heroDivider() => Container(
      width: 1, height: 32,
      color: Colors.white.withValues(alpha: .2),
      margin: const EdgeInsets.symmetric(horizontal: 4));

  // ─────────────────────────────────────────────
  // CATEGORY FILTER
  // ─────────────────────────────────────────────
  Widget _buildCategoryFilter() {
    final catColors = <String, Color>{
      'All': _C.primary,
      'Insurance': _C.error,
      'Financial': _C.successDark,
      'Allowance': _C.orange,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((cat) {
          final active = cat == _activeCategory;
          final color  = catColors[cat] ?? _C.primary;
          final count  = cat == 'All'
              ? _benefits.length
              : _benefits.where((b) => b.category == cat).length;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _activeCategory = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? color : _C.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: active ? color : _C.border),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(cat,
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600,
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
                            fontSize: 9, fontWeight: FontWeight.w700,
                            color: active ? Colors.white : _C.textSec)),
                  ),
                ]),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BENEFITS GRID
  // ─────────────────────────────────────────────
  Widget _buildBenefitsGrid() {
    final items = _filtered;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: items.map((b) => _BenefitCard(
        benefit: b,
        onTap: () => _showBenefitDetail(b),
      )).toList(),
    );
  }

  // ─────────────────────────────────────────────
  // HEALTH INSURANCE EXPANDED CARD
  // ─────────────────────────────────────────────
  Widget _buildHealthInsuranceCard() {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Column(children: [
        // Collapsible header
        InkWell(
          onTap: () => setState(() => _healthExpanded = !_healthExpanded),
          borderRadius: BorderRadius.vertical(
              top: const Radius.circular(20),
              bottom: _healthExpanded ? Radius.zero : const Radius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                    color: _C.errorLight,
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.health_and_safety_outlined,
                    size: 22, color: _C.error),
              ),
              const SizedBox(width: 12),
              const Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Health Insurance',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700,
                          color: _C.textPrimary)),
                  Text('Star Health · Family Floater · ₹5L',
                      style: TextStyle(fontSize: 11, color: _C.textSec)),
                ],
              )),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: _C.successLight,
                    borderRadius: BorderRadius.circular(20)),
                child: const Text('Active',
                    style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w700,
                        color: _C.successDark)),
              ),
              const SizedBox(width: 8),
              AnimatedRotation(
                turns: _healthExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 220),
                child: const Icon(Icons.keyboard_arrow_down_rounded,
                    size: 22, color: _C.textSec),
              ),
            ]),
          ),
        ),

        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _healthExpanded
              ? Column(children: [
                  Container(height: 1, color: _C.border),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Coverage members
                        const Text('Covered Members',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600,
                                color: _C.textSec)),
                        const SizedBox(height: 10),
                        Row(children: [
                          _memberAvatar('AP', _C.primary,  'Self'),
                          const SizedBox(width: 10),
                          _memberAvatar('SP', const Color(0xFFEC4899), 'Spouse'),
                          const SizedBox(width: 10),
                          _memberAvatar('C1', _C.teal, 'Child 1'),
                          const SizedBox(width: 10),
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                                color: _C.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _C.border,
                                    style: BorderStyle.solid)),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_rounded,
                                    size: 18, color: _C.textSec),
                                Text('Add',
                                    style: TextStyle(
                                        fontSize: 8, color: _C.textSec)),
                              ],
                            ),
                          ),
                        ]),
                        const SizedBox(height: 16),

                        // Key details grid
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.5,
                          children: [
                            _infoTile('Sum Insured', '₹5,00,000', _C.error),
                            _infoTile('Renewal Date', '31 Mar 2027', _C.primary),
                            _infoTile('Network Hospitals', '10,000+', _C.teal),
                            _infoTile('Maternity', '₹50,000', _C.purple),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // CTA buttons
                        Row(children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _snack('Download insurance card', _C.textSec),
                              icon: const Icon(Icons.download_outlined, size: 16),
                              label: const Text('Card'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _C.error,
                                side: const BorderSide(color: _C.error, width: 1.5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _snack('Claim raised ✅', _C.successDark),
                              icon: const Icon(Icons.add_circle_outline_rounded,
                                  size: 16),
                              label: const Text('Raise Claim'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _C.error,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ])
              : const SizedBox.shrink(),
        ),
      ]),
    );
  }

  Widget _memberAvatar(String initials, Color color, String label) => Column(
    children: [
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Text(initials,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: Colors.white)),
        ),
      ),
      const SizedBox(height: 4),
      Text(label,
          style: const TextStyle(fontSize: 9, color: _C.textSec)),
    ],
  );

  Widget _infoTile(String label, String value, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .07),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withValues(alpha: .2)),
    ),
    child: Row(children: [
      Expanded(child: Text(label,
          style: const TextStyle(fontSize: 10, color: _C.textSec))),
      Text(value,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    ]),
  );

  // ─────────────────────────────────────────────
  // GRATUITY PROJECTION CARD
  // ─────────────────────────────────────────────
  Widget _buildGratuityCard() {
    // 1 year 1 month tenure → 13 months / 12 = 1.08 years
    const tenureMonths = 13;
    const totalMonths  = 60;   // 5 years
    const progress     = tenureMonths / totalMonths;

    const accrued      = 14583.0;
    const atFiveYears  = 87500.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
                color: _C.successLight,
                borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.savings_outlined, size: 16,
                color: _C.successDark),
          ),
          const SizedBox(width: 10),
          const Text('Gratuity Projection',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                  color: _C.textPrimary)),
        ]),
        const SizedBox(height: 16),

        // Progress bar to 5 years
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tenure: ${tenureMonths ~/ 12} yr ${tenureMonths % 12} mo',
                style: TextStyle(fontSize: 11, color: _C.textSec)),
            Text('Eligibility: 5 years',
                style: TextStyle(fontSize: 11, color: _C.textSec)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: const LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: _C.successLight,
            valueColor: AlwaysStoppedAnimation<Color>(_C.successDark),
          ),
        ),
        const SizedBox(height: 4),
        Text('${(progress * 100).toInt()}% to eligibility',
            style: const TextStyle(fontSize: 10, color: _C.textSec)),
        const SizedBox(height: 14),

        // Stats
        Row(children: [
          Expanded(child: _gratuityBox(
              'Accrued So Far',   _fmtCurrency(accrued),
              'Monthly: ₹1,042', _C.successDark, _C.successLight)),
          const SizedBox(width: 10),
          Expanded(child: _gratuityBox(
              'At 5 Years',       _fmtCurrency(atFiveYears),
              'Projected payout', _C.primary, _C.primaryLight)),
        ]),
        const SizedBox(height: 12),

        // Formula
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(children: [
            Icon(Icons.calculate_outlined, size: 14, color: _C.textSec),
            SizedBox(width: 8),
            Text('Formula: Last Basic Salary × 15/26 × No. of Years',
                style: TextStyle(fontSize: 11, color: _C.textSec)),
          ]),
        ),
      ]),
    );
  }

  Widget _gratuityBox(String label, String value, String sub,
      Color color, Color bg) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(fontSize: 10, color: _C.textSec)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800,
                  color: color, letterSpacing: -0.5)),
          Text(sub,
              style: TextStyle(
                  fontSize: 9, color: color.withValues(alpha: .7))),
        ]),
      );

  // ─────────────────────────────────────────────
  // CTC BREAKDOWN
  // ─────────────────────────────────────────────
  Widget _buildCTCBreakdown() {
    final items = [
      ('Fixed Pay',       85000.0, _C.primary),
      ('Benefits',        11833.0, _C.teal),    // monthly avg of 1.42L/yr
      ('Employer PF',      5100.0, _C.purple),
      ('Employer ESIC',    2127.0, _C.orange),
      ('Gratuity (mly)',   1042.0, _C.successDark),
    ];
    final total = items.fold(0.0, (s, i) => s + i.$2);

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
          Row(children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                  color: _C.primaryLight,
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.pie_chart_outline_rounded,
                  size: 16, color: _C.primary),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('CTC Breakdown (Monthly)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                        color: _C.textPrimary)),
                Text('Includes all direct & indirect components',
                    style: TextStyle(fontSize: 10, color: _C.textSec)),
              ]),
            ),
          ]),
          const SizedBox(height: 16),

          // Stacked horizontal bar
          ...items.map((item) {
            final (label, amount, color) = item;
            final pct = amount / total;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(children: [
                Row(children: [
                  Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 8),
                  Expanded(child: Text(label,
                      style: const TextStyle(
                          fontSize: 12, color: _C.textPrimary))),
                  Text(_fmtCurrency(amount),
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: color)),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 34,
                    child: Text('${(pct * 100).round()}%',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontSize: 10, color: _C.textSec)),
                  ),
                ]),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 5,
                    backgroundColor: _C.surface,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ]),
            );
          }),

          Container(height: 1, color: _C.border,
              margin: const EdgeInsets.symmetric(vertical: 8)),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Monthly CTC',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                      color: _C.textPrimary)),
              Text(_fmtCurrency(total),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800,
                      color: _C.primary)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BENEFIT CARD (grid tile)
// ─────────────────────────────────────────────
class _BenefitCard extends StatefulWidget {
  final _Benefit benefit;
  final VoidCallback onTap;

  const _BenefitCard({required this.benefit, required this.onTap});

  @override
  State<_BenefitCard> createState() => _BenefitCardState();
}

class _BenefitCardState extends State<_BenefitCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final b = widget.benefit;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: b.highlighted ? b.color : _C.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: b.highlighted ? b.color : _C.border,
              width: b.highlighted ? 0 : 1,
            ),
            boxShadow: b.highlighted
                ? [BoxShadow(
                    color: b.color.withValues(alpha: .3),
                    blurRadius: 12, offset: const Offset(0, 4))]
                : [BoxShadow(
                    color: Colors.black.withValues(alpha: .04),
                    blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top row: icon + category
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: b.highlighted
                          ? Colors.white.withValues(alpha: .2)
                          : b.bg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(b.icon, size: 18,
                        color: b.highlighted ? Colors.white : b.color),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: b.highlighted
                          ? Colors.white.withValues(alpha: .2)
                          : b.bg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(b.category,
                        style: TextStyle(
                            fontSize: 8, fontWeight: FontWeight.w700,
                            color: b.highlighted
                                ? Colors.white.withValues(alpha: .9)
                                : b.color)),
                  ),
                ],
              ),

              // Text
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(b.title,
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: b.highlighted
                            ? Colors.white
                            : _C.textPrimary),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(b.value,
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800,
                        color: b.highlighted ? Colors.white : b.color,
                        letterSpacing: -0.5)),
                Text(b.subtitle,
                    style: TextStyle(
                        fontSize: 9,
                        color: b.highlighted
                            ? Colors.white60
                            : _C.textTert)),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BENEFIT DETAIL SHEET
// ─────────────────────────────────────────────
class _BenefitDetailSheet extends StatelessWidget {
  final _Benefit benefit;
  final VoidCallback? onCta;

  const _BenefitDetailSheet({required this.benefit, this.onCta});

  @override
  Widget build(BuildContext context) {
    final b = benefit;
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      expand: false,
      builder: (_, ctrl) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: _C.border,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 18),

            // Header
            Row(children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                    color: b.bg, borderRadius: BorderRadius.circular(14)),
                child: Icon(b.icon, size: 26, color: b.color),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700,
                          color: _C.textPrimary)),
                  Text(b.value,
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800,
                          color: b.color, letterSpacing: -0.5)),
                ],
              )),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                    color: b.bg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: b.color.withValues(alpha: .2))),
                child: Text(b.category,
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: b.color)),
              ),
            ]),
            const SizedBox(height: 16),

            Expanded(child: ListView(
              controller: ctrl,
              children: [
                // Description
                Text(b.description,
                    style: const TextStyle(
                        fontSize: 13, color: _C.textPrimary, height: 1.6)),
                const SizedBox(height: 16),

                // Details grid
                Container(
                  decoration: BoxDecoration(
                    color: _C.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: b.details.asMap().entries.map((e) {
                      final i = e.key;
                      final d = e.value;
                      return Column(children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 11),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(d.label,
                                  style: const TextStyle(
                                      fontSize: 12, color: _C.textSec)),
                              const SizedBox(width: 16),
                              Flexible(
                                child: Text(d.value,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _C.textPrimary),
                                    textAlign: TextAlign.right),
                              ),
                            ],
                          ),
                        ),
                        if (i < b.details.length - 1)
                          Container(height: 1, color: _C.border,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 14)),
                      ]);
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // CTA
                if (onCta != null)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: onCta,
                      icon: const Icon(Icons.add_circle_outline_rounded,
                          size: 18),
                      label: Text(b.ctaLabel!,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: b.color,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  )
                else
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
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                    ),
                  ),
              ],
            )),
          ],
        ),
      ),
    );
  }
}