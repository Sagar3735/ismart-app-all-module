// ============================================================
// ISF HR Portal — Notices Screen
// File: lib/screens/settings/notices_screen.dart
//
// Features:
//   - Pinned / urgent notices hero section
//   - Category filter chips (All / HR / Policy / IT / Admin / Finance)
//   - Notice cards with type badge, date, author, read indicator
//   - Search bar to filter notices by keyword
//   - Full notice detail bottom sheet (DraggableScrollableSheet)
//   - Acknowledge / sign button on applicable notices
//   - Bookmark / save notice
//   - Attachment download on notices with files
//   - Expiry countdown for time-sensitive notices
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
  static const border = Color(0xFFE2E8F0);
}

// ─────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────
enum _NoticeCategory { hr, policy, it, admin, finance, general }

enum _NoticePriority { urgent, high, normal, low }

class _Notice {
  final String id;
  final String title;
  final String summary;
  final String body;
  final _NoticeCategory category;
  final _NoticePriority priority;
  final String postedOn;
  final String? expiresOn; // null = no expiry
  final String postedBy;
  final String? attachmentName;
  final bool isPinned;
  final bool requiresAck; // acknowledgement required?
  bool isRead;
  bool isBookmarked = false;
  bool hasAcknowledged = false;

  _Notice({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    required this.category,
    required this.priority,
    required this.postedOn,
    this.expiresOn,
    required this.postedBy,
    this.attachmentName,
    this.isPinned = false,
    this.requiresAck = false,
    this.isRead = false,
  });
}

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────
({String label, Color color, Color bg, IconData icon}) _catMeta(
    _NoticeCategory c) {
  switch (c) {
    case _NoticeCategory.hr:
      return (
        label: 'HR',
        color: _C.purple,
        bg: _C.purpleLight,
        icon: Icons.people_outline_rounded
      );
    case _NoticeCategory.policy:
      return (
        label: 'Policy',
        color: _C.primary,
        bg: _C.primaryLight,
        icon: Icons.policy_outlined
      );
    case _NoticeCategory.it:
      return (
        label: 'IT',
        color: _C.teal,
        bg: _C.tealLight,
        icon: Icons.computer_outlined
      );
    case _NoticeCategory.admin:
      return (
        label: 'Admin',
        color: _C.orange,
        bg: _C.orangeLight,
        icon: Icons.admin_panel_settings_outlined
      );
    case _NoticeCategory.finance:
      return (
        label: 'Finance',
        color: _C.successDark,
        bg: _C.successLight,
        icon: Icons.account_balance_outlined
      );
    case _NoticeCategory.general:
      return (
        label: 'General',
        color: _C.textSec,
        bg: _C.surface,
        icon: Icons.campaign_outlined
      );
  }
}

({Color color, Color bg}) _priorityStyle(_NoticePriority p) {
  switch (p) {
    case _NoticePriority.urgent:
      return (color: _C.errorDark, bg: _C.errorLight);
    case _NoticePriority.high:
      return (color: _C.warningDark, bg: _C.warningLight);
    case _NoticePriority.normal:
      return (color: _C.primary, bg: _C.primaryLight);
    case _NoticePriority.low:
      return (color: _C.textSec, bg: _C.surface);
  }
}

