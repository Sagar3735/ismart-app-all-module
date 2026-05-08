// ============================================================
// ISF HR Portal — Tickets Screen
// File: lib/screens/self_service/tickets_screen.dart
//
// Features:
//   - Summary stats banner (Open / In-Progress / Resolved)
//   - Raise New Ticket form:
//       • Category chips (IT / HR / Admin / Finance / Facilities)
//       • Subcategory dropdown (dynamic per category)
//       • Priority selector (Low / Medium / High / Critical)
//       • Subject + description fields
//       • Optional file attachment
//       • Submit with animated confirmation
//   - Ticket list with status filters
//   - Expandable ticket cards with full thread
//   - Reply / add comment to open tickets
//   - Rating dialog on resolved tickets
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
enum _TicketCategory { it, hr, admin, finance, facilities }

enum _Priority { low, medium, high, critical }

enum _TicketStatus { open, inProgress, onHold, resolved, closed }

class _Comment {
  final String author;
  final String initials;
  final Color avatarColor;
  final bool isAgent;
  final String text;
  final String time;
  const _Comment({
    required this.author,
    required this.initials,
    required this.avatarColor,
    required this.isAgent,
    required this.text,
    required this.time,
  });
}

class _Ticket {
  final String id;
  final String subject;
  final String description;
  final _TicketCategory category;
  final String subcategory;
  final _Priority priority;
  _TicketStatus status;
  final String raisedOn;
  final String? assignedTo;
  final List<_Comment> comments;
  int? userRating;
  bool expanded = false;

  _Ticket({
    required this.id,
    required this.subject,
    required this.description,
    required this.category,
    required this.subcategory,
    required this.priority,
    required this.status,
    required this.raisedOn,
    this.assignedTo,
    required this.comments,
    this.userRating,
  });
}

// ─────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────
final _mockTickets = [
  _Ticket(
    id: 'TKT-2026-0041',
    subject: 'VPN not connecting from home',
    description:
        'Unable to connect to office VPN from home network since yesterday evening. Getting "authentication failed" error.',
    category: _TicketCategory.it,
    subcategory: 'Network / VPN',
    priority: _Priority.high,
    status: _TicketStatus.inProgress,
    raisedOn: '28 Apr 2026',
    assignedTo: 'Rahul (IT Support)',
    comments: [
      const _Comment(
          author: 'Amit Patil',
          initials: 'AP',
          avatarColor: Color(0xFF2563EB),
          isAgent: false,
          text:
              'VPN shows authentication failed even with correct credentials.',
          time: '28 Apr, 09:15 AM'),
      const _Comment(
          author: 'Rahul IT',
          initials: 'RI',
          avatarColor: Color(0xFF0D9488),
          isAgent: true,
          text:
              'Hi Amit, I\'ve reset your VPN token. Please try again and let me know.',
          time: '28 Apr, 11:30 AM'),
    ],
  ),
  _Ticket(
    id: 'TKT-2026-0038',
    subject: 'Laptop running very slow',
    description:
        'Dell Latitude laptop is extremely slow since the latest Windows update. Takes 10+ mins to boot.',
    category: _TicketCategory.it,
    subcategory: 'Hardware / Laptop',
    priority: _Priority.medium,
    status: _TicketStatus.resolved,
    raisedOn: '22 Apr 2026',
    assignedTo: 'Priya IT',
    userRating: 5,
    comments: [
      const _Comment(
          author: 'Priya IT',
          initials: 'PI',
          avatarColor: Color(0xFF7C3AED),
          isAgent: true,
          text:
              'Cleared startup programs and upgraded RAM. Boot time is now under 30 seconds.',
          time: '23 Apr, 02:00 PM'),
      const _Comment(
          author: 'Amit Patil',
          initials: 'AP',
          avatarColor: Color(0xFF2563EB),
          isAgent: false,
          text: 'Working perfectly now! Thank you.',
          time: '23 Apr, 03:45 PM'),
    ],
  ),
  _Ticket(
    id: 'TKT-2026-0031',
    subject: 'Request for additional monitor',
    description:
        'Need a second monitor for improved productivity while working on multiple projects simultaneously.',
    category: _TicketCategory.admin,
    subcategory: 'Equipment Request',
    priority: _Priority.low,
    status: _TicketStatus.open,
    raisedOn: '15 Apr 2026',
    comments: [],
  ),
  _Ticket(
    id: 'TKT-2026-0025',
    subject: 'Office AC not working in Bay 3',
    description:
        'The air conditioning unit in Bay 3 has stopped working. Very uncomfortable working environment.',
    category: _TicketCategory.facilities,
    subcategory: 'HVAC / AC',
    priority: _Priority.high,
    status: _TicketStatus.closed,
    raisedOn: '10 Apr 2026',
    assignedTo: 'Facilities Team',
    comments: [
      const _Comment(
          author: 'Facilities',
          initials: 'FM',
          avatarColor: Color(0xFFEA580C),
          isAgent: true,
          text: 'AC unit repaired. Please confirm if it is working.',
          time: '11 Apr, 04:00 PM'),
    ],
  ),
];

