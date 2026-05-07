// ============================================================
// ISF HR Portal — Reliever Screen
// File: lib/screens/attendance/reliever_screen.dart
//
// Features:
//   - Tab 1: Request Reliever form
//       • Date picker
//       • Shift info display
//       • Reason chip selector
//       • Optional description
//       • "Prefer specific person" toggle + employee search
//       • Available Relievers Today section
//   - Tab 2: My Requests history
//       • Filter chips (All / Pending / Approved / Fulfilled / Rejected)
//       • Expandable request cards with status + comments
//
// Dependencies: none beyond flutter/material
// ============================================================

import 'package:flutter/material.dart';

// ─── Replace with actual imports ─────────────────────────
// import '../../theme/app_colors.dart';
// import '../../theme/app_text_styles.dart';
// import '../../data/mock_data.dart';
// ─────────────────────────────────────────────────────────

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
enum _RelieverStatus { pending, approved, fulfilled, rejected }

class _RelieverRequest {
  final String id;
  final DateTime date;
  final String shift;
  final String reason;
  final String? description;
  final _RelieverStatus status;
  final String? coveredBy;
  final String? managerComment;
  bool expanded = false;

  _RelieverRequest({
    required this.id,
    required this.date,
    required this.shift,
    required this.reason,
    this.description,
    required this.status,
    this.coveredBy,
    this.managerComment,
  });
}

class _TeamMember {
  final String initials;
  final String name;
  final String designation;
  final String shift;
  final Color avatarColor;
  final bool available = true;

  const _TeamMember({
    required this.initials,
    required this.name,
    required this.designation,
    required this.shift,
    required this.avatarColor,
  });
}

// ─────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────
final _mockRequests = [
  _RelieverRequest(
    id: 'RLV-2026-014',
    date: DateTime(2026, 4, 25),
    shift: 'Standard (09:00 – 18:00)',
    reason: 'Medical',
    description: 'Scheduled doctor appointment, need full day coverage.',
    status: _RelieverStatus.fulfilled,
    coveredBy: 'Ravi Sharma',
    managerComment: 'Approved. Ravi Sharma has confirmed coverage.',
  ),
  _RelieverRequest(
    id: 'RLV-2026-011',
    date: DateTime(2026, 4, 18),
    shift: 'Standard (09:00 – 18:00)',
    reason: 'Personal',
    description: 'Family commitment.',
    status: _RelieverStatus.approved,
    managerComment: 'Approved. Awaiting colleague confirmation.',
  ),
  _RelieverRequest(
    id: 'RLV-2026-008',
    date: DateTime(2026, 4, 10),
    shift: 'Standard (09:00 – 18:00)',
    reason: 'Training',
    description: 'AWS certification training — full day session.',
    status: _RelieverStatus.rejected,
    managerComment:
        'Coverage unavailable on this date. Please reschedule training.',
  ),
  _RelieverRequest(
    id: 'RLV-2026-005',
    date: DateTime(2026, 3, 22),
    shift: 'Standard (09:00 – 18:00)',
    reason: 'Annual Leave',
    status: _RelieverStatus.fulfilled,
    coveredBy: 'Pooja Nair',
    managerComment: 'Fulfilled by Pooja Nair.',
  ),
];

const _availableToday = [
  _TeamMember(
    initials: 'RS',
    name: 'Ravi Sharma',
    designation: 'Full Stack Developer',
    shift: '09:00 – 18:00',
    avatarColor: Color(0xFF7C3AED),
  ),
  _TeamMember(
    initials: 'PN',
    name: 'Pooja Nair',
    designation: 'Backend Developer',
    shift: '09:00 – 18:00',
    avatarColor: Color(0xFF0D9488),
  ),
  _TeamMember(
    initials: 'SM',
    name: 'Suresh Menon',
    designation: 'QA Engineer',
    shift: '10:00 – 19:00',
    avatarColor: Color(0xFFEA580C),
  ),
];