// ─────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────
final _allNotices = [
  _Notice(
    id: 'NOT-2026-021',
    title: '🚨 MANDATORY: POSH Training — 10 May 2026',
    summary:
        'All employees must complete the mandatory POSH awareness session. Attendance is compulsory.',
    body: '''Dear Team,

As per the Prevention, Prohibition, and Redressal of Sexual Harassment (POSH) Act, 2013, all employees are mandated to attend the annual POSH awareness training.

📅 Date: Saturday, 10 May 2026
🕙 Time: 10:00 AM – 12:00 PM
📍 Venue: Conference Hall B, 3rd Floor (or via Zoom link below)
🔗 Zoom: https://zoom.isf.com/posh-2026

This session is compulsory for all full-time, part-time, and contract employees. Non-attendance will be noted in your compliance record.

Please confirm your attendance by replying to hr@isf.com before 7 May 2026.

For queries, contact the POSH Committee at posh@isf.com.

Regards,
Sneha Patil
HR Manager, ISF Solutions''',
    category: _NoticeCategory.hr,
    priority: _NoticePriority.urgent,
    postedOn: '29 Apr 2026',
    expiresOn: '10 May 2026',
    postedBy: 'Sneha Patil, HR Manager',
    attachmentName: 'POSH_Training_Agenda_2026.pdf',
    isPinned: true,
    requiresAck: true,
    isRead: false,
  ),
  _Notice(
    id: 'NOT-2026-019',
    title: 'Updated Work From Home Policy — Effective 1 May 2026',
    summary:
        'New WFH policy allows up to 3 days per week with manager approval. Read the updated guidelines.',
    body: '''Dear All,

We are pleased to announce an updated Work From Home (WFH) policy effective from 1 May 2026.

Key Changes:
• Employees may work from home up to 3 days per week.
• WFH days must be pre-approved by your reporting manager.
• Core hours (10 AM – 4 PM) are mandatory for all WFH days.
• WFH is not permitted on days with mandatory in-office events.
• Equipment policy: employees are responsible for their own internet and workspace.

Eligibility:
• Employees with minimum 6 months of tenure.
• All permanent and confirmed employees.
• Not applicable during probation or Performance Improvement Plans (PIPs).

Please read the full policy document attached and reach out to HR for any queries.

Best regards,
People & Culture Team''',
    category: _NoticeCategory.policy,
    priority: _NoticePriority.high,
    postedOn: '27 Apr 2026',
    postedBy: 'People & Culture Team',
    attachmentName: 'WFH_Policy_v4.0_May2026.pdf',
    isPinned: true,
    requiresAck: true,
    isRead: false,
  ),
  _Notice(
    id: 'NOT-2026-017',
    title: 'Scheduled Server Maintenance — 3 May 2026, 11 PM–3 AM',
    summary:
        'ISmart portal and email will be unavailable during maintenance. Plan accordingly.',
    body: '''Team,

The IT department will be performing scheduled server maintenance and infrastructure upgrades.

Impact Window:
• Start: Saturday, 3 May 2026 at 11:00 PM IST
• End: Sunday, 4 May 2026 at 3:00 AM IST

Affected Services:
• ISmart HR Portal (this app)
• Corporate Email (Outlook)
• VPN Access
• Internal wiki and document portal

Services NOT affected:
• Mobile hotspot access
• Personal email accounts
• External client systems

Recommended Actions:
1. Download any required payslips or documents before 11 PM.
2. Submit pending leave/expense requests before the window.
3. Contact the emergency IT line (ext. 9999) for critical issues during maintenance.

We apologise for any inconvenience.

Rahul Kumar
IT Infrastructure Team''',
    category: _NoticeCategory.it,
    priority: _NoticePriority.high,
    postedOn: '25 Apr 2026',
    expiresOn: '04 May 2026',
    postedBy: 'Rahul Kumar, IT Infrastructure',
    isRead: true,
  ),
  _Notice(
    id: 'NOT-2026-015',
    title: 'Q1 Performance Reviews — Schedule Released',
    summary:
        'Q1 performance review slots have been published. Check your assigned slot with your manager.',
    body: '''Dear Team,

The Q1 2026 performance review schedule is now live. Please find your assigned slots below.

Review Period: 5 May – 16 May 2026

Process:
1. Self-Assessment: Complete your self-review by 2 May 2026 via the Goals module.
2. Manager Review: Your manager will schedule a 1:1 conversation.
3. Final Rating: HR will consolidate ratings by 20 May 2026.

What to prepare:
• Key achievements against Q1 goals
• Challenges and learnings
• Goals for Q2 2026

Please ensure your self-assessment is submitted before the deadline. Incomplete submissions may affect your final evaluation.

For any concerns, reach out to your manager or HR at appraisal@isf.com.

Regards,
Performance & Rewards Team''',
    category: _NoticeCategory.hr,
    priority: _NoticePriority.normal,
    postedOn: '22 Apr 2026',
    postedBy: 'Performance & Rewards Team',
    isRead: true,
  ),
  _Notice(
    id: 'NOT-2026-013',
    title: 'May 2026 Salary Processing Date',
    summary:
        'May salary will be credited on 30 May 2026 instead of the usual 31st.',
    body: '''Dear All,

Please note that May 2026 salary will be processed and credited on:

📅 30 May 2026 (Friday)

Reason: 31 May 2026 (Saturday) is a non-working day.

Expense claims and overtime requests for May must be submitted by 20 May 2026 to be included in the current month's processing.

For any payroll-related queries, reach out to Vikram Kadam at payroll@isf.com.

Regards,
Payroll Team''',
    category: _NoticeCategory.finance,
    priority: _NoticePriority.normal,
    postedOn: '20 Apr 2026',
    postedBy: 'Vikram Kadam, Payroll',
    isRead: true,
  ),
  _Notice(
    id: 'NOT-2026-011',
    title: 'New Pantry Rules — Effective Immediately',
    summary:
        'Updated guidelines for office pantry use. Respectful and clean usage is expected from all.',
    body: '''Hi Team,

Following feedback from multiple employees, Admin has updated the pantry usage guidelines:

1. Please clean up after yourself. Dishes should be washed or placed in the sink immediately.
2. Refrigerator items must be labelled with your name and date. Items older than 3 days will be discarded every Friday.
3. Hot plates and microwave must be wiped after use.
4. Do not store raw vegetables or strong-smelling foods overnight.
5. The pantry closes at 8 PM. Please plan accordingly.

We appreciate everyone's cooperation in keeping the workspace clean and comfortable.

Admin Team''',
    category: _NoticeCategory.admin,
    priority: _NoticePriority.low,
    postedOn: '15 Apr 2026',
    postedBy: 'Admin Team',
    isRead: true,
  ),
  _Notice(
    id: 'NOT-2026-008',
    title: 'ISF Annual Sports Day — 25 May 2026',
    summary:
        'Register for the annual sports day! Events include cricket, badminton, and carrom.',
    body: '''Dear Team,

We are excited to announce the ISF Annual Sports Day 2026! 🏏🏸

📅 Date: 25 May 2026 (Sunday)
📍 Venue: Mahatma Gandhi Grounds, Dadar
🕙 Reporting Time: 8:00 AM

Events:
• Cricket (5-over format, teams of 8)
• Badminton (singles & doubles)
• Carrom (singles)
• Tug of War
• 100m Sprint

How to participate:
Register via the ISmart portal or email sports@isf.com by 15 May 2026. Free breakfast and lunch will be provided for all participants.

Let the games begin! 🏆

Team ISF''',
    category: _NoticeCategory.general,
    priority: _NoticePriority.low,
    postedOn: '10 Apr 2026',
    expiresOn: '25 May 2026',
    postedBy: 'ISF Culture Committee',
    isRead: true,
  ),
];

