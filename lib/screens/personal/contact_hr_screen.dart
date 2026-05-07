// ============================================================
// ISF HR Portal — Contact HR Screen
// File: lib/screens/personal/contact_hr_screen.dart
//
// Features:
//   - Quick action buttons (Raise Query / Call HR / Email HR / WhatsApp)
//   - HR Team directory with call & chat actions
//   - Raise a Query form with type chips, priority, char counter
//   - My Past Queries list with expandable detail + status
//   - Help Resources 2x2 grid
//
// Dependencies: none beyond flutter/material
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Replace with actual imports ─────────────────────────
// import '../../theme/app_colors.dart';
// import '../../theme/app_text_styles.dart';
// ─────────────────────────────────────────────────────────

// ─────────────────────────────────────────────
// INLINE THEME
// ─────────────────────────────────────────────
class _C {
  static const primary = Color(0xFF2563EB);
  static const primaryLight = Color(0xFFEFF6FF);
  static const accent = Color(0xFF6366F1);
  static const accentLight = Color(0xFFEEF2FF);
  static const successLight = Color(0xFFDCFCE7);
  static const successDark = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
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
class _HRContact {
  final String initials, name, role, department, phone, email;
  final Color avatarColor;
  const _HRContact({
    required this.initials,
    required this.name,
    required this.role,
    required this.department,
    required this.phone,
    required this.email,
    required this.avatarColor,
  });
}

class _PastQuery {
  final String id, subject, type, description, hrResponse;
  final String raisedOn;
  final _QueryStatus status;
  bool expanded = false;
  _PastQuery({
    required this.id,
    required this.subject,
    required this.type,
    required this.description,
    required this.raisedOn,
    required this.status,
    required this.hrResponse,
  });
}

enum _QueryStatus { open, inProgress, resolved }

enum _Priority { low, medium, high }

// ─────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────
const _hrTeam = [
  _HRContact(
    initials: 'SP',
    name: 'Sneha Patil',
    role: 'HR Manager',
    department: 'People & Culture',
    phone: '+91 98100 11111',
    email: 'sneha.patil@isf.com',
    avatarColor: Color(0xFFEC4899),
  ),
  _HRContact(
    initials: 'AR',
    name: 'Anjali Rao',
    role: 'HR Executive',
    department: 'Recruitment',
    phone: '+91 98100 22222',
    email: 'anjali.rao@isf.com',
    avatarColor: Color(0xFF8B5CF6),
  ),
  _HRContact(
    initials: 'VK',
    name: 'Vikram Kadam',
    role: 'HR Executive',
    department: 'Payroll & Compliance',
    phone: '+91 98100 33333',
    email: 'vikram.kadam@isf.com',
    avatarColor: Color(0xFF0D9488),
  ),
  _HRContact(
    initials: 'PM',
    name: 'Priya Mehta',
    role: 'Direct Manager',
    department: 'IT Department',
    phone: '+91 98100 44444',
    email: 'priya.mehta@isf.com',
    avatarColor: Color(0xFF2563EB),
  ),
];

final _pastQueries = [
  _PastQuery(
    id: 'ISF-QRY-0041',
    subject: 'Leave balance discrepancy for March',
    type: 'Leave Issue',
    description:
        'My casual leave balance shows 10 days but I applied for 3 days in March and it was approved. The balance should be 12 but shows 10.',
    raisedOn: '20 Apr 2026',
    status: _QueryStatus.resolved,
    hrResponse:
        'The balance has been corrected. A system sync issue caused the discrepancy. Your current balance is now 12 days. Apologies for the inconvenience.',
  ),
  _PastQuery(
    id: 'ISF-QRY-0038',
    subject: 'March payslip TDS calculation query',
    type: 'Payroll',
    description:
        'The TDS deducted in my March payslip seems higher than expected based on my declared investments. Please review.',
    raisedOn: '05 Apr 2026',
    status: _QueryStatus.inProgress,
    hrResponse:
        'We are reviewing your IT declaration against the deductions. Will update by 30 Apr.',
  ),
  _PastQuery(
    id: 'ISF-QRY-0032',
    subject: 'WFH policy clarification',
    type: 'General',
    description:
        'Can I work from home on Fridays as per the new Q2 policy? Need clarification on the eligibility criteria.',
    raisedOn: '15 Mar 2026',
    status: _QueryStatus.open,
    hrResponse: '',
  ),
];

const _queryTypes = [
  'Leave Issue',
  'Payroll',
  'Attendance',
  'Harassment',
  'Grievance',
  'General',
];

const _helpResources = [
  (Icons.description_outlined, 'HR Policy Doc', _C.primary, _C.primaryLight),
  (Icons.event_available_outlined, 'Leave Policy', _C.teal, _C.tealLight),
  (Icons.shield_outlined, 'POSH Policy', _C.accent, _C.accentLight),
  (Icons.gavel_outlined, 'Grievance Policy', _C.orange, _C.orangeLight),
];

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class ContactHRScreen extends StatefulWidget {
  const ContactHRScreen({super.key});
  @override
  State<ContactHRScreen> createState() => _ContactHRScreenState();
}

class _ContactHRScreenState extends State<ContactHRScreen> {
  // ── Query form state ─────────────────────────
  String? _selectedType;
  _Priority _priority = _Priority.medium;
  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;
  // ── Past queries ─────────────────────────────
  final List<_PastQuery> _queries = _pastQueries;