const _searchSuggestions = [
  _TeamMember(
    initials: 'RS',
    name: 'Ravi Sharma',
    designation: 'Full Stack Developer',
    shift: '09:00 – 18:00',
    avatarColor: Color(0xFF7C3AED),
  ),
  _TeamMember(
    initials: 'PN',
    name: 'Pooja Nair',
    designation: 'Backend Developer',
    shift: '09:00 – 18:00',
    avatarColor: Color(0xFF0D9488),
  ),
  _TeamMember(
    initials: 'SM',
    name: 'Suresh Menon',
    designation: 'QA Engineer',
    shift: '10:00 – 19:00',
    avatarColor: Color(0xFFEA580C),
  ),
  _TeamMember(
    initials: 'NK',
    name: 'Neha Kulkarni',
    designation: 'UI Developer',
    shift: '09:00 – 18:00',
    avatarColor: Color(0xFFEC4899),
  ),
];

const _reasons = [
  'Annual Leave',
  'Medical',
  'Emergency',
  'Personal',
  'Training',
  'Other',
];

const _filterLabels = ['All', 'Pending', 'Approved', 'Fulfilled', 'Rejected'];

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class RelieverScreen extends StatefulWidget {
  const RelieverScreen({super.key});

  @override
  State<RelieverScreen> createState() => _RelieverScreenState();
}