const _filterLabels = [
  'All',
  'HR',
  'Policy',
  'IT',
  'Admin',
  'Finance',
  'General'
];

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class NoticesScreen extends StatefulWidget {
  const NoticesScreen({super.key});

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  final List<_Notice> _notices = List.from(_allNotices);
  String _activeFilter = 'All';
  String _searchQuery = '';
  bool _showSearch = false;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Filtered list ─────────────────────────────
  List<_Notice> get _filtered {
    List<_Notice> list = _notices;

    // Category filter
    if (_activeFilter != 'All') {
      list = list.where((n) {
        switch (_activeFilter) {
          case 'HR':
            return n.category == _NoticeCategory.hr;
          case 'Policy':
            return n.category == _NoticeCategory.policy;
          case 'IT':
            return n.category == _NoticeCategory.it;
          case 'Admin':
            return n.category == _NoticeCategory.admin;
          case 'Finance':
            return n.category == _NoticeCategory.finance;
          case 'General':
            return n.category == _NoticeCategory.general;
          default:
            return true;
        }
      }).toList();
    }

    // Search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((n) =>
              n.title.toLowerCase().contains(q) ||
              n.summary.toLowerCase().contains(q) ||
              n.postedBy.toLowerCase().contains(q))
          .toList();
    }

    return list;
  }

  List<_Notice> get _pinned => _filtered.where((n) => n.isPinned).toList();
  List<_Notice> get _regular => _filtered.where((n) => !n.isPinned).toList();

  int get _unreadCount => _notices.where((n) => !n.isRead).length;

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

  void _openNotice(_Notice notice) {
    setState(() => notice.isRead = true);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _NoticeDetailSheet(
        notice: notice,
        onAcknowledge: () {
          setState(() => notice.hasAcknowledged = true);
          _snack('Notice acknowledged ✅', _C.successDark);
        },
        onDownload: () =>
            _snack('${notice.attachmentName} downloaded ✅', _C.successDark),
        onBookmark: () {
          setState(() => notice.isBookmarked = !notice.isBookmarked);
          _snack(
            notice.isBookmarked ? 'Notice bookmarked' : 'Bookmark removed',
            _C.textSec,
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final pinned = _pinned;
    final regular = _regular;

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _buildAppBar(),
      body: Column(children: [
        // Search bar (animated)
        if (_showSearch) _buildSearchBar(),
        // Filters
        _buildFilters(),
        // Content
        Expanded(
          child: (_filtered.isEmpty)
              ? _EmptyState(query: _searchQuery, filter: _activeFilter)
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 48),
                  children: [
                    // Pinned section
                    if (pinned.isNotEmpty) ...[
                      _SectionLabel('📌 Pinned', pinned.length),
                      const SizedBox(height: 8),
                      ...pinned.map((n) => _NoticeCard(
                            notice: n,
                            onTap: () => _openNotice(n),
                            onBookmark: () => setState(
                                () => n.isBookmarked = !n.isBookmarked),
                          )),
                      const SizedBox(height: 16),
                    ],
                    // Regular
                    if (regular.isNotEmpty) ...[
                      if (pinned.isNotEmpty)
                        _SectionLabel('All Notices', regular.length),
                      if (pinned.isNotEmpty) const SizedBox(height: 8),
                      ...regular.map((n) => _NoticeCard(
                            notice: n,
                            onTap: () => _openNotice(n),
                            onBookmark: () => setState(
                                () => n.isBookmarked = !n.isBookmarked),
                          )),
                    ],
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
        title: Row(children: [
          const Text('Notices',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: _C.textPrimary)),
          if (_unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                  color: _C.error, borderRadius: BorderRadius.circular(20)),
              child: Text('$_unreadCount new',
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ),
          ],
        ]),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _showSearch
                  ? const Icon(Icons.close_rounded,
                      key: ValueKey('close'), size: 22)
                  : const Icon(Icons.search_rounded,
                      key: ValueKey('search'), size: 22),
            ),
            color: _C.textSec,
            onPressed: () => setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) {
                _searchCtrl.clear();
                _searchQuery = '';
              }
            }),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_outline_rounded, size: 21),
            color: _C.textSec,
            onPressed: () {
              final bookmarked = _notices.where((n) => n.isBookmarked).length;
              _snack(
                  '$bookmarked notice${bookmarked != 1 ? "s" : ""} bookmarked',
                  _C.textSec);
            },
            tooltip: 'Bookmarks',
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _C.border),
        ),
      );

  // ─────────────────────────────────────────────
  // SEARCH BAR
  // ─────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      color: _C.card,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: TextField(
        controller: _searchCtrl,
        autofocus: true,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(fontSize: 14, color: _C.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search notices…',
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
          fillColor: _C.surface,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.primary, width: 1.5)),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // FILTER CHIPS
  // ─────────────────────────────────────────────
  Widget _buildFilters() {
    return Container(
      color: _C.card,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filterLabels.map((label) {
            final active = label == _activeFilter;
            int count;
            switch (label) {
              case 'All':
                count = _notices.length;
                break;
              case 'HR':
                count = _notices
                    .where((n) => n.category == _NoticeCategory.hr)
                    .length;
                break;
              case 'Policy':
                count = _notices
                    .where((n) => n.category == _NoticeCategory.policy)
                    .length;
                break;
              case 'IT':
                count = _notices
                    .where((n) => n.category == _NoticeCategory.it)
                    .length;
                break;
              case 'Admin':
                count = _notices
                    .where((n) => n.category == _NoticeCategory.admin)
                    .length;
                break;
              case 'Finance':
                count = _notices
                    .where((n) => n.category == _NoticeCategory.finance)
                    .length;
                break;
              case 'General':
                count = _notices
                    .where((n) => n.category == _NoticeCategory.general)
                    .length;
                break;
              default:
                count = 0;
            }

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _activeFilter = label),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: active ? _C.primary : _C.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: active ? _C.primary : _C.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(label,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
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
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: active ? Colors.white : _C.textSec)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION LABEL
// ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final int count;
  const _SectionLabel(this.label, this.count);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(label,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _C.textPrimary)),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
            color: _C.surface, borderRadius: BorderRadius.circular(10)),
        child: Text('$count',
            style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700, color: _C.textSec)),
      ),
      const SizedBox(width: 10),
      Expanded(child: Container(height: 1, color: _C.border)),
    ]);
  }
}

