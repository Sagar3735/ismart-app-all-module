// ============================================================
// ISF HR Portal — Employee Details Screen
// File: lib/screens/personal/employee_details_screen.dart
//
// Dependencies (already in pubspec.yaml):
//   - cached_network_image
//   - provider
//   - intl
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ─── Replace these with your actual imports ───────────────
// import '../../theme/app_colors.dart';
// import '../../theme/app_text_styles.dart';
// import '../../data/mock_data.dart';
// import '../../models/employee.dart';
// ──────────────────────────────────────────────────────────

// ─────────────────────────────────────────────
// INLINE THEME (remove once you have theme files)
// ─────────────────────────────────────────────
class _C {
  static const primary = Color(0xFF2563EB);
  static const primaryLight = Color(0xFFEFF6FF);
  static const accent = Color(0xFF6366F1);
  static const success = Color(0xFF22C55E);
  static const successLight = Color(0xFFDCFCE7);
  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFEF9C3);
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFEF2F2);
  static const bg = Color(0xFFF8FAFC);
  static const card = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF0F172A);
  static const textSec = Color(0xFF64748B);
  static const textTert = Color(0xFF94A3B8);
  static const border = Color(0xFFE2E8F0);
}

// ─────────────────────────────────────────────
// MOCK DATA (inline — remove once mockData.dart is wired)
// ─────────────────────────────────────────────
class _MockEmployee {
  static const id = 'ISF-2024-0042';
  static const name = 'Amit Patil';
  static const designation = 'Full Stack Developer';
  static const department = 'Information Technology';
  static const email = 'amit.patil@isf.com';
  static const phone = '+91 98765 43210';
  static const altPhone = '+91 91234 56789';
  static const bloodGroup = 'B+';
  static const doj = '15 March 2024';
  static const dob = '23 April 1997';
  static const gender = 'Male';
  static const maritalStatus = 'Married';
  static const nationality = 'Indian';
  static const religion = 'Hindu';
  static const workLocation = 'Wadala, Mumbai';
  static const workMode = 'On-Site';
  static const employeeType = 'Full-Time';
  static const grade = 'L3 — Senior';
  static const shift = 'Standard (09:00 – 18:00)';
  static const reportingTo = 'Priya Mehta';
  static const pfNumber = 'MH/BAN/1234567';
  static const uanNumber = '100987654321';
  static const esicNumber = 'MH-1234567890';
  static const panNumber = 'ABCDE1234F';
  static const aadhaarLast4 = '••••  ••••  5678';
  static const bankName = 'HDFC Bank';
  static const accountNumber = '••••  ••••  2345';
  static const ifscCode = 'HDFC0001234';
  static const address =
      '12, Shivaji Nagar, Wadala East, Mumbai – 400037, Maharashtra';
  static const photo = 'https://i.pravatar.cc/150?img=12';
}

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class EmployeeDetailsScreen extends StatefulWidget {
  const EmployeeDetailsScreen({super.key});

  @override
  State<EmployeeDetailsScreen> createState() => _EmployeeDetailsScreenState();
}

class _EmployeeDetailsScreenState extends State<EmployeeDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _scrollController = ScrollController();
  bool _headerCollapsed = false;

  static const _tabs = ['Personal', 'Employment', 'Statutory', 'Bank'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _scrollController.addListener(() {
      final collapsed = _scrollController.offset > 120;
      if (collapsed != _headerCollapsed) {
        setState(() => _headerCollapsed = collapsed);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(innerBoxIsScrolled),
          _buildTabBar(),
        ],
        body: TabBarView(
          controller: _tabController,
          children: const [
            _PersonalTab(),
            _EmploymentTab(),
            _StatutoryTab(),
            _BankTab(),
          ],
        ),
      ),
    );
  }

  // ── Sliver App Bar (collapsing hero) ──────────────────────
  Widget _buildSliverAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: _C.card,
      surfaceTintColor: Colors.transparent,
      elevation: innerBoxIsScrolled ? 1 : 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        color: _C.textPrimary,
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/');
          }
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined, size: 20),
          color: _C.textPrimary,
          onPressed: () {},
          tooltip: 'Share',
        ),
        IconButton(
          icon: const Icon(Icons.download_outlined, size: 20),
          color: _C.textPrimary,
          onPressed: () => _showDownloadSheet(context),
          tooltip: 'Download',
        ),
        const SizedBox(width: 4),
      ],
      title: AnimatedOpacity(
        opacity: _headerCollapsed ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_MockEmployee.name,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _C.textPrimary)),
            Text(_MockEmployee.designation,
                style: TextStyle(fontSize: 11, color: _C.textSec)),
          ],
        ),
      ),
      flexibleSpace: const FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: _HeroHeader(),
      ),
    );
  }

  // ── Tab Bar (sticky) ───────────────────────────────────────
  Widget _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        TabBar(
          controller: _tabController,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
          labelColor: _C.primary,
          unselectedLabelColor: _C.textSec,
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
          indicatorColor: _C.primary,
          indicatorWeight: 2.5,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: _C.border,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      ),
    );
  }

  void _showDownloadSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _DownloadSheet(),
    );
  }
}

