// ============================================================
// ISF HR Portal — Help & Support Screen
// File: lib/screens/settings/help_screen.dart
//
// Features:
//   - Quick action row (Chat / Call / Email / Ticket)
//   - Search bar to filter FAQs
//   - FAQ categories (accordion sections per category)
//   - Expandable FAQ items with answer + rating thumbs
//   - "Was this helpful?" per FAQ
//   - Contact support card with availability
//   - Video tutorials / guides list
//   - App version + feedback button
//   - Report a bug flow (bottom sheet form)
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
  static const error = Color(0xFFEF4444);
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
class _FAQ {
  final String id;
  final String question;
  final String answer;
  bool isExpanded = false;
  int? helpRating; // 1=helpful, -1=not helpful, null=unrated

  _FAQ({
    required this.id,
    required this.question,
    required this.answer,
  });
}

class _FAQCategory {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final Color bg;
  final List<_FAQ> faqs;
  bool isExpanded;

  _FAQCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.bg,
    required this.faqs,
    this.isExpanded = false,
  });
}

class _Guide {
  final String title;
  final String subtitle;
  final String duration;
  final IconData icon;
  final Color color;
  final Color bg;

  const _Guide({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.icon,
    required this.color,
    required this.bg,
  });
}

// ─────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────
final _faqCategories = [
  _FAQCategory(
    id: 'attendance',
    title: 'Attendance & Leave',
    icon: Icons.event_outlined,
    color: _C.primary,
    bg: _C.primaryLight,
    isExpanded: true,
    faqs: [
      _FAQ(
          id: 'a1',
          question: 'How do I apply for leave?',
          answer:
              'Go to Modules → Leave Apply. Select the leave type (Casual, Sick, Earned, or Comp Off), choose your from and to dates, enter a reason, select your reporting manager, and tap Submit Request. You\'ll receive a notification when your manager approves or rejects the request.'),
      _FAQ(
          id: 'a2',
          question: 'How do I regularize a missed punch?',
          answer:
              'Go to Modules → Regularize. Select the date of the missed punch, choose the regularization type (Missing Punch In/Out, Wrong Time, etc.), set the correct time, select your work location, provide a reason, and submit. Your manager will review within 2 working days.'),
      _FAQ(
          id: 'a3',
          question: 'Where do I view my leave balance?',
          answer:
              'Your leave balances are available in Modules → Leave Balance. You\'ll see Casual (CL), Sick (SL), Earned (EL), and Comp Off balances with a breakdown of used, pending, and remaining days. You can also view a monthly usage chart and gratuity projection.'),
      _FAQ(
          id: 'a4',
          question: 'How do I request a reliever for a day?',
          answer:
              'Go to Modules → Reliever. Select the date you need coverage, pick your shift, choose the reason, optionally search for a preferred team member, and submit. You can also directly assign a reliever from the Available Relievers Today list.'),
      _FAQ(
          id: 'a5',
          question: 'What is the OT policy?',
          answer:
              'Overtime is logged at 1.5× your hourly rate. Standard shift is 9 hours (9 AM–6 PM). Any work beyond this qualifies as OT. Log your OT from Modules → Overtime by entering date, from/to times, and reason. Your manager will approve, and you can claim Comp Off or cash payout once approved.'),
    ],
  ),
  _FAQCategory(
    id: 'payroll',
    title: 'Payroll & Benefits',
    icon: Icons.account_balance_wallet_outlined,
    color: _C.successDark,
    bg: _C.successLight,
    faqs: [
      _FAQ(
          id: 'p1',
          question: 'When is my salary credited?',
          answer:
              'Salary is credited on the last working day of each month. For months where the 31st (or 30th) falls on a weekend, salary is credited on the preceding Friday. For April 2026, salary was credited on 30 April. Check the Notices section for any changes to the processing schedule.'),
      _FAQ(
          id: 'p2',
          question: 'How do I download my payslip?',
          answer:
              'Go to Modules → Payslip. Tap the month you want from the horizontal month selector. You can preview the payslip, download it as a PDF, or email it to your registered work email address. All payslips from the last 12 months are available.'),
      _FAQ(
          id: 'p3',
          question: 'How do I apply for a salary advance?',
          answer:
              'Go to Modules → Advance. Use the slider to select your advance amount (up to 50% of gross salary), choose your repayment tenure (1–6 months), select a reason, and submit. A confirmation dialog will show your EMI details before submitting. Repayment is auto-deducted from monthly salary.'),
      _FAQ(
          id: 'p4',
          question: 'How do I update my IT declaration?',
          answer:
              'Go to Modules → Tax / IT. Choose your tax regime (Old or New), expand each section (80C, 80D, HRA, etc.), and enter your investment amounts. The app calculates your tax liability in real time. Submit your declaration before the 15 Dec deadline.'),
      _FAQ(
          id: 'p5',
          question: 'Where do I view my PF balance?',
          answer:
              'Go to Modules → PF Details. Your EPFO account card shows your PF Account Number and UAN. The balance section shows Employee Share, Employer Share, and EPS balance with animated totals. You can also download your passbook and initiate a transfer from here.'),
    ],
  ),
  _FAQCategory(
    id: 'profile',
    title: 'Profile & Documents',
    icon: Icons.person_outline_rounded,
    color: _C.purple,
    bg: _C.purpleLight,
    faqs: [
      _FAQ(
          id: 'pr1',
          question: 'How do I update my profile information?',
          answer:
              'Go to Modules → My Profile. Tap Edit to switch to edit mode. You can update your personal information (DOB, blood group, etc.), contact details (phone, email, emergency contact), and notification preferences. Changes are saved after a 1.3-second confirmation animation.'),
      _FAQ(
          id: 'pr2',
          question: 'How do I upload a document?',
          answer:
              'Go to Modules → Documents. Tap the Upload FAB at the bottom right. Select the document category (Personal, Employment, Compliance, or Training), enter the document name, choose a file from your device, and tap Upload Document. The file will appear in the list after upload.'),
      _FAQ(
          id: 'pr3',
          question: 'How do I change my profile photo?',
          answer:
              'Go to Modules → My Profile → Edit mode. Tap the camera icon on your profile photo to open the photo picker. You can choose from your gallery or take a new photo. The photo updates immediately after selection.'),
    ],
  ),
  _FAQCategory(
    id: 'tech',
    title: 'Technical Issues',
    icon: Icons.bug_report_outlined,
    color: _C.orange,
    bg: _C.orangeLight,
    faqs: [
      _FAQ(
          id: 't1',
          question: 'The app is not loading. What should I do?',
          answer:
              'First, check your internet connection. If connected, force-close the app and reopen it. If the issue persists, clear the app cache from your device settings (Settings → Apps → ISmart → Clear Cache). If the problem continues, contact IT support at it@isf.com.'),
      _FAQ(
          id: 't2',
          question: 'I forgot my login password. How do I reset it?',
          answer:
              'On the login screen, tap "Forgot Password?" below the login button. Enter your registered work email address. You\'ll receive a password reset link within 5 minutes. If you don\'t receive it, check your Spam folder or contact HR at hr@isf.com.'),
      _FAQ(
          id: 't3',
          question: 'My biometric login is not working.',
          answer:
              'If Face ID or fingerprint login fails, tap "Use Password Instead" to log in with your credentials. Then go to Settings → Security → Re-enable Biometric Login to reconfigure. Ensure your device biometrics are enrolled in your phone settings. Contact IT if the issue persists.'),
      _FAQ(
          id: 't4',
          question: 'Notifications are not appearing.',
          answer:
              'Check that notifications are enabled for the ISmart app in your device settings (Settings → Notifications → ISmart HR Portal → Allow). Also check in-app preferences via Notifications → Settings icon → ensure your preferred channels are enabled.'),
    ],
  ),
  _FAQCategory(
    id: 'selfservice',
    title: 'Self Service',
    icon: Icons.self_improvement_outlined,
    color: _C.teal,
    bg: _C.tealLight,
    faqs: [
      _FAQ(
          id: 's1',
          question: 'How do I raise a helpdesk ticket?',
          answer:
              'Go to Modules → Tickets. Tap "Raise Ticket". Select the category (IT, HR, Admin, Finance, or Facilities), choose a subcategory, set the priority, enter a subject and description, optionally attach a screenshot, and submit. You\'ll receive updates as your ticket is processed.'),
      _FAQ(
          id: 's2',
          question: 'How do I submit a conveyance claim?',
          answer:
              'Go to Modules → Conveyance. Tap the "+" button to add expense entries — select date, trip type, transport mode, from/to locations, and amount. Add all entries for the month, then tap Submit Claim. Your manager will approve and the amount will be credited in the next payroll cycle.'),
      _FAQ(
          id: 's3',
          question: 'How do I request my uniform size update?',
          answer:
              'Go to Modules → Uniform Sizes. Check your current recorded sizes on the summary card. Select the items you need and tap each size in the grid selector. Set your fit preference and tap Submit Request. Your updated uniform will be dispatched within 7 working days.'),
    ],
  ),
];