class _RelieverScreenState extends State<RelieverScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  // ── Form state ───────────────────────────────
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedReason;
  bool _preferSpecific = false;
  final _descCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  _TeamMember? _selectedMember;
  bool _showSuggestions = false;
  List<_TeamMember> _filteredSuggestions = [];
  bool _submitting = false;
  final _formKey = GlobalKey<FormState>();

  // ── History state ────────────────────────────
  int _activeFilter = 0;
  final List<_RelieverRequest> _requests = List.from(_mockRequests);

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _descCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Search ───────────────────────────────────
  void _onSearchChanged() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _showSuggestions = q.isNotEmpty;
      _filteredSuggestions = _searchSuggestions
          .where((m) =>
              m.name.toLowerCase().contains(q) ||
              m.designation.toLowerCase().contains(q))
          .toList();
    });
  }

  // ── Filtered requests ────────────────────────
  List<_RelieverRequest> get _filteredRequests {
    if (_activeFilter == 0) return _requests;
    final label = _filterLabels[_activeFilter].toLowerCase();
    return _requests.where((r) {
      switch (r.status) {
        case _RelieverStatus.pending:
          return label == 'pending';
        case _RelieverStatus.approved:
          return label == 'approved';
        case _RelieverStatus.fulfilled:
          return label == 'fulfilled';
        case _RelieverStatus.rejected:
          return label == 'rejected';
      }
    }).toList();
  }

  // ── Date picker ──────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _C.primary,
            onPrimary: Colors.white,
            surface: _C.card,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // ── Submit ───────────────────────────────────
  Future<void> _submit() async {
    if (_selectedReason == null) {
      _showSnack('Please select a reason', _C.error);
      return;
    }
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final newRequest = _RelieverRequest(
      id: 'RLV-2026-0${15 + _requests.length}',
      date: _selectedDate,
      shift: 'Standard (09:00 – 18:00)',
      reason: _selectedReason!,
      description: _descCtrl.text.isEmpty ? null : _descCtrl.text,
      status: _RelieverStatus.pending,
    );

    setState(() {
      _submitting = false;
      _requests.insert(0, newRequest);
      // Reset form
      _selectedDate = DateTime.now().add(const Duration(days: 1));
      _selectedReason = null;
      _preferSpecific = false;
      _descCtrl.clear();
      _searchCtrl.clear();
      _selectedMember = null;
      _showSuggestions = false;
      // Switch to history tab
      _tabCtrl.animateTo(1);
    });

    _showSnack('Reliever request submitted ✅', _C.successDark);
  }

  void _showSnack(String msg, Color bg) {
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

  // ── Assign ───────────────────────────────────
  void _assignReliever(_TeamMember member) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Assign Reliever',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        content: Text('Send a reliever request to ${member.name}?',
            style: const TextStyle(fontSize: 14, color: _C.textSec)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: _C.textSec)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnack('Request sent to ${member.name} ✅', _C.successDark);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Send Request'),
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
      body: Column(children: [
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _buildRequestTab(),
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
        title: const Text('Reliever',
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
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.swap_horiz_rounded, size: 13, color: _C.primary),
              const SizedBox(width: 4),
              Text('${_requests.length} Requests',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _C.primary)),
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
  Widget _buildTabBar() {
    return Container(
      color: _C.card,
      child: TabBar(
        controller: _tabCtrl,
        tabs: const [
          Tab(text: 'Request Reliever'),
          Tab(text: 'My Requests'),
        ],
        labelColor: _C.primary,
        unselectedLabelColor: _C.textSec,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        indicatorColor: _C.primary,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: _C.border,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TAB 1: REQUEST FORM
  // ─────────────────────────────────────────────
  Widget _buildRequestTab() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() => _showSuggestions = false);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          // Info banner
          const _InfoBanner(
            icon: Icons.info_outline_rounded,
            color: _C.primary,
            bg: _C.primaryLight,
            message:
                'Submit a reliever request at least 24 hours in advance for best coverage chances.',
          ),
          const SizedBox(height: 16),

          // Form card
          _formCard(),
          const SizedBox(height: 16),

          // Available today
          _availableTodayCard(),
        ],
      ),
    );
  }

  Widget _formCard() {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Column(children: [
        _cardHeader('Request Reliever', Icons.person_add_outlined),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Date picker ──────────────────
                _fieldLabel('Date *'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: _C.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _C.border, width: 1.5),
                    ),
                    child: Row(children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                            color: _C.primaryLight,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.calendar_today_outlined,
                            size: 16, color: _C.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _formatDate(_selectedDate),
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _C.textPrimary),
                        ),
                      ),
                      Text(
                        _dayLabel(_selectedDate),
                        style: const TextStyle(fontSize: 11, color: _C.textSec),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.edit_calendar_outlined,
                          size: 16, color: _C.textTert),
                    ]),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Shift display ────────────────
                _fieldLabel('Shift'),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _C.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _C.border),
                  ),
                  child: Row(children: [
                    const Icon(Icons.access_time_rounded,
                        size: 16, color: _C.textSec),
                    const SizedBox(width: 10),
                    const Text('Standard (09:00 – 18:00)',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _C.textPrimary)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                          color: _C.primaryLight,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Text('Your Shift',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: _C.primary)),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),

                // ── Reason chips ─────────────────
                _fieldLabel('Reason *'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _reasons.map((r) {
                    final active = _selectedReason == r;
                    final (color, bg) = _reasonColor(r);
                    return GestureDetector(
                      onTap: () => setState(() => _selectedReason = r),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: active ? color : _C.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: active ? color : _C.border,
                            width: 1.5,
                          ),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(_reasonIcon(r),
                              size: 13,
                              color: active ? Colors.white : _C.textSec),
                          const SizedBox(width: 5),
                          Text(r,
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

                // ── Description ──────────────────
                _fieldLabel('Description (optional)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 3,
                  maxLength: 200,
                  style: const TextStyle(fontSize: 13, color: _C.textPrimary),
                  decoration: _inputDeco('Provide any additional details…'),
                ),
                const SizedBox(height: 16),

                // ── Prefer specific person ────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _preferSpecific ? _C.primaryLight : _C.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _preferSpecific
                          ? _C.primary.withValues(alpha: .3)
                          : _C.border,
                    ),
                  ),
                  child: Column(children: [
                    Row(children: [
                      const Icon(Icons.person_search_outlined,
                          size: 18, color: _C.primary),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Prefer specific person?',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _C.textPrimary)),
                            Text('Search a team member to request',
                                style:
                                    TextStyle(fontSize: 11, color: _C.textSec)),
                          ],
                        ),
                      ),
                      Transform.scale(
                        scale: 0.85,
                        child: Switch(
                          value: _preferSpecific,
                          onChanged: (v) => setState(() {
                            _preferSpecific = v;
                            if (!v) {
                              _searchCtrl.clear();
                              _selectedMember = null;
                              _showSuggestions = false;
                            }
                          }),
                          activeThumbColor: _C.primary,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ]),

                    // Search field (shown when toggle ON)
                    if (_preferSpecific) ...[
                      const SizedBox(height: 12),
                      // Selected member chip
                      if (_selectedMember != null)
                        _SelectedMemberChip(
                          member: _selectedMember!,
                          onRemove: () => setState(() {
                            _selectedMember = null;
                            _searchCtrl.clear();
                          }),
                        )
                      else ...[
                        TextField(
                          controller: _searchCtrl,
                          style: const TextStyle(
                              fontSize: 13, color: _C.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Search team member…',
                            hintStyle: const TextStyle(
                                fontSize: 13, color: _C.textTert),
                            prefixIcon: const Icon(Icons.search_rounded,
                                size: 18, color: _C.textTert),
                            filled: true,
                            fillColor: _C.card,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 11),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: _C.border, width: 1.5)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: _C.border, width: 1.5)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: _C.primary, width: 1.5)),
                          ),
                        ),
                        // Suggestions
                        if (_showSuggestions &&
                            _filteredSuggestions.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Container(
                            decoration: BoxDecoration(
                              color: _C.card,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _C.border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: .06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children:
                                  _filteredSuggestions.asMap().entries.map((e) {
                                final i = e.key;
                                final m = e.value;
                                return Column(children: [
                                  InkWell(
                                    onTap: () => setState(() {
                                      _selectedMember = m;
                                      _showSuggestions = false;
                                      _searchCtrl.text = m.name;
                                    }),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      child: Row(children: [
                                        _miniAvatar(m),
                                        const SizedBox(width: 10),
                                        Expanded(
                                            child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(m.name,
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: _C.textPrimary)),
                                            Text(m.designation,
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    color: _C.textSec)),
                                          ],
                                        )),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                              color: _C.successLight,
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: const Text('Available',
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w700,
                                                  color: _C.successDark)),
                                        ),
                                      ]),
                                    ),
                                  ),
                                  if (i < _filteredSuggestions.length - 1)
                                    Container(
                                        height: 1,
                                        color: _C.border,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 12)),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ],
                        if (_showSuggestions && _filteredSuggestions.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text('No team members found',
                                style: TextStyle(
                                    fontSize: 12, color: _C.textTert)),
                          ),
                      ],
                    ],
                  ]),
                ),
                const SizedBox(height: 24),

                // ── Submit button ─────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
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
                              Text('Submit Request',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _availableTodayCard() {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Column(children: [
        _cardHeader('Available Relievers Today', Icons.group_outlined),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Column(
            children: _availableToday.asMap().entries.map((e) {
              final i = e.key;
              final m = e.value;
              return Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(children: [
                    _miniAvatar(m),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.name,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _C.textPrimary)),
                        const SizedBox(height: 1),
                        Text(m.designation,
                            style: const TextStyle(
                                fontSize: 11, color: _C.textSec)),
                        Row(children: [
                          const Icon(Icons.access_time_outlined,
                              size: 10, color: _C.textTert),
                          const SizedBox(width: 3),
                          Text(m.shift,
                              style: const TextStyle(
                                  fontSize: 10, color: _C.textTert)),
                        ]),
                      ],
                    )),
                    _AssignButton(onTap: () => _assignReliever(m)),
                  ]),
                ),
                if (i < _availableToday.length - 1)
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
    final filtered = _filteredRequests;

    return Column(children: [
      // Filter chips
      Container(
        color: _C.card,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_filterLabels.length, (i) {
              final active = i == _activeFilter;
              final label = _filterLabels[i];
              final count = i == 0
                  ? _requests.length
                  : _requests
                      .where((r) => _statusMatch(r.status, label))
                      .length;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _activeFilter = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: active ? _C.primary : _C.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: active ? _C.primary : _C.border,
                      ),
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
            }),
          ),
        ),
      ),
      Container(height: 1, color: _C.border),

      // List
      Expanded(
        child: filtered.isEmpty
            ? _EmptyState(filterLabel: _filterLabels[_activeFilter])
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _RequestCard(
                  request: filtered[i],
                  onToggle: () => setState(
                      () => filtered[i].expanded = !filtered[i].expanded),
                ),
              ),
      ),
    ]);
  }

  // ─────────────────────────────────────────────
  // SHARED HELPERS
  // ─────────────────────────────────────────────
  bool _statusMatch(_RelieverStatus s, String label) {
    switch (s) {
      case _RelieverStatus.pending:
        return label == 'Pending';
      case _RelieverStatus.approved:
        return label == 'Approved';
      case _RelieverStatus.fulfilled:
        return label == 'Fulfilled';
      case _RelieverStatus.rejected:
        return label == 'Rejected';
    }
  }

  Widget _cardHeader(String title, IconData icon) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    color: _C.primaryLight,
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 16, color: _C.primary),
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
        ],
      );

  Widget _fieldLabel(String text) => Text(text,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: _C.textPrimary));

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

  Widget _miniAvatar(_TeamMember m) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: m.avatarColor, shape: BoxShape.circle),
        child: Center(
          child: Text(m.initials,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
        ),
      );

  String _formatDate(DateTime d) {
    const months = [
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
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  String _dayLabel(DateTime d) {
    final diff = d.difference(DateTime.now()).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[d.weekday - 1];
  }

  (Color, Color) _reasonColor(String r) {
    switch (r) {
      case 'Annual Leave':
        return (_C.primary, _C.primaryLight);
      case 'Medical':
        return (_C.error, _C.errorLight);
      case 'Emergency':
        return (_C.orange, _C.orangeLight);
      case 'Personal':
        return (_C.accent, _C.accentLight);
      case 'Training':
        return (_C.teal, _C.tealLight);
      default:
        return (_C.textSec, _C.surface);
    }
  }

  IconData _reasonIcon(String r) {
    switch (r) {
      case 'Annual Leave':
        return Icons.beach_access_outlined;
      case 'Medical':
        return Icons.local_hospital_outlined;
      case 'Emergency':
        return Icons.warning_amber_outlined;
      case 'Personal':
        return Icons.person_outline_rounded;
      case 'Training':
        return Icons.school_outlined;
      default:
        return Icons.more_horiz_rounded;
    }
  }
}

// ─────────────────────────────────────────────
// SELECTED MEMBER CHIP
// ─────────────────────────────────────────────
class _SelectedMemberChip extends StatelessWidget {
  final _TeamMember member;
  final VoidCallback onRemove;
  const _SelectedMemberChip({required this.member, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _C.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.primary.withValues(alpha: .3)),
      ),
      child: Row(children: [
        Container(
          width: 32,
          height: 32,
          decoration:
              BoxDecoration(color: member.avatarColor, shape: BoxShape.circle),
          child: Center(
            child: Text(member.initials,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(member.name,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _C.primary)),
            Text(member.designation,
                style: const TextStyle(fontSize: 10, color: _C.textSec)),
          ],
        )),
        GestureDetector(
          onTap: onRemove,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
                color: _C.primary.withValues(alpha: .15), shape: BoxShape.circle),
            child: const Icon(Icons.close_rounded, size: 13, color: _C.primary),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// ASSIGN BUTTON
// ─────────────────────────────────────────────
class _AssignButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AssignButton({required this.onTap});

  @override
  State<_AssignButton> createState() => _AssignButtonState();
}

class _AssignButtonState extends State<_AssignButton> {
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _pressed ? _C.primaryDark : _C.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text('Assign',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REQUEST CARD
// ─────────────────────────────────────────────
class _RequestCard extends StatelessWidget {
  final _RelieverRequest request;
  final VoidCallback onToggle;

  const _RequestCard({required this.request, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final meta = _statusMetaFor(request.status);
    final (rColor, rBg) = _reasonColorFor(request.reason);

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: request.expanded ? meta.color.withValues(alpha: .4) : _C.border,
            width: request.expanded ? 1.5 : 1,
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
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row
                Row(children: [
                  Text(request.id,
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
                        color: meta.bg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: meta.color.withValues(alpha: .3))),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(meta.icon, size: 10, color: meta.color),
                      const SizedBox(width: 4),
                      Text(meta.label,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: meta.color)),
                    ]),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: request.expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 18, color: _C.textTert),
                  ),
                ]),
                const SizedBox(height: 10),

                // Date + shift
                Row(children: [
                  _infoChip(Icons.calendar_today_outlined,
                      _formatDate(request.date), _C.primary, _C.primaryLight),
                  const SizedBox(width: 8),
                  _infoChip(Icons.access_time_outlined, '09:00 – 18:00',
                      _C.textSec, _C.surface),
                ]),
                const SizedBox(height: 8),

                // Reason
                Row(children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: rBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: rColor.withValues(alpha: .3))),
                    child: Text(request.reason,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: rColor)),
                  ),
                  if (request.coveredBy != null) ...[
                    const SizedBox(width: 8),
                    Row(children: [
                      const Icon(Icons.check_circle_outline_rounded,
                          size: 13, color: _C.successDark),
                      const SizedBox(width: 3),
                      Text('${request.coveredBy}',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _C.successDark)),
                    ]),
                  ],
                ]),
              ],
            ),
          ),

          // Expanded detail
          if (request.expanded) ...[
            Container(
                height: 1,
                color: _C.border,
                margin: const EdgeInsets.symmetric(horizontal: 14)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (request.description != null) ...[
                    const Text('Description',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _C.textSec)),
                    const SizedBox(height: 4),
                    Text(request.description!,
                        style: const TextStyle(
                            fontSize: 13, color: _C.textPrimary, height: 1.5)),
                    const SizedBox(height: 12),
                  ],
                  if (request.managerComment != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: meta.bg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: meta.color.withValues(alpha: .2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(Icons.comment_outlined,
                                size: 13, color: meta.color),
                            const SizedBox(width: 5),
                            Text('Manager Comment',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: meta.color)),
                          ]),
                          const SizedBox(height: 6),
                          Text(request.managerComment!,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: _C.textPrimary,
                                  height: 1.5)),
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

  Widget _infoChip(IconData icon, String label, Color color, Color bg) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: .2))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        ]),
      );

  ({String label, Color color, Color bg, IconData icon}) _statusMetaFor(
      _RelieverStatus s) {
    switch (s) {
      case _RelieverStatus.pending:
        return (
          label: 'Pending',
          color: _C.warningDark,
          bg: _C.warningLight,
          icon: Icons.hourglass_top_rounded
        );
      case _RelieverStatus.approved:
        return (
          label: 'Approved',
          color: _C.primary,
          bg: _C.primaryLight,
          icon: Icons.check_rounded
        );
      case _RelieverStatus.fulfilled:
        return (
          label: 'Fulfilled',
          color: _C.successDark,
          bg: _C.successLight,
          icon: Icons.verified_outlined
        );
      case _RelieverStatus.rejected:
        return (
          label: 'Rejected',
          color: _C.error,
          bg: _C.errorLight,
          icon: Icons.close_rounded
        );
    }
  }

  (Color, Color) _reasonColorFor(String r) {
    switch (r) {
      case 'Annual Leave':
        return (_C.primary, _C.primaryLight);
      case 'Medical':
        return (_C.error, _C.errorLight);
      case 'Emergency':
        return (_C.orange, _C.orangeLight);
      case 'Personal':
        return (_C.accent, _C.accentLight);
      case 'Training':
        return (_C.teal, _C.tealLight);
      default:
        return (_C.textSec, _C.surface);
    }
  }

  String _formatDate(DateTime d) {
    const months = [
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
    return '${d.day} ${months[d.month]} ${d.year}';
  }
}

// ─────────────────────────────────────────────
// INFO BANNER
// ─────────────────────────────────────────────
class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final Color color, bg;
  final String message;

  const _InfoBanner({
    required this.icon,
    required this.color,
    required this.bg,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Row(children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(message,
              style: TextStyle(fontSize: 12, color: color, height: 1.4)),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String filterLabel;
  const _EmptyState({required this.filterLabel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: _C.primaryLight,
                  borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.swap_horiz_rounded,
                  size: 36, color: _C.primary),
            ),
            const SizedBox(height: 16),
            Text(
              filterLabel == 'All'
                  ? 'No reliever requests yet'
                  : 'No $filterLabel requests',
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Your reliever requests will appear here once submitted.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _C.textSec, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