// ─────────────────────────────────────────────
// HERO HEADER
// ─────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _C.card,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 56,
        bottom: 16,
        left: 20,
        right: 20,
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _C.primary, width: 2.5),
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: _MockEmployee.photo,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: _C.primaryLight,
                      child: const Center(
                        child: Text('AP',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: _C.primary)),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: _C.primaryLight,
                      child: const Center(
                        child: Text('AP',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: _C.primary)),
                      ),
                    ),
                  ),
                ),
              ),
              // Active badge
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _C.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: _C.card, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Info
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_MockEmployee.name,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _C.textPrimary,
                        letterSpacing: -0.3)),
                SizedBox(height: 2),
                Text(_MockEmployee.designation,
                    style: TextStyle(fontSize: 13, color: _C.textSec)),
                SizedBox(height: 6),
                Row(
                  children: [
                    _MiniChip(
                        label: _MockEmployee.id,
                        icon: Icons.badge_outlined,
                        color: _C.primary,
                        bg: _C.primaryLight),
                    SizedBox(width: 6),
                    _MiniChip(
                        label: _MockEmployee.employeeType,
                        icon: Icons.work_outline_rounded,
                        color: _C.success,
                        bg: _C.successLight),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 12, color: _C.textTert),
                    SizedBox(width: 2),
                    Text(_MockEmployee.workLocation,
                        style:
                            TextStyle(fontSize: 11, color: _C.textTert)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB 1 — PERSONAL
// ─────────────────────────────────────────────
class _PersonalTab extends StatelessWidget {
  const _PersonalTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        // Quick contact row
        _QuickContactRow(),
        SizedBox(height: 16),

        // Basic Info
        _Section(
          title: 'Basic Information',
          icon: Icons.person_outline_rounded,
          children: [
            _InfoRow(label: 'Full Name', value: _MockEmployee.name),
            _InfoRow(label: 'Date of Birth', value: _MockEmployee.dob),
            _InfoRow(label: 'Gender', value: _MockEmployee.gender),
            _InfoRow(
                label: 'Blood Group',
                value: _MockEmployee.bloodGroup,
                valueColor: _C.error,
                valueBg: _C.errorLight),
            _InfoRow(
                label: 'Marital Status', value: _MockEmployee.maritalStatus),
            _InfoRow(label: 'Nationality', value: _MockEmployee.nationality),
            _InfoRow(
                label: 'Religion', value: _MockEmployee.religion, isLast: true),
          ],
        ),
        SizedBox(height: 12),

        // Contact
        _Section(
          title: 'Contact Information',
          icon: Icons.contact_phone_outlined,
          children: [
            _InfoRow(
                label: 'Email', value: _MockEmployee.email, isCopyable: true),
            _InfoRow(
                label: 'Mobile', value: _MockEmployee.phone, isCopyable: true),
            _InfoRow(
                label: 'Alternate',
                value: _MockEmployee.altPhone,
                isCopyable: true),
            _InfoRow(
                label: 'Address',
                value: _MockEmployee.address,
                isMultiLine: true,
                isLast: true),
          ],
        ),
        SizedBox(height: 80),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// TAB 2 — EMPLOYMENT
// ─────────────────────────────────────────────
class _EmploymentTab extends StatelessWidget {
  const _EmploymentTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        // Tenure card
        _TenureCard(),
        SizedBox(height: 16),

        _Section(
          title: 'Job Details',
          icon: Icons.work_outline_rounded,
          children: [
            _InfoRow(
                label: 'Employee ID',
                value: _MockEmployee.id,
                isCopyable: true),
            _InfoRow(label: 'Department', value: _MockEmployee.department),
            _InfoRow(label: 'Designation', value: _MockEmployee.designation),
            _InfoRow(
                label: 'Grade',
                value: _MockEmployee.grade,
                valueColor: _C.accent,
                valueBg: Color(0xFFEEF2FF)),
            _InfoRow(label: 'Employee Type', value: _MockEmployee.employeeType),
            _InfoRow(label: 'Date of Joining', value: _MockEmployee.doj),
            _InfoRow(label: 'Shift', value: _MockEmployee.shift),
            _InfoRow(label: 'Work Mode', value: _MockEmployee.workMode),
            _InfoRow(label: 'Work Location', value: _MockEmployee.workLocation),
            _InfoRow(
                label: 'Reporting To',
                value: _MockEmployee.reportingTo,
                isLast: true),
          ],
        ),
        SizedBox(height: 80),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// TAB 3 — STATUTORY
// ─────────────────────────────────────────────
class _StatutoryTab extends StatelessWidget {
  const _StatutoryTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _SensitiveBanner(),
        SizedBox(height: 12),
        _Section(
          title: 'Provident Fund',
          icon: Icons.account_balance_outlined,
          children: [
            _InfoRow(
                label: 'PF Number',
                value: _MockEmployee.pfNumber,
                isCopyable: true),
            _InfoRow(
                label: 'UAN Number',
                value: _MockEmployee.uanNumber,
                isCopyable: true,
                isLast: true),
          ],
        ),
        SizedBox(height: 12),
        _Section(
          title: 'ESIC & Tax',
          icon: Icons.shield_outlined,
          children: [
            _InfoRow(
                label: 'ESIC Number',
                value: _MockEmployee.esicNumber,
                isCopyable: true),
            _InfoRow(
                label: 'PAN Number',
                value: _MockEmployee.panNumber,
                isCopyable: true),
            _InfoRow(
                label: 'Aadhaar',
                value: _MockEmployee.aadhaarLast4,
                isLast: true),
          ],
        ),
        SizedBox(height: 80),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// TAB 4 — BANK
// ─────────────────────────────────────────────
class _BankTab extends StatelessWidget {
  const _BankTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _SensitiveBanner(),
        SizedBox(height: 12),

        // Bank card visual
        _BankCardVisual(),
        SizedBox(height: 16),

        _Section(
          title: 'Bank Account Details',
          icon: Icons.account_balance_wallet_outlined,
          children: [
            _InfoRow(label: 'Bank Name', value: _MockEmployee.bankName),
            _InfoRow(
                label: 'Account Number',
                value: _MockEmployee.accountNumber,
                isCopyable: true),
            _InfoRow(
                label: 'IFSC Code',
                value: _MockEmployee.ifscCode,
                isCopyable: true,
                isLast: true),
          ],
        ),
        SizedBox(height: 80),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE WIDGETS
// ─────────────────────────────────────────────

/// Horizontal quick-action contact strip
class _QuickContactRow extends StatelessWidget {
  const _QuickContactRow();

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.call_outlined, 'Call', _C.success, _C.successLight),
      (Icons.email_outlined, 'Email', _C.primary, _C.primaryLight),
      (Icons.chat_bubble_outline, 'Chat', _C.accent, const Color(0xFFEEF2FF)),
      (Icons.headset_mic_outlined, 'HR', _C.warning, _C.warningLight),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.map((a) {
          final (icon, label, color, bg) = a;
          return _QuickAction(icon: icon, label: label, color: color, bg: bg);
        }).toList(),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color, bg;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: bg, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: _C.textSec)),
        ],
      ),
    );
  }
}