const _guides = [
  _Guide(
    title: 'Getting Started with ISmart',
    subtitle: 'A complete walkthrough of all modules',
    duration: '8 min read',
    icon: Icons.play_circle_outline_rounded,
    color: _C.primary,
    bg: _C.primaryLight,
  ),
  _Guide(
    title: 'How to Apply for Leave',
    subtitle: 'Step-by-step leave application guide',
    duration: '3 min read',
    icon: Icons.event_available_outlined,
    color: _C.successDark,
    bg: _C.successLight,
  ),
  _Guide(
    title: 'IT Declaration — Old vs New Regime',
    subtitle: 'Compare regimes and declare investments',
    duration: '5 min read',
    icon: Icons.calculate_outlined,
    color: _C.accent,
    bg: _C.accentLight,
  ),
  _Guide(
    title: 'Payslip & Salary Understanding',
    subtitle: 'Breaking down your CTC components',
    duration: '4 min read',
    icon: Icons.receipt_long_outlined,
    color: _C.teal,
    bg: _C.tealLight,
  ),
  _Guide(
    title: 'Regularize Your Attendance',
    subtitle: 'Fix missed punches and wrong times',
    duration: '2 min read',
    icon: Icons.edit_calendar_outlined,
    color: _C.orange,
    bg: _C.orangeLight,
  ),
];

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<_FAQCategory> _categories = _faqCategories;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Search filter ─────────────────────────────
  List<_FAQCategory> get _filtered {
    if (_searchQuery.isEmpty) return _categories;
    final q = _searchQuery.toLowerCase();
    return _categories
        .map((cat) {
          final matchFaqs = cat.faqs
              .where((f) =>
                  f.question.toLowerCase().contains(q) ||
                  f.answer.toLowerCase().contains(q))
              .toList();
          if (matchFaqs.isEmpty) return null;
          // Return a copy with only matching FAQs, all expanded
          return _FAQCategory(
            id: cat.id,
            title: cat.title,
            icon: cat.icon,
            color: cat.color,
            bg: cat.bg,
            faqs: matchFaqs,
            isExpanded: true,
          );
        })
        .whereType<_FAQCategory>()
        .toList();
  }

  int get _totalFaqs => _categories.fold(0, (s, c) => s + c.faqs.length);

  void _snack(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: bg,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  void _showBugReport() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _BugReportSheet(
        onSubmit: () {
          Navigator.pop(context);
          _snack(
              'Bug report submitted ✅ — Thank you for helping improve ISmart!',
              _C.successDark);
        },
      ),
    );
  }

  void _copyEmail(String email) {
    Clipboard.setData(ClipboardData(text: email));
    _snack('$email copied to clipboard', _C.textSec);
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
        children: [
          _buildHeroCard(),
          const SizedBox(height: 16),
          _buildQuickActions(),
          const SizedBox(height: 20),
          _buildSearchBar(),
          const SizedBox(height: 16),

          // FAQ header
          Row(children: [
            const Text('Frequently Asked Questions',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary)),
            const Spacer(),
            Text('$_totalFaqs questions',
                style: const TextStyle(fontSize: 11, color: _C.textSec)),
          ]),
          const SizedBox(height: 10),

          // FAQs
          if (filtered.isEmpty)
            _EmptySearch(query: _searchQuery)
          else
            ...filtered.map((cat) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _FAQCategoryCard(
                    category: cat,
                    onToggleCategory: () {
                      // If in search mode, skip — categories always open
                      if (_searchQuery.isNotEmpty) return;
                      setState(() => cat.isExpanded = !cat.isExpanded);
                    },
                    onToggleFAQ: (faq) => setState(() {
                      faq.isExpanded = !faq.isExpanded;
                    }),
                    onRate: (faq, helpful) => setState(() {
                      faq.helpRating = helpful ? 1 : -1;
                    }),
                  ),
                )),

          const SizedBox(height: 16),
          _buildGuidesSection(),
          const SizedBox(height: 16),
          _buildContactCard(),
          const SizedBox(height: 16),
          _buildAppInfo(),
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
        title: const Text('Help & Support',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        actions: [
          TextButton.icon(
            onPressed: _showBugReport,
            icon: const Icon(Icons.bug_report_outlined, size: 16),
            label: const Text('Report Bug'),
            style: TextButton.styleFrom(
              foregroundColor: _C.error,
              textStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
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
          colors: [Color(0xFF1D4ED8), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: _C.primary.withValues(alpha: .3),
              blurRadius: 14,
              offset: const Offset(0, 5))
        ],
      ),
      child: Row(children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('How can we help you?',
              style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3)),
          const SizedBox(height: 6),
          const Text(
            'Browse FAQs, watch guides, or reach our support team directly.',
            style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.access_time_rounded, size: 12, color: Colors.white70),
              SizedBox(width: 5),
              Text('Mon–Fri · 9 AM – 6 PM',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500)),
            ]),
          ),
        ])),
        const SizedBox(width: 16),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(18)),
          child: const Icon(Icons.support_agent_rounded,
              size: 34, color: Colors.white),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────
  // QUICK ACTIONS
  // ─────────────────────────────────────────────
  Widget _buildQuickActions() {
    final actions = [
      (
        Icons.chat_bubble_outline_rounded,
        'Chat',
        _C.primary,
        _C.primaryLight,
        () => _snack('Opening live chat…', _C.primary)
      ),
      (
        Icons.call_outlined,
        'Call HR',
        _C.successDark,
        _C.successLight,
        () => _copyEmail(
              '+91 98100 11111',
            )
      ),
      (
        Icons.email_outlined,
        'Email',
        _C.accent,
        _C.accentLight,
        () => _copyEmail('support@isf.com')
      ),
      (
        Icons.confirmation_number_outlined,
        'Ticket',
        _C.orange,
        _C.orangeLight,
        () => _snack('Opening ticket form…', _C.orange)
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.map((a) {
          final (icon, label, color, bg, onTap) = a;
          return GestureDetector(
            onTap: onTap,
            child: Column(children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                    color: bg, borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 6),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _C.textSec)),
            ]),
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SEARCH BAR
  // ─────────────────────────────────────────────
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchCtrl,
      onChanged: (v) => setState(() => _searchQuery = v),
      style: const TextStyle(fontSize: 14, color: _C.textPrimary),
      decoration: InputDecoration(
        hintText: 'Search FAQs…',
        hintStyle: const TextStyle(fontSize: 14, color: _C.textTert),
        prefixIcon:
            const Icon(Icons.search_rounded, size: 20, color: _C.textTert),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded,
                    size: 18, color: _C.textTert),
                onPressed: () {
                  _searchCtrl.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
        filled: true,
        fillColor: _C.card,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _C.border, width: 1.5)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _C.border, width: 1.5)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _C.primary, width: 1.5)),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // GUIDES SECTION
  // ─────────────────────────────────────────────
  Widget _buildGuidesSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('User Guides',
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _C.textPrimary)),
      const SizedBox(height: 10),
      ..._guides.map((g) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => _snack('Opening: ${g.title}', _C.textSec),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _C.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _C.border),
                ),
                child: Row(children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: g.bg, borderRadius: BorderRadius.circular(12)),
                    child: Icon(g.icon, size: 22, color: g.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(g.title,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _C.textPrimary)),
                        const SizedBox(height: 2),
                        Text(g.subtitle,
                            style: const TextStyle(
                                fontSize: 11, color: _C.textSec)),
                      ])),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: _C.surface,
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.schedule_outlined,
                          size: 11, color: _C.textSec),
                      const SizedBox(width: 3),
                      Text(g.duration,
                          style:
                              const TextStyle(fontSize: 10, color: _C.textSec)),
                    ]),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right_rounded,
                      size: 18, color: _C.textTert),
                ]),
              ),
            ),
          )),
    ]);
  }

  // ─────────────────────────────────────────────
  // CONTACT CARD
  // ─────────────────────────────────────────────
  Widget _buildContactCard() {
    final contacts = [
      (
        Icons.people_outline_rounded,
        'HR Support',
        'hr@isf.com',
        _C.purple,
        _C.purpleLight
      ),
      (
        Icons.computer_outlined,
        'IT Helpdesk',
        'it@isf.com',
        _C.teal,
        _C.tealLight
      ),
      (
        Icons.account_balance_outlined,
        'Payroll',
        'payroll@isf.com',
        _C.successDark,
        _C.successLight
      ),
      (
        Icons.admin_panel_settings_outlined,
        'Admin',
        'admin@isf.com',
        _C.orange,
        _C.orangeLight
      ),
    ];

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
                child: const Icon(Icons.contact_support_outlined,
                    size: 16, color: _C.primary)),
            const SizedBox(width: 10),
            const Text('Contact Support',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                  color: _C.successLight,
                  borderRadius: BorderRadius.circular(20)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.circle, size: 7, color: _C.successDark),
                SizedBox(width: 5),
                Text('Online',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _C.successDark)),
              ]),
            ),
          ]),
        ),
        Container(height: 1, color: _C.border),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
              children: contacts.asMap().entries.map((e) {
            final (icon, label, email, color, bg) = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _copyEmail(email),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  decoration: BoxDecoration(
                    color: bg.withValues(alpha: .5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: .2)),
                  ),
                  child: Row(children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                          color: bg, borderRadius: BorderRadius.circular(9)),
                      child: Icon(icon, size: 17, color: color),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(label,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _C.textPrimary)),
                          Text(email,
                              style: TextStyle(fontSize: 11, color: color)),
                        ])),
                    Icon(Icons.copy_outlined,
                        size: 15, color: color.withValues(alpha: .6)),
                  ]),
                ),
              ),
            );
          }).toList()),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────
  // APP INFO
  // ─────────────────────────────────────────────
  Widget _buildAppInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: Column(children: [
        // App logo row
        Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: _C.primary, borderRadius: BorderRadius.circular(12)),
            child: const Center(
              child: Text('ISF',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5)),
            ),
          ),
          const SizedBox(width: 12),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ISmart HR Portal',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary)),
            Text('ISF Solutions Pvt. Ltd.',
                style: TextStyle(fontSize: 11, color: _C.textSec)),
          ]),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: _C.primaryLight,
                borderRadius: BorderRadius.circular(20)),
            child: const Text('v3.2.1',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _C.primary)),
          ),
        ]),
        const SizedBox(height: 14),
        Container(height: 1, color: _C.border),
        const SizedBox(height: 14),

        // Info rows
        _infoRow('Version', '3.2.1 (Build 241)'),
        _infoRow('Last Updated', '29 Apr 2026'),
        _infoRow('Platform', 'Flutter 3.22 · Dart 3.4'),
        _infoRow('Environment', 'Production'),
        const SizedBox(height: 14),

        // Feedback + Rate
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _snack('Opening feedback form…', _C.textSec),
              icon: const Icon(Icons.rate_review_outlined, size: 16),
              label: const Text('Give Feedback'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _C.textSec,
                side: const BorderSide(color: _C.border, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 11),
                textStyle:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () =>
                  _snack('⭐ Thank you for rating ISmart!', _C.successDark),
              icon: const Icon(Icons.star_outline_rounded, size: 16),
              label: const Text('Rate App'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 11),
                textStyle:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        const Text('© 2026 ISF Solutions Pvt. Ltd. · All rights reserved.',
            style: TextStyle(fontSize: 10, color: _C.textTert),
            textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          SizedBox(
              width: 100,
              child: Text(label,
                  style: const TextStyle(fontSize: 12, color: _C.textSec))),
          Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _C.textPrimary)),
        ]),
      );
}