// ─────────────────────────────────────────────
// NOTICE CARD
// ─────────────────────────────────────────────
class _NoticeCard extends StatelessWidget {
  final _Notice notice;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _NoticeCard({
    required this.notice,
    required this.onTap,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final cat = _catMeta(notice.category);
    final priStyle = _priorityStyle(notice.priority);
    final isUnread = !notice.isRead;
    final isUrgent = notice.priority == _NoticePriority.urgent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: isUnread ? const Color(0xFFF0F5FF) : _C.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUrgent
                  ? _C.error.withValues(alpha: .35)
                  : isUnread
                      ? _C.primary.withValues(alpha: .25)
                      : _C.border,
              width: isUrgent || isUnread ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: [
            // Urgent top bar
            if (isUrgent)
              Container(
                height: 4,
                decoration: const BoxDecoration(
                  color: _C.error,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row
                  Row(children: [
                    // Category chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: cat.bg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: cat.color.withValues(alpha: .2))),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(cat.icon, size: 10, color: cat.color),
                        const SizedBox(width: 4),
                        Text(cat.label,
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: cat.color)),
                      ]),
                    ),
                    const SizedBox(width: 6),

                    // Priority badge
                    if (notice.priority != _NoticePriority.low &&
                        notice.priority != _NoticePriority.normal)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                            color: priStyle.bg,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          notice.priority == _NoticePriority.urgent
                              ? '🚨 URGENT'
                              : 'HIGH',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: priStyle.color),
                        ),
                      ),