// Category metadata
({
  String label,
  IconData icon,
  Color color,
  Color bg,
  List<String> subcategories
}) _categoryMeta(_TicketCategory c) {
  switch (c) {
    case _TicketCategory.it:
      return (
        label: 'IT',
        icon: Icons.computer_outlined,
        color: _C.primary,
        bg: _C.primaryLight,
        subcategories: [
          'Network / VPN',
          'Hardware / Laptop',
          'Software / Apps',
          'Email / Outlook',
          'Access / Permissions',
          'Other IT'
        ]
      );
    case _TicketCategory.hr:
      return (
        label: 'HR',
        icon: Icons.people_outline_rounded,
        color: _C.purple,
        bg: _C.purpleLight,
        subcategories: [
          'Leave Issue',
          'Payroll',
          'Policy Query',
          'Onboarding',
          'Exit Process',
          'Other HR'
        ]
      );
    case _TicketCategory.admin:
      return (
        label: 'Admin',
        icon: Icons.admin_panel_settings_outlined,
        color: _C.teal,
        bg: _C.tealLight,
        subcategories: [
          'Equipment Request',
          'ID Card',
          'Visitor Pass',
          'Stationery',
          'Other Admin'
        ]
      );
    case _TicketCategory.finance:
      return (
        label: 'Finance',
        icon: Icons.account_balance_outlined,
        color: _C.successDark,
        bg: _C.successLight,
        subcategories: [
          'Reimbursement',
          'Invoice / PO',
          'Advance Query',
          'Tax / TDS',
          'Other Finance'
        ]
      );
    case _TicketCategory.facilities:
      return (
        label: 'Facilities',
        icon: Icons.business_outlined,
        color: _C.orange,
        bg: _C.orangeLight,
        subcategories: [
          'HVAC / AC',
          'Plumbing',
          'Electrical',
          'Housekeeping',
          'Cafeteria',
          'Other Facilities'
        ]
      );
  }
}

({String label, Color color, Color bg, IconData icon}) _priorityMeta(
    _Priority p) {
  switch (p) {
    case _Priority.low:
      return (
        label: 'Low',
        color: _C.textSec,
        bg: _C.surface,
        icon: Icons.arrow_downward_rounded
      );
    case _Priority.medium:
      return (
        label: 'Medium',
        color: _C.warningDark,
        bg: _C.warningLight,
        icon: Icons.remove_rounded
      );
    case _Priority.high:
      return (
        label: 'High',
        color: _C.error,
        bg: _C.errorLight,
        icon: Icons.arrow_upward_rounded
      );
    case _Priority.critical:
      return (
        label: 'Critical',
        color: _C.errorDark,
        bg: _C.errorLight,
        icon: Icons.priority_high_rounded
      );
  }
}