// ─────────────────────────────────────────────
// FAQ CATEGORY CARD
// ─────────────────────────────────────────────
class _FAQCategoryCard extends StatelessWidget {
  final _FAQCategory category;
  final VoidCallback onToggleCategory;
  final void Function(_FAQ) onToggleFAQ;
  final void Function(_FAQ, bool) onRate;

  const _FAQCategoryCard({
    required this.category,
    required this.onToggleCategory,
    required this.onToggleFAQ,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: category.isExpanded
                ? category.color.withValues(alpha: .3)
                : _C.border,
            width: category.isExpanded ? 1.5 : 1),
      ),
      child: Column(children: [
        // Category header
        InkWell(
          onTap: onToggleCategory,
          borderRadius: BorderRadius.vertical(
              top: const Radius.circular(16),
              bottom: category.isExpanded
                  ? Radius.zero
                  : const Radius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: category.bg,
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(category.icon, size: 18, color: category.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(category.title,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _C.textPrimary)),
                    Text(
                        '${category.faqs.length} question${category.faqs.length != 1 ? "s" : ""}',
                        style:
                            const TextStyle(fontSize: 11, color: _C.textSec)),
                  ])),
              AnimatedRotation(
                turns: category.isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 220),
                child: Icon(Icons.keyboard_arrow_down_rounded,
                    size: 22, color: category.color),
              ),
            ]),
          ),
        ),

        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: category.isExpanded
              ? Column(children: [
                  Container(height: 1, color: _C.border),
                  ...category.faqs.asMap().entries.map((e) {
                    final i = e.key;
                    final faq = e.value;
                    return _FAQItem(
                      faq: faq,
                      isLast: i == category.faqs.length - 1,
                      categoryColor: category.color,
                      onToggle: () => onToggleFAQ(faq),
                      onRate: (helpful) => onRate(faq, helpful),
                    );
                  }),
                ])
              : const SizedBox.shrink(),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// FAQ ITEM