  @override
  void initState() {
    super.initState();
    _descCtrl
        .addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ── Submit query ─────────────────────────────
  Future<void> _submitQuery() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null) {
      _showSnack('Please select a query type', _C.error);
      return;
    }
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 1300));
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _queries.insert(
          0,
          _PastQuery(
            id: 'ISF-QRY-${(DateTime.now().millisecondsSinceEpoch % 9000 + 1000)}',
            subject: _subjectCtrl.text,
            type: _selectedType!,
            description: _descCtrl.text,
            raisedOn: 'Today',
            status: _QueryStatus.open,
            hrResponse: '',
          ));
      _subjectCtrl.clear();
      _descCtrl.clear();
      _selectedType = null;
      _priority = _Priority.medium;
    });
    _showSnack('Query raised successfully ✅', _C.successDark);
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

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnack('$label copied', _C.textSec);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          _buildQuickActions(),
          const SizedBox(height: 16),
          _buildHRDirectory(),
          const SizedBox(height: 16),
          _buildQueryForm(),
          const SizedBox(height: 16),
          _buildPastQueries(),
          const SizedBox(height: 16),
          _buildHelpResources(),
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
        title: const Text('Contact HR',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _C.border),
        ),
      );

  // ─────────────────────────────────────────────
  // QUICK ACTIONS
  // ─────────────────────────────────────────────
  Widget _buildQuickActions() {
    final actions = [
      (
        Icons.support_agent_outlined,
        'Raise\nQuery',
        _C.primary,
        _C.primaryLight,
        () => Scrollable.ensureVisible(_formKey.currentContext ?? context,
            duration: const Duration(milliseconds: 400))
      ),
      (
        Icons.call_outlined,
        'Call HR',
        _C.successDark,
        _C.successLight,
        () => _showCallSheet()
      ),
      (
        Icons.email_outlined,
        'Email HR',
        _C.accent,
        _C.accentLight,
        () => _copyToClipboard('hr@isf.com', 'Email')
      ),
      (
        Icons.chat_rounded,
        'WhatsApp\nHR',
        _C.teal,
        _C.tealLight,
        () => _showSnack('Opening WhatsApp…', _C.teal)
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.map((a) {
          final (icon, label, color, bg, onTap) = a;
          return _QuickActionBtn(
            icon: icon,
            label: label,
            color: color,
            bg: bg,
            onTap: onTap,
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HR DIRECTORY
  // ─────────────────────────────────────────────
  Widget _buildHRDirectory() {
    return _SectionCard(
      title: 'HR Team',
      icon: Icons.people_outline_rounded,
      child: Column(
        children: _hrTeam.asMap().entries.map((e) {
          final i = e.key;
          final contact = e.value;
          return _HRContactRow(
            contact: contact,
            isLast: i == _hrTeam.length - 1,
            onCall: () => _showCallSheet(contact: contact),
            onChat: () => _showChatOptions(contact),
            onLongPress: () => _copyToClipboard(contact.email, contact.name),
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // QUERY FORM
  // ─────────────────────────────────────────────
  Widget _buildQueryForm() {
    return _SectionCard(
      title: 'Raise HR Query',
      icon: Icons.help_outline_rounded,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Query type chips
            _fieldLabel('Query Type *'),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _queryTypes.map((type) {
                  final active = _selectedType == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? _C.primary : _C.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: active ? _C.primary : _C.border,
                            width: 1.5,
                          ),
                        ),
                        child: Text(type,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: active ? Colors.white : _C.textSec)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Subject
            _fieldLabel('Subject *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _subjectCtrl,
              maxLength: 100,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Subject is required' : null,
              style: const TextStyle(
                  fontSize: 14,
                  color: _C.textPrimary,
                  fontWeight: FontWeight.w500),
              decoration: _inputDeco('e.g. Leave balance discrepancy'),
            ),
            const SizedBox(height: 12),

            // Description
            _fieldLabel('Description *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descCtrl,
              maxLines: 4,
              maxLength: 500,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Description is required';
                }
                if (v.trim().length < 20) {
                  return 'Please provide at least 20 characters';
                }
                return null;
              },
              style: const TextStyle(fontSize: 14, color: _C.textPrimary),
              decoration: _inputDeco('Describe your issue in detail…'),
            ),
            const SizedBox(height: 12),

            // Priority
            _fieldLabel('Priority'),
            const SizedBox(height: 8),
            Row(
                children: _Priority.values.map((p) {
              final active = _priority == p;
              final meta = _priorityMeta(p);
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: p != _Priority.high ? 8 : 0),
                  child: GestureDetector(
                    onTap: () => setState(() => _priority = p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      height: 40,
                      decoration: BoxDecoration(
                        color: active ? meta.color : _C.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: active ? meta.color : _C.border,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(meta.label,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: active ? Colors.white : _C.textSec)),
                      ),
                    ),
                  ),
                ),
              );
            }).toList()),
            const SizedBox(height: 20),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submitQuery,
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
                          Text('Submit Query',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // PAST QUERIES
  // ─────────────────────────────────────────────
  Widget _buildPastQueries() {
    return _SectionCard(
      title: 'My Past Queries',
      icon: Icons.history_rounded,
      child: _queries.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text('No queries raised yet',
                    style: TextStyle(fontSize: 13, color: _C.textTert)),
              ),
            )
          : Column(
              children: _queries.asMap().entries.map((e) {
                final i = e.key;
                final q = e.value;
                return _QueryCard(
                  query: q,
                  isLast: i == _queries.length - 1,
                  onToggle: () => setState(() => q.expanded = !q.expanded),
                );
              }).toList(),
            ),
    );
  }

  // ─────────────────────────────────────────────
  // HELP RESOURCES
  // ─────────────────────────────────────────────
  Widget _buildHelpResources() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header outside card
        Row(children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                color: _C.primaryLight, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.library_books_outlined,
                size: 15, color: _C.primary),
          ),
          const SizedBox(width: 8),
          const Text('Help Resources',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _C.textPrimary)),
        ]),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: _helpResources.map((r) {
            final (icon, label, color, bg) = r;
            return GestureDetector(
              onTap: () => _showSnack('Opening $label…', color),
              child: Container(
                decoration: BoxDecoration(
                  color: _C.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _C.border),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: bg, borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon, size: 18, color: color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(label,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _C.textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // BOTTOM SHEETS
  // ─────────────────────────────────────────────
  void _showCallSheet({_HRContact? contact}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _CallSheet(
          contact: contact ?? _hrTeam[0],
          onCopy: (val, lbl) => _copyToClipboard(val, lbl)),
    );
  }

  void _showChatOptions(_HRContact contact) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ChatOptionsSheet(contact: contact),
    );
  }

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────
  ({String label, Color color}) _priorityMeta(_Priority p) {
    switch (p) {
      case _Priority.low:
        return (label: 'Low', color: _C.textSec);
      case _Priority.medium:
        return (label: 'Medium', color: _C.warning);
      case _Priority.high:
        return (label: 'High', color: _C.error);
    }
  }

  Widget _fieldLabel(String text) => Text(text,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: _C.textPrimary));

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: _C.textTert),
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
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _C.error, width: 1.5)),
        counterStyle: const TextStyle(fontSize: 11, color: _C.textTert),
        errorStyle: const TextStyle(fontSize: 11, color: _C.error),
      );
}