                    const Spacer(),

                    // Ack badge
                    if (notice.requiresAck)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: notice.hasAcknowledged
                              ? _C.successLight
                              : _C.warningLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(
                            notice.hasAcknowledged
                                ? Icons.check_circle_outline_rounded
                                : Icons.priority_high_rounded,
                            size: 9,
                            color: notice.hasAcknowledged
                                ? _C.successDark
                                : _C.warningDark,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            notice.hasAcknowledged ? 'Signed' : 'Action Req.',
                            style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: notice.hasAcknowledged
                                    ? _C.successDark
                                    : _C.warningDark),
                          ),
                        ]),
                      ),

                    const SizedBox(width: 6),

                    // Bookmark
                    GestureDetector(
                      onTap: onBookmark,
                      child: Icon(
                        notice.isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline_rounded,
                        size: 18,
                        color: notice.isBookmarked ? _C.primary : _C.textTert,
                      ),
                    ),

                    // Unread dot
                    if (isUnread) ...[
                      const SizedBox(width: 6),
                      Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: _C.primary, shape: BoxShape.circle)),
                    ],
                  ]),
                  const SizedBox(height: 10),

                  // Title
                  Text(notice.title,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isUnread ? FontWeight.w800 : FontWeight.w600,
                          color: _C.textPrimary,
                          height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),

                  // Summary
                  Text(notice.summary,
                      style: const TextStyle(
                          fontSize: 12, color: _C.textSec, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 10),

                  // Footer row
                  Row(children: [
                    const Icon(Icons.person_outline_rounded,
                        size: 11, color: _C.textTert),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(notice.postedBy,
                          style:
                              const TextStyle(fontSize: 10, color: _C.textTert),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.calendar_today_outlined,
                        size: 11, color: _C.textTert),
                    const SizedBox(width: 4),
                    Text(notice.postedOn,
                        style:
                            const TextStyle(fontSize: 10, color: _C.textTert)),

                    // Attachment indicator
                    if (notice.attachmentName != null) ...[
                      const SizedBox(width: 10),
                      const Icon(Icons.attach_file_rounded,
                          size: 12, color: _C.textSec),
                    ],

                    // Expiry countdown
                    if (notice.expiresOn != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: _C.errorLight,
                            borderRadius: BorderRadius.circular(8)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.timer_outlined,
                              size: 9, color: _C.error),
                          const SizedBox(width: 3),
                          Text('Exp: ${notice.expiresOn}',
                              style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: _C.error)),
                        ]),
                      ),
                    ],
                  ]),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// NOTICE DETAIL SHEET