/// Tenure / experience card (Tab 2)
class _TenureCard extends StatelessWidget {
  const _TenureCard();

  @override
  Widget build(BuildContext context) {
    // Hardcoded from mock for now
    const months = 13;
    const years = 1;
    const rem = months % 12;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_rounded,
              color: Colors.white, size: 36),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tenure at ISF',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500)),
                SizedBox(height: 2),
                Text(
                    '$years Year${years != 1 ? "s" : ""} $rem Month${rem != 1 ? "s" : ""}',
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5)),
                Text('Since 15 March 2024',
                    style: TextStyle(fontSize: 11, color: Colors.white60)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Active',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

/// Bank card visual (Tab 4)
class _BankCardVisual extends StatelessWidget {
  const _BankCardVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('HDFC Bank',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
              Icon(Icons.credit_card_rounded,
                  color: Colors.white.withValues(alpha: .5), size: 22),
            ],
          ),
          const Spacer(),
          const Text('••••  ••••  2345',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2)),
          const SizedBox(height: 4),
          const Text(_MockEmployee.name,
              style: TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }
}

/// Sensitive data warning banner (Tabs 3 & 4)
class _SensitiveBanner extends StatelessWidget {
  const _SensitiveBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _C.warningLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _C.warning.withValues(alpha: .3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline_rounded, size: 15, color: _C.warning),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Sensitive information — visible only to you. Do not share with others.',
              style: TextStyle(fontSize: 11, color: Color(0xFF854F0B)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Download bottom sheet
class _DownloadSheet extends StatelessWidget {
  const _DownloadSheet();

  final _formats = const [
    (
      Icons.picture_as_pdf_outlined,
      'Employee Profile PDF',
      'Includes all personal & employment details'
    ),
    (Icons.badge_outlined, 'ID Card', 'Printable ID card format'),
    (
      Icons.text_snippet_outlined,
      'Joining Letter',
      'Official joining confirmation'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
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
          const SizedBox(height: 20),
          const Text('Download Document',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _C.textPrimary)),
          const SizedBox(height: 4),
          const Text('Choose a format to download',
              style: TextStyle(fontSize: 13, color: _C.textSec)),
          const SizedBox(height: 16),
          ..._formats.map((f) {
            final (icon, title, sub) = f;
            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: _C.primaryLight,
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: _C.primary, size: 20),
              ),
              title: Text(title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
              subtitle: Text(sub,
                  style: const TextStyle(fontSize: 11, color: _C.textSec)),
              trailing: const Icon(Icons.download_outlined,
                  size: 18, color: _C.textSec),
              onTap: () {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$title download started'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

/// Section card with title + icon
class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      color: _C.primaryLight,
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, size: 15, color: _C.primary),
                ),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _C.textPrimary)),
              ],
            ),
          ),
          Container(height: 1, color: _C.border),
          ...children,
        ],
      ),
    );
  }
}