// ─────────────────────────────────────────────
class _FAQItem extends StatelessWidget {
  final _FAQ faq;
  final bool isLast;
  final Color categoryColor;
  final VoidCallback onToggle;
  final void Function(bool) onRate;

  const _FAQItem({
    required this.faq,
    required this.isLast,
    required this.categoryColor,
    required this.onToggle,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(faq.question,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            faq.isExpanded ? FontWeight.w700 : FontWeight.w600,
                        color: _C.textPrimary)),
              ),
              const SizedBox(width: 8),
              AnimatedRotation(
                turns: faq.isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.keyboard_arrow_down_rounded,
                    size: 18, color: _C.textTert),
              ),
            ]),

            // Answer
            if (faq.isExpanded) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: _C.surface, borderRadius: BorderRadius.circular(10)),
                child: Text(faq.answer,
                    style: const TextStyle(
                        fontSize: 13, color: _C.textPrimary, height: 1.6)),
              ),
              const SizedBox(height: 10),

              // Was this helpful?
              Row(children: [
                const Text('Was this helpful?',
                    style: TextStyle(fontSize: 11, color: _C.textSec)),
                const SizedBox(width: 10),
                _rateBtn(Icons.thumb_up_outlined, 1, faq.helpRating,
                    categoryColor, () => onRate(true)),
                const SizedBox(width: 6),
                _rateBtn(Icons.thumb_down_outlined, -1, faq.helpRating,
                    _C.error, () => onRate(false)),
                if (faq.helpRating != null) ...[
                  const SizedBox(width: 10),
                  Text(
                    faq.helpRating == 1
                        ? '👍 Thank you!'
                        : 'We\'ll improve this answer.',
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            faq.helpRating == 1 ? _C.successDark : _C.textSec),
                  ),
                ],
              ]),
            ],
          ]),
        ),
      ),
      if (!isLast)
        Container(
            height: 1,
            color: _C.border,
            margin: const EdgeInsets.symmetric(horizontal: 16)),
    ]);
  }

  Widget _rateBtn(
      IconData icon, int val, int? current, Color color, VoidCallback onTap) {
    final isActive = current == val;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: .12) : _C.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? color : _C.border, width: 1.5),
        ),
        child: Icon(icon, size: 15, color: isActive ? color : _C.textSec),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BUG REPORT SHEET