// ─────────────────────────────────────────────
class _NoticeDetailSheet extends StatelessWidget {
  final _Notice notice;
  final VoidCallback onAcknowledge;
  final VoidCallback onDownload;
  final VoidCallback onBookmark;

  const _NoticeDetailSheet({
    required this.notice,
    required this.onAcknowledge,
    required this.onDownload,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final cat = _catMeta(notice.category);
    final priStyle = _priorityStyle(notice.priority);

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, ctrl) => Column(children: [
        // Non-scrollable header
        Container(
          decoration: const BoxDecoration(
            color: _C.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(children: [
            // Handle
            const SizedBox(height: 12),
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: _C.border,
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 14),

            // Category + priority + close
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: cat.bg, borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(cat.icon, size: 12, color: cat.color),
                    const SizedBox(width: 5),
                    Text(cat.label,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: cat.color)),
                  ]),
                ),
                if (notice.priority == _NoticePriority.urgent ||
                    notice.priority == _NoticePriority.high) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                        color: priStyle.bg,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      notice.priority == _NoticePriority.urgent
                          ? '🚨 URGENT'
                          : 'HIGH PRIORITY',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: priStyle.color),
                    ),
                  ),
                ],
                const Spacer(),
                // Bookmark
                IconButton(
                  icon: Icon(
                    notice.isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    size: 22,
                    color: notice.isBookmarked ? _C.primary : _C.textSec,
                  ),
                  onPressed: () {
                    onBookmark();
                    Navigator.pop(context);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ]),
            ),
            const SizedBox(height: 12),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(notice.title,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _C.textPrimary,
                      height: 1.3)),
            ),
            const SizedBox(height: 8),

            // Meta row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                const Icon(Icons.person_outline_rounded,
                    size: 13, color: _C.textSec),
                const SizedBox(width: 5),
                Text(notice.postedBy,
                    style: const TextStyle(fontSize: 11, color: _C.textSec)),
                const SizedBox(width: 10),
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: _C.textSec),
                const SizedBox(width: 5),
                Text(notice.postedOn,
                    style: const TextStyle(fontSize: 11, color: _C.textSec)),
                if (notice.expiresOn != null) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                        color: _C.errorLight,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text('Expires: ${notice.expiresOn}',
                        style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: _C.error)),
                  ),
                ],
              ]),
            ),
            const SizedBox(height: 14),
            Container(height: 1, color: _C.border),
          ]),
        ),

        // Scrollable body
        Expanded(
          child: ListView(
            controller: ctrl,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              // Body text
              Text(notice.body,
                  style: const TextStyle(
                      fontSize: 14, color: _C.textPrimary, height: 1.8)),

              // Attachment
              if (notice.attachmentName != null) ...[
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    onDownload();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _C.errorLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _C.error.withValues(alpha: .2)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.picture_as_pdf_outlined,
                          size: 24, color: _C.error),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notice.attachmentName!,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _C.textPrimary)),
                          const Text('Tap to download',
                              style:
                                  TextStyle(fontSize: 11, color: _C.textSec)),
                        ],
                      )),
                      const Icon(Icons.download_outlined,
                          size: 20, color: _C.error),
                    ]),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Acknowledge button
              if (notice.requiresAck) ...[
                notice.hasAcknowledged
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                            color: _C.successLight,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: _C.success.withValues(alpha: .3))),
                        child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.verified_outlined,
                                  size: 18, color: _C.successDark),
                              SizedBox(width: 8),
                              Text('Acknowledged ✓',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _C.successDark)),
                            ]),
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            onAcknowledge();
                          },
                          icon: const Icon(Icons.check_circle_outline_rounded,
                              size: 18),
                          label: const Text(
                              'I have read and understood this notice',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _C.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                const SizedBox(height: 10),
              ],

              // Close
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
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String query;
  final String filter;
  const _EmptyState({required this.query, required this.filter});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                  color: _C.primaryLight,
                  borderRadius: BorderRadius.circular(24)),
              child: const Icon(Icons.campaign_outlined,
                  size: 42, color: _C.primary),
            ),
            const SizedBox(height: 20),
            Text(
              query.isNotEmpty
                  ? 'No results for "$query"'
                  : 'No $filter notices',
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Notices and announcements from ISF will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _C.textSec, height: 1.5),
            ),
          ]),
        ),
      );
}