// ─────────────────────────────────────────────
// QUICK ACTION BUTTON
// ─────────────────────────────────────────────
class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color, bg;
  final VoidCallback onTap;

  const _QuickActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 52,
          height: 52,
          decoration:
              BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 6),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _C.textSec,
                height: 1.3)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// HR CONTACT ROW
// ─────────────────────────────────────────────
class _HRContactRow extends StatelessWidget {
  final _HRContact contact;
  final bool isLast;
  final VoidCallback onCall, onChat, onLongPress;

  const _HRContactRow({
    required this.contact,
    required this.isLast,
    required this.onCall,
    required this.onChat,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      InkWell(
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: contact.avatarColor, shape: BoxShape.circle),
              child: Center(
                child: Text(contact.initials,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contact.name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _C.textPrimary)),
                const SizedBox(height: 2),
                Text('${contact.role} · ${contact.department}',
                    style: const TextStyle(fontSize: 11, color: _C.textSec)),
              ],
            )),
            // Actions
            Row(children: [
              _circleIconBtn(
                  Icons.call_outlined, _C.successDark, _C.successLight, onCall),
              const SizedBox(width: 8),
              _circleIconBtn(Icons.chat_bubble_outline_rounded, _C.primary,
                  _C.primaryLight, onChat),
            ]),
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

  Widget _circleIconBtn(
          IconData icon, Color color, Color bg, VoidCallback fn) =>
      GestureDetector(
        onTap: fn,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, size: 16, color: color),
        ),
      );
}