({String label, Color color, Color bg, IconData icon}) _statusMeta(
    _TicketStatus s) {
  switch (s) {
    case _TicketStatus.open:
      return (
        label: 'Open',
        color: _C.primary,
        bg: _C.primaryLight,
        icon: Icons.fiber_new_rounded
      );
    case _TicketStatus.inProgress:
      return (
        label: 'In Progress',
        color: _C.warningDark,
        bg: _C.warningLight,
        icon: Icons.loop_rounded
      );
    case _TicketStatus.onHold:
      return (
        label: 'On Hold',
        color: _C.textSec,
        bg: _C.surface,
        icon: Icons.pause_circle_outline_rounded
      );
    case _TicketStatus.resolved:
      return (
        label: 'Resolved',
        color: _C.successDark,
        bg: _C.successLight,
        icon: Icons.check_circle_outline_rounded
      );
    case _TicketStatus.closed:
      return (
        label: 'Closed',
        color: _C.textSec,
        bg: _C.surface,
        icon: Icons.lock_outline_rounded
      );
  }
}

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  _TicketStatus? _filterStatus;
  final List<_Ticket> _tickets = List.from(_mockTickets);

  // ── Form state ────────────────────────────────
  _TicketCategory? _selCategory;
  String? _selSubcategory;
  _Priority _priority = _Priority.medium;
  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _hasAttachment = false;
  bool _submitting = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ── Computed ──────────────────────────────────
  List<_Ticket> get _filtered {
    if (_filterStatus == null) return _tickets;
    return _tickets.where((t) => t.status == _filterStatus).toList();
  }

  int _countByStatus(_TicketStatus s) =>
      _tickets.where((t) => t.status == s).length;

  // ── Submit ticket ─────────────────────────────
  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selCategory == null) {
      _snack('Select a category', _C.error);
      return;
    }
    if (_selSubcategory == null) {
      _snack('Select a subcategory', _C.error);
      return;
    }

    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final newTicket = _Ticket(
      id: 'TKT-2026-00${50 + _tickets.length}',
      subject: _subjectCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _selCategory!,
      subcategory: _selSubcategory!,
      priority: _priority,
      status: _TicketStatus.open,
      raisedOn: 'Today',
      comments: [],
    );

    setState(() {
      _submitting = false;
      _tickets.insert(0, newTicket);
      _selCategory = null;
      _selSubcategory = null;
      _priority = _Priority.medium;
      _subjectCtrl.clear();
      _descCtrl.clear();
      _hasAttachment = false;
      _tabCtrl.animateTo(1);
    });

    _snack('Ticket ${newTicket.id} raised ✅', _C.successDark);
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

  void _showReplySheet(_Ticket ticket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ReplySheet(
        ticket: ticket,
        onSubmit: (text) {
          setState(() {
            ticket.comments.add(_Comment(
              author: 'Amit Patil',
              initials: 'AP',
              avatarColor: _C.primary,
              isAgent: false,
              text: text,
              time: 'Just now',
            ));
          });
          Navigator.pop(context);
          _snack('Reply added', _C.successDark);
        },
      ),
    );
  }

  void _showRatingDialog(_Ticket ticket) {
    int tempRating = ticket.userRating ?? 0;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Rate Support',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: _C.textPrimary)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('How satisfied are you with the resolution?',
                style: TextStyle(fontSize: 13, color: _C.textSec),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () => setSt(() => tempRating = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        i < tempRating
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 36,
                        color: _C.warning,
                      ),
                    ),
                  );
                })),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child:
                    const Text('Later', style: TextStyle(color: _C.textSec))),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => ticket.userRating = tempRating);
                _snack('Thank you for your feedback! ⭐ $tempRating/5',
                    _C.successDark);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: _C.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              child: const Text('Submit Rating'),
            ),
          ],
        ),
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
      body: Column(children: [
        _buildTabBar(),
        Expanded(
            child: TabBarView(
          controller: _tabCtrl,
          children: [_buildRaiseTab(), _buildMyTicketsTab()],
        )),
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
        title: const Text('Helpdesk Tickets',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: _C.primaryLight,
                borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                      color: _C.primary, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text(
                  '${_countByStatus(_TicketStatus.open) + _countByStatus(_TicketStatus.inProgress)} Active',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _C.primary)),
            ]),
          ),
        ],
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: _C.border)),
      );

  // ─────────────────────────────────────────────
  // TAB BAR
  // ─────────────────────────────────────────────
  Widget _buildTabBar() => Container(
        color: _C.card,
        child: TabBar(
          controller: _tabCtrl,
          tabs: const [Tab(text: 'Raise Ticket'), Tab(text: 'My Tickets')],
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
  // TAB 1: RAISE TICKET
  // ─────────────────────────────────────────────
  Widget _buildRaiseTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
      children: [
        _buildStatsRow(),
        const SizedBox(height: 16),
        _buildForm(),
      ],
    );
  }

  // ─── Stats row ────────────────────────────────
  Widget _buildStatsRow() {
    final stats = [
      (_countByStatus(_TicketStatus.open), 'Open', _C.primary, _C.primaryLight),
      (
        _countByStatus(_TicketStatus.inProgress),
        'In Progress',
        _C.warningDark,
        _C.warningLight
      ),
      (
        _countByStatus(_TicketStatus.resolved) +
            _countByStatus(_TicketStatus.closed),
        'Resolved',
        _C.successDark,
        _C.successLight
      ),
    ];

    return Row(
        children: stats.asMap().entries.map((e) {
      final i = e.key;
      final (count, label, color, bg) = e.value;
      return Expanded(
          child: Padding(
        padding: EdgeInsets.only(right: i < stats.length - 1 ? 10 : 0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: .2)),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('$count',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: color,
                      height: 1)),
              Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: .15),
                      borderRadius: BorderRadius.circular(7)),
                  child: Icon(Icons.confirmation_number_outlined,
                      size: 15, color: color)),
            ]),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color.withValues(alpha: .8))),
          ]),
        ),
      ));
    }).toList());
  }

  // ─── Form ─────────────────────────────────────
  Widget _buildForm() {
    final subcats = _selCategory != null
        ? _categoryMeta(_selCategory!).subcategories
        : <String>[];

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
                child: const Icon(Icons.add_circle_outline_rounded,
                    size: 16, color: _C.primary)),
            const SizedBox(width: 10),
            const Text('New Ticket',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary)),
          ]),
        ),
        Container(height: 1, color: _C.border),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // ── Category chips ─────────────────
              const _FieldLabel('Category *'),
              const SizedBox(height: 8),
              Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _TicketCategory.values.map((cat) {
                    final m = _categoryMeta(cat);
                    final active = _selCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selCategory = cat;
                        _selSubcategory = null;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 9),
                        decoration: BoxDecoration(
                          color: active ? m.color : _C.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: active ? m.color : _C.border, width: 1.5),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(m.icon,
                              size: 13,
                              color: active ? Colors.white : _C.textSec),
                          const SizedBox(width: 6),
                          Text(m.label,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: active ? Colors.white : _C.textSec)),
                        ]),
                      ),
                    );
                  }).toList()),
              const SizedBox(height: 14),

              // ── Subcategory dropdown ────────────
              if (_selCategory != null) ...[
                const _FieldLabel('Subcategory *'),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: _C.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _C.border, width: 1.5),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selSubcategory,
                      hint: const Text('Select subcategory',
                          style: TextStyle(fontSize: 13, color: _C.textTert)),
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 20, color: _C.textSec),
                      style: const TextStyle(
                          fontSize: 13,
                          color: _C.textPrimary,
                          fontWeight: FontWeight.w500),
                      onChanged: (v) => setState(() => _selSubcategory = v),
                      items: subcats
                          .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // ── Priority ───────────────────────
              const _FieldLabel('Priority *'),
              const SizedBox(height: 8),
              Row(
                  children: _Priority.values.map((p) {
                final m = _priorityMeta(p);
                final active = _priority == p;
                return Expanded(
                    child: Padding(
                  padding:
                      EdgeInsets.only(right: p != _Priority.critical ? 8 : 0),
                  child: GestureDetector(
                    onTap: () => setState(() => _priority = p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: 44,
                      decoration: BoxDecoration(
                        color: active ? m.color : _C.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: active ? m.color : _C.border, width: 1.5),
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(m.icon,
                                size: 13,
                                color: active ? Colors.white : m.color),
                            const SizedBox(height: 2),
                            Text(m.label,
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: active ? Colors.white : m.color)),
                          ]),
                    ),
                  ),
                ));
              }).toList()),
              const SizedBox(height: 14),

              // ── Subject ────────────────────────
              const _FieldLabel('Subject *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _subjectCtrl,
                maxLength: 100,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Subject is required'
                    : null,
                style: const TextStyle(fontSize: 14, color: _C.textPrimary),
                decoration: _inputDeco('Brief summary of the issue'),
              ),
              const SizedBox(height: 12),

              // ── Description ─────────────────────
              const _FieldLabel('Description *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                maxLength: 500,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Description is required';
                  }
                  if (v.trim().length < 15) return 'Minimum 15 characters';
                  return null;
                },
                style: const TextStyle(fontSize: 14, color: _C.textPrimary),
                decoration: _inputDeco(
                    'Describe the issue in detail. Include steps to reproduce if applicable.'),
              ),
              const SizedBox(height: 12),

              // ── Attachment ─────────────────────
              GestureDetector(
                onTap: () => setState(() => _hasAttachment = !_hasAttachment),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _hasAttachment ? _C.successLight : _C.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _hasAttachment
                            ? _C.success.withValues(alpha: .4)
                            : _C.border,
                        width: _hasAttachment ? 1.5 : 1),
                  ),
                  child: Row(children: [
                    Icon(
                        _hasAttachment
                            ? Icons.check_circle_outline_rounded
                            : Icons.attach_file_rounded,
                        size: 20,
                        color: _hasAttachment ? _C.successDark : _C.textSec),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(
                      _hasAttachment
                          ? 'screenshot_error.png attached'
                          : 'Attach screenshot or file (optional)',
                      style: TextStyle(
                          fontSize: 13,
                          color: _hasAttachment ? _C.successDark : _C.textSec),
                    )),
                    if (_hasAttachment)
                      GestureDetector(
                        onTap: () => setState(() => _hasAttachment = false),
                        child: const Icon(Icons.close_rounded,
                            size: 16, color: _C.textSec),
                      ),
                  ]),
                ),
              ),
              const SizedBox(height: 20),

              // ── Submit ─────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submitTicket,
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
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Icon(Icons.send_outlined, size: 17),
                              SizedBox(width: 8),
                              Text('Submit Ticket',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                            ]),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────
  // TAB 2: MY TICKETS
  // ─────────────────────────────────────────────
  Widget _buildMyTicketsTab() {
    final filtered = _filtered;

    return Column(children: [
      // Filter row
      Container(
        color: _C.card,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _FChip('All', _filterStatus == null, _tickets.length,
                () => setState(() => _filterStatus = null)),
            ...[
              _TicketStatus.open,
              _TicketStatus.inProgress,
              _TicketStatus.resolved,
              _TicketStatus.closed
            ].map((s) {
              final m = _statusMeta(s);
              final cnt = _tickets.where((t) => t.status == s).length;
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

      Expanded(
        child: filtered.isEmpty
            ? _EmptyTickets()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 48),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _TicketCard(
                  ticket: filtered[i],
                  onToggle: () => setState(
                      () => filtered[i].expanded = !filtered[i].expanded),
                  onReply: (filtered[i].status == _TicketStatus.open ||
                          filtered[i].status == _TicketStatus.inProgress)
                      ? () => _showReplySheet(filtered[i])
                      : null,
                  onRate: filtered[i].status == _TicketStatus.resolved &&
                          filtered[i].userRating == null
                      ? () => _showRatingDialog(filtered[i])
                      : null,
                  onStateChange: () => setState(() {}),
                ),
              ),
      ),
    ]);
  }

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
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _C.error, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _C.error, width: 1.5)),
        errorStyle: const TextStyle(fontSize: 11, color: _C.error),
      );
}