// ─────────────────────────────────────────────
class _BugReportSheet extends StatefulWidget {
  final VoidCallback onSubmit;
  const _BugReportSheet({required this.onSubmit});

  @override
  State<_BugReportSheet> createState() => _BugReportSheetState();
}

class _BugReportSheetState extends State<_BugReportSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _hasScreenshot = false;
  bool _submitting = false;
  String? _area;

  static const _areas = [
    'Attendance',
    'Leave',
    'Payroll',
    'Documents',
    'Profile',
    'Self Service',
    'App Crash',
    'Other',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
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
            const SizedBox(height: 16),
            const Row(children: [
              Icon(Icons.bug_report_outlined, size: 20, color: _C.error),
              SizedBox(width: 8),
              Text('Report a Bug',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary)),
            ]),
            const SizedBox(height: 4),
            const Text(
                'Help us improve by describing the issue you encountered.',
                style: TextStyle(fontSize: 12, color: _C.textSec)),
            const SizedBox(height: 16),

            // Affected area
            const Text('Affected Area *',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _C.textPrimary)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                  color: _C.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _C.border, width: 1.5)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _area,
                  hint: const Text('Select module',
                      style: TextStyle(fontSize: 13, color: _C.textTert)),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 20, color: _C.textSec),
                  style: const TextStyle(
                      fontSize: 13,
                      color: _C.textPrimary,
                      fontWeight: FontWeight.w500),
                  onChanged: (v) => setState(() => _area = v),
                  items: _areas
                      .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Title
            const Text('Title *',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _C.textPrimary)),
            const SizedBox(height: 6),
            TextField(
              controller: _titleCtrl,
              maxLength: 80,
              style: const TextStyle(fontSize: 13, color: _C.textPrimary),
              decoration: _inputDeco('Brief description of the bug'),
            ),
            const SizedBox(height: 8),

            // Description
            const Text('Description *',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _C.textPrimary)),
            const SizedBox(height: 6),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              maxLength: 300,
              style: const TextStyle(fontSize: 13, color: _C.textPrimary),
              decoration: _inputDeco(
                  'Steps to reproduce, what happened, what was expected…'),
            ),
            const SizedBox(height: 8),

            // Screenshot toggle
            GestureDetector(
              onTap: () => setState(() => _hasScreenshot = !_hasScreenshot),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _hasScreenshot ? _C.successLight : _C.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: _hasScreenshot
                          ? _C.success.withValues(alpha: .4)
                          : _C.border,
                      width: _hasScreenshot ? 1.5 : 1),
                ),
                child: Row(children: [
                  Icon(
                      _hasScreenshot
                          ? Icons.check_circle_outline_rounded
                          : Icons.attach_file_rounded,
                      size: 18,
                      color: _hasScreenshot ? _C.successDark : _C.textSec),
                  const SizedBox(width: 8),
                  Text(
                      _hasScreenshot
                          ? 'screenshot.png attached'
                          : 'Attach screenshot (optional)',
                      style: TextStyle(
                          fontSize: 12,
                          color: _hasScreenshot ? _C.successDark : _C.textSec)),
                ]),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitting
                    ? null
                    : () async {
                        if (_area == null || _titleCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('Please fill in all required fields'),
                            backgroundColor: _C.error,
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 2),
                          ));
                          return;
                        }
                        setState(() => _submitting = true);
                        await Future.delayed(
                            const Duration(milliseconds: 1300));
                        if (mounted) widget.onSubmit();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.error,
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
                    : const Text('Submit Bug Report',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: _C.textTert),
        filled: true,
        fillColor: _C.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        counterStyle: const TextStyle(fontSize: 10, color: _C.textTert),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _C.border, width: 1.5)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _C.border, width: 1.5)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _C.error, width: 1.5)),
      );
}

// ─────────────────────────────────────────────
// EMPTY SEARCH STATE
// ─────────────────────────────────────────────
class _EmptySearch extends StatelessWidget {
  final String query;
  const _EmptySearch({required this.query});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.search_off_rounded,
                size: 48, color: _C.textDisabled),
            const SizedBox(height: 12),
            Text('No results for "$query"',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary)),
            const SizedBox(height: 6),
            const Text('Try different keywords or browse categories above.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: _C.textSec, height: 1.5)),
          ]),
        ),
      );
}