// ─────────────────────────────────────────────
// QUERY CARD (expandable)
// ─────────────────────────────────────────────
class _QueryCard extends StatelessWidget {
  final _PastQuery query;
  final bool isLast;
  final VoidCallback onToggle;

  const _QueryCard({
    required this.query,
    required this.isLast,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final meta = _statusMeta(query.status);
    return Column(children: [
      InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                // Query number
                Text(query.id,
                    style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: _C.textTert,
                        letterSpacing: 0.5)),
                const Spacer(),
                // Status chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: meta.bg, borderRadius: BorderRadius.circular(20)),
                  child: Text(meta.label,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: meta.color)),
                ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: query.expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 18, color: _C.textTert),
                ),
              ]),
              const SizedBox(height: 6),
              Text(query.subject,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _C.textPrimary),
                  maxLines: query.expanded ? null : 1,
                  overflow: query.expanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                      color: _C.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _C.border)),
                  child: Text(query.type,
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _C.textSec)),
                ),
                const SizedBox(width: 8),
                Text(query.raisedOn,
                    style: const TextStyle(fontSize: 11, color: _C.textTert)),
              ]),
              // Expanded detail
              if (query.expanded) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: _C.surface,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Your Query',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _C.textSec)),
                      const SizedBox(height: 4),
                      Text(query.description,
                          style: const TextStyle(
                              fontSize: 13,
                              color: _C.textPrimary,
                              height: 1.5)),
                      if (query.hrResponse.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(height: 1, color: _C.border),
                        const SizedBox(height: 12),
                        Row(children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                                color: _C.primaryLight, shape: BoxShape.circle),
                            child: const Center(
                              child: Text('HR',
                                  style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                      color: _C.primary)),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('HR Response',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _C.primary)),
                        ]),
                        const SizedBox(height: 6),
                        Text(query.hrResponse,
                            style: const TextStyle(
                                fontSize: 13,
                                color: _C.textPrimary,
                                height: 1.5)),
                      ] else if (query.status == _QueryStatus.open) ...[
                        const SizedBox(height: 10),
                        const Row(children: [
                          Icon(Icons.access_time_rounded,
                              size: 13, color: _C.textTert),
                          SizedBox(width: 4),
                          Text('Awaiting HR response…',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: _C.textTert,
                                  fontStyle: FontStyle.italic)),
                        ]),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      if (!isLast)
        Container(
            height: 1,
            color: _C.border,
            margin: const EdgeInsets.symmetric(horizontal: 16)),
    ]);
  }

  ({String label, Color color, Color bg}) _statusMeta(_QueryStatus s) {
    switch (s) {
      case _QueryStatus.open:
        return (label: 'Open', color: _C.orange, bg: _C.orangeLight);
      case _QueryStatus.inProgress:
        return (label: 'In Progress', color: _C.primary, bg: _C.primaryLight);
      case _QueryStatus.resolved:
        return (label: 'Resolved', color: _C.successDark, bg: _C.successLight);
    }
  }
}