// ─────────────────────────────────────────────
// TICKET CARD
// ─────────────────────────────────────────────
class _TicketCard extends StatelessWidget {
  final _Ticket ticket;
  final VoidCallback onToggle;
  final VoidCallback? onReply;
  final VoidCallback? onRate;
  final VoidCallback onStateChange;

  const _TicketCard({
    required this.ticket,
    required this.onToggle,
    this.onReply,
    this.onRate,
    required this.onStateChange,
  });

  @override
  Widget build(BuildContext context) {
    final catMeta = _categoryMeta(ticket.category);
    final priMeta = _priorityMeta(ticket.priority);
    final statusMeta = _statusMeta(ticket.status);

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color:
                  ticket.expanded ? catMeta.color.withValues(alpha: .4) : _C.border,
              width: ticket.expanded ? 1.5 : 1),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: .04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // ID row
              Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                      color: catMeta.bg,
                      borderRadius: BorderRadius.circular(6)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(catMeta.icon, size: 10, color: catMeta.color),
                    const SizedBox(width: 3),
                    Text(catMeta.label,
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: catMeta.color)),
                  ]),
                ),
                const SizedBox(width: 8),
                Text(ticket.id,
                    style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: _C.textTert,
                        letterSpacing: 0.3)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: statusMeta.bg,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: statusMeta.color.withValues(alpha: .3))),
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
                  turns: ticket.expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 18, color: _C.textTert),
                ),
              ]),
              const SizedBox(height: 8),

              // Subject
              Text(ticket.subject,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _C.textPrimary),
                  maxLines: ticket.expanded ? null : 1,
                  overflow: ticket.expanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis),
              const SizedBox(height: 6),

              // Meta row
              Row(children: [
                // Priority chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                      color: priMeta.bg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: priMeta.color.withValues(alpha: .3))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(priMeta.icon, size: 10, color: priMeta.color),
                    const SizedBox(width: 3),
                    Text(priMeta.label,
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: priMeta.color)),
                  ]),
                ),
                const SizedBox(width: 8),
                Text(ticket.subcategory,
                    style: const TextStyle(fontSize: 10, color: _C.textSec)),
                const Spacer(),
                const Icon(Icons.access_time_rounded,
                    size: 11, color: _C.textTert),
                const SizedBox(width: 3),
                Text(ticket.raisedOn,
                    style: const TextStyle(fontSize: 10, color: _C.textTert)),
              ]),

              // Assignee
              if (ticket.assignedTo != null) ...[
                const SizedBox(height: 5),
                Row(children: [
                  const Icon(Icons.headset_mic_outlined,
                      size: 11, color: _C.textTert),
                  const SizedBox(width: 4),
                  Text('Assigned to ${ticket.assignedTo}',
                      style: const TextStyle(fontSize: 10, color: _C.textTert)),
                ]),
              ],

              // Rating stars (resolved)
              if (ticket.userRating != null) ...[
                const SizedBox(height: 6),
                Row(
                    children: List.generate(
                        5,
                        (i) => Icon(
                              i < ticket.userRating!
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              size: 14,
                              color: _C.warning,
                            ))),
              ],
            ]),
          ),

          // ── Expanded detail ──────────────────
          if (ticket.expanded) ...[
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
                    const Text('Description',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _C.textSec)),
                    const SizedBox(height: 5),
                    Text(ticket.description,
                        style: const TextStyle(
                            fontSize: 13, color: _C.textPrimary, height: 1.5)),

                    // Comments / thread
                    if (ticket.comments.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      const Text('Activity Thread',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _C.textSec)),
                      const SizedBox(height: 8),
                      ...ticket.comments.map((c) => _CommentBubble(comment: c)),
                    ],

                    const SizedBox(height: 12),

                    // Action buttons
                    Row(children: [
                      if (onReply != null)
                        Expanded(
                            child: ElevatedButton.icon(
                          onPressed: onReply,
                          icon: const Icon(Icons.reply_outlined, size: 16),
                          label: const Text('Reply',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: catMeta.color,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        )),
                      if (onReply != null && onRate != null)
                        const SizedBox(width: 10),
                      if (onRate != null)
                        Expanded(
                            child: OutlinedButton.icon(
                          onPressed: onRate,
                          icon:
                              const Icon(Icons.star_outline_rounded, size: 16),
                          label: const Text('Rate',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _C.warning,
                            side:
                                const BorderSide(color: _C.warning, width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        )),
                      if (onReply == null && onRate == null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                              color: _C.surface,
                              borderRadius: BorderRadius.circular(10)),
                          child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock_outline_rounded,
                                    size: 14, color: _C.textSec),
                                SizedBox(width: 6),
                                Text('Ticket closed — Read only',
                                    style: TextStyle(
                                        fontSize: 12, color: _C.textSec)),
                              ]),
                        ),
                    ]),
                  ]),
            ),
          ],
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// COMMENT BUBBLE
// ─────────────────────────────────────────────
class _CommentBubble extends StatelessWidget {
  final _Comment comment;
  const _CommentBubble({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                color: comment.avatarColor, shape: BoxShape.circle),
            child: Center(
                child: Text(comment.initials,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white))),
          ),
          const SizedBox(width: 8),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  Text(comment.author,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _C.textPrimary)),
                  if (comment.isAgent) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                          color: _C.primaryLight,
                          borderRadius: BorderRadius.circular(8)),
                      child: const Text('Support',
                          style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: _C.primary)),
                    ),
                  ],
                  const Spacer(),
                  Text(comment.time,
                      style: const TextStyle(fontSize: 9, color: _C.textTert)),
                ]),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: comment.isAgent ? _C.primaryLight : _C.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: comment.isAgent
                            ? _C.primary.withValues(alpha: .2)
                            : _C.border),
                  ),
                  child: Text(comment.text,
                      style: const TextStyle(
                          fontSize: 12, color: _C.textPrimary, height: 1.4)),
                ),
              ])),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REPLY SHEET