/// Single info row inside a section
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isCopyable;
  final bool isMultiLine;
  final bool isLast;
  final Color? valueColor;
  final Color? valueBg;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isCopyable = false,
    this.isMultiLine = false,
    this.isLast = false,
    this.valueColor,
    this.valueBg,
  });

  @override
  Widget build(BuildContext context) {
    Widget valueWidget;

    if (valueBg != null && valueColor != null) {
      // Chip-style value
      valueWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: valueBg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(value,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: valueColor)),
      );
    } else {
      valueWidget = Text(
        value,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: valueColor ?? _C.textPrimary,
        ),
        textAlign: isMultiLine ? TextAlign.left : TextAlign.right,
        maxLines: isMultiLine ? 3 : 1,
        overflow: isMultiLine ? TextOverflow.visible : TextOverflow.ellipsis,
      );
    }

    return InkWell(
      onLongPress: isCopyable
          ? () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label copied'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
          : null,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: isMultiLine
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(label,
                              style: const TextStyle(
                                  fontSize: 12, color: _C.textSec)),
                          if (isCopyable) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.copy_outlined,
                                size: 11, color: _C.textTert),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      valueWidget,
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(label,
                              style: const TextStyle(
                                  fontSize: 12, color: _C.textSec)),
                          if (isCopyable) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.copy_outlined,
                                size: 11, color: _C.textTert),
                          ],
                        ],
                      ),
                      const SizedBox(width: 16),
                      Flexible(child: valueWidget),
                    ],
                  ),
          ),
          if (!isLast)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 1,
              color: _C.border,
            ),
        ],
      ),
    );
  }
}

/// Small chip badge (hero header)
class _MiniChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color, bg;

  const _MiniChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB BAR PERSISTENT HEADER DELEGATE
// ─────────────────────────────────────────────
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: _C.card,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