// ─────────────────────────────────────────────
// SECTION CARD WRAPPER
// ─────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CALL SHEET
// ─────────────────────────────────────────────
class _CallSheet extends StatelessWidget {
  final _HRContact contact;
  final void Function(String, String) onCopy;

  const _CallSheet({required this.contact, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: _C.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
                color: contact.avatarColor, shape: BoxShape.circle),
            child: Center(
                child: Text(contact.initials,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white))),
          ),
          const SizedBox(height: 12),
          Text(contact.name,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary)),
          const SizedBox(height: 2),
          Text('${contact.role} · ${contact.department}',
              style: const TextStyle(fontSize: 13, color: _C.textSec)),
          const SizedBox(height: 20),
          // Phone row
          _ContactRow(
            icon: Icons.call_outlined,
            iconColor: _C.successDark,
            iconBg: _C.successLight,
            label: 'Phone',
            value: contact.phone,
            onTap: () => onCopy(contact.phone, 'Phone number'),
          ),
          const SizedBox(height: 10),
          // Email row
          _ContactRow(
            icon: Icons.email_outlined,
            iconColor: _C.primary,
            iconBg: _C.primaryLight,
            label: 'Email',
            value: contact.email,
            onTap: () => onCopy(contact.email, 'Email'),
          ),
          const SizedBox(height: 24),
          // Call button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onCopy(contact.phone, 'Number');
              },
              icon: const Icon(Icons.call_rounded, size: 18),
              label: Text('Call ${contact.name.split(' ').first}',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.successDark,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor, iconBg;
  final String label, value;
  final VoidCallback onTap;

  const _ContactRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.border)),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 11, color: _C.textSec)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _C.textPrimary)),
            ],
          )),
          const Icon(Icons.copy_outlined, size: 15, color: _C.textTert),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CHAT OPTIONS SHEET
// ─────────────────────────────────────────────
class _ChatOptionsSheet extends StatelessWidget {
  final _HRContact contact;
  const _ChatOptionsSheet({required this.contact});

  @override
  Widget build(BuildContext context) {
    final options = [
      (
        Icons.chat_bubble_outline_rounded,
        'In-App Chat',
        'Send a message via ISF Portal',
        _C.primary,
        _C.primaryLight
      ),
      (
        Icons.phone_outlined,
        'WhatsApp',
        'Chat on WhatsApp',
        _C.teal,
        _C.tealLight
      ),
      (Icons.email_outlined, 'Email', contact.email, _C.accent, _C.accentLight),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: _C.border, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 18),
          Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: contact.avatarColor, shape: BoxShape.circle),
              child: Center(
                  child: Text(contact.initials,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white))),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Chat with ${contact.name.split(' ').first}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _C.textPrimary)),
              Text(contact.role,
                  style: const TextStyle(fontSize: 12, color: _C.textSec)),
            ]),
          ]),
          const SizedBox(height: 16),
          ...options.map((o) {
            final (icon, title, sub, color, bg) = o;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: bg, borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, size: 20, color: color),
                ),
                title: Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _C.textPrimary)),
                subtitle: Text(sub,
                    style: const TextStyle(fontSize: 11, color: _C.textSec),
                    overflow: TextOverflow.ellipsis),
                trailing: const Icon(Icons.arrow_forward_ios_rounded,
                    size: 13, color: _C.textTert),
                onTap: () => Navigator.pop(context),
              ),
            );
          }),
        ],
      ),
    );
  }
}