// ─────────────────────────────────────────────
class _ReplySheet extends StatefulWidget {
  final _Ticket ticket;
  final void Function(String) onSubmit;
  const _ReplySheet({required this.ticket, required this.onSubmit});

  @override
  State<_ReplySheet> createState() => _ReplySheetState();
}

class _ReplySheetState extends State<_ReplySheet> {
  final _ctrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _ctrl.dispose();
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
            Text('Reply to ${widget.ticket.id}',
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary)),
            const SizedBox(height: 4),
            Text(widget.ticket.subject,
                style: const TextStyle(fontSize: 12, color: _C.textSec),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 14),
            TextField(
              controller: _ctrl,
              maxLines: 4,
              maxLength: 500,
              autofocus: true,
              style: const TextStyle(fontSize: 13, color: _C.textPrimary),
              decoration: InputDecoration(
                hintText: 'Add your comment or update…',
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
                    borderSide:
                        const BorderSide(color: _C.primary, width: 1.5)),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitting
                    ? null
                    : () async {
                        final text = _ctrl.text.trim();
                        if (text.isEmpty) return;
                        setState(() => _submitting = true);
                        await Future.delayed(const Duration(milliseconds: 800));
                        if (mounted) widget.onSubmit(text);
                      },
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
                    : const Text('Send Reply',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED SMALL WIDGETS
// ─────────────────────────────────────────────
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
                borderRadius: BorderRadius.circular(10)),
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

class _EmptyTickets extends StatelessWidget {
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
                child: const Icon(Icons.confirmation_number_outlined,
                    size: 36, color: _C.primary)),
            const SizedBox(height: 16),
            const Text('No tickets yet',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary)),
            const SizedBox(height: 6),
            const Text('Raise a ticket from the first tab to get support.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: _C.textSec, height: 1.5)),
          ]),
        ),
      );
}
