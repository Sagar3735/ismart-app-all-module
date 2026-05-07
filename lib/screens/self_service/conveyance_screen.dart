// ============================================================
// ISF HR Portal — Conveyance Screen
// File: lib/screens/self_service/conveyance_screen.dart
//
// Features:
//   - Monthly conveyance summary hero card
//   - Add expense form:
//       • Date picker
//       • Trip type chips (Office Visit / Client Meeting / Site Visit / Other)
//       • From/To location fields
//       • Mode of transport chips (Cab / Auto / Own Vehicle / Public Transport / Flight)
//       • Distance field (km, auto-calc for own vehicle)
//       • Amount field with receipt toggle
//       • Billable to client toggle
//   - Expense list with swipe-to-delete and edit
//   - Submit for approval button
//   - Claim history with status tracking
//   - Export/Share summary
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
enum _TripType { officeVisit, clientMeeting, siteVisit, other }

enum _Transport { cab, auto, ownVehicle, publicTransport, flight }

enum _ClaimStatus { draft, submitted, approved, rejected, paid }

class _ConveyanceEntry {
  final String id;
  final DateTime date;
  final _TripType tripType;
  final _Transport transport;
  final String fromLocation;
  final String toLocation;
  final double? distanceKm;
  final double amount;
  final bool hasReceipt;
  final bool billableToClient;
  final String? note;

  const _ConveyanceEntry({
    required this.id,
    required this.date,
    required this.tripType,
    required this.transport,
    required this.fromLocation,
    required this.toLocation,
    this.distanceKm,
    required this.amount,
    this.hasReceipt = false,
    this.billableToClient = false,
    this.note,
  });
}

class _ConveyanceClaim {
  final String id;
  final String month;
  final List<_ConveyanceEntry> entries;
  final double total;
  final _ClaimStatus status;
  final String submittedOn;
  final String? approvedOn;
  final String? managerComment;
  bool expanded;

  _ConveyanceClaim({
    required this.id,
    required this.month,
    required this.entries,
    required this.total,
    required this.status,
    required this.submittedOn,
    this.approvedOn,
    this.managerComment,
    this.expanded = false,
  });
}

// ─────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────
final _mockPastClaims = [
  _ConveyanceClaim(
    id: 'CNV-2026-004',
    month: 'March 2026',
    entries: [],
    total: 4850,
    status: _ClaimStatus.paid,
    submittedOn: '02 Apr 2026',
    approvedOn: '05 Apr 2026',
    managerComment: 'Approved. Paid in April salary.',
    expanded: false,
  ),
  _ConveyanceClaim(
    id: 'CNV-2026-002',
    month: 'February 2026',
    entries: [],
    total: 3200,
    status: _ClaimStatus.approved,
    submittedOn: '04 Mar 2026',
    approvedOn: '08 Mar 2026',
    managerComment: 'Approved. Processing for payment.',
    expanded: false,
  ),
  _ConveyanceClaim(
    id: 'CNV-2025-012',
    month: 'December 2025',
    entries: [],
    total: 6100,
    status: _ClaimStatus.rejected,
    submittedOn: '03 Jan 2026',
    managerComment:
        'Missing receipts for 3 entries. Please re-submit with receipts.',
    expanded: false,
  ),
];

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────
String _fmtCurrency(double v) {
  if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(1)}K';
  return '₹${v.toStringAsFixed(0)}';
}

String _fmtFull(double v) {
  final s = v.toInt().toString();
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

String _fmtDate(DateTime d) {
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
  const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return '${days[d.weekday]}, ${d.day} ${months[d.month]}';
}

({String label, Color color, Color bg, IconData icon}) _claimStatusMeta(
    _ClaimStatus s) {
  switch (s) {
    case _ClaimStatus.draft:
      return (
        label: 'Draft',
        color: _C.textSec,
        bg: _C.surface,
        icon: Icons.edit_outlined
      );
    case _ClaimStatus.submitted:
      return (
        label: 'Submitted',
        color: _C.warningDark,
        bg: _C.warningLight,
        icon: Icons.hourglass_top_rounded
      );
    case _ClaimStatus.approved:
      return (
        label: 'Approved',
        color: _C.primary,
        bg: _C.primaryLight,
        icon: Icons.check_rounded
      );
    case _ClaimStatus.rejected:
      return (
        label: 'Rejected',
        color: _C.errorDark,
        bg: _C.errorLight,
        icon: Icons.cancel_outlined
      );
    case _ClaimStatus.paid:
      return (
        label: 'Paid ✓',
        color: _C.successDark,
        bg: _C.successLight,
        icon: Icons.payments_outlined
      );
  }
}

({String label, IconData icon, Color color, Color bg}) _tripTypeMeta(
    _TripType t) {
  switch (t) {
    case _TripType.officeVisit:
      return (
        label: 'Office Visit',
        icon: Icons.business_outlined,
        color: _C.primary,
        bg: _C.primaryLight
      );
    case _TripType.clientMeeting:
      return (
        label: 'Client Meeting',
        icon: Icons.handshake_outlined,
        color: _C.teal,
        bg: _C.tealLight
      );
    case _TripType.siteVisit:
      return (
        label: 'Site Visit',
        icon: Icons.location_on_outlined,
        color: _C.orange,
        bg: _C.orangeLight
      );
    case _TripType.other:
      return (
        label: 'Other',
        icon: Icons.more_horiz_rounded,
        color: _C.textSec,
        bg: _C.surface
      );
  }
}

({String label, IconData icon}) _transportMeta(_Transport t) {
  switch (t) {
    case _Transport.cab:
      return (label: 'Cab', icon: Icons.local_taxi_rounded);
    case _Transport.auto:
      return (label: 'Auto', icon: Icons.electric_rickshaw_outlined);
    case _Transport.ownVehicle:
      return (label: 'Own Vehicle', icon: Icons.drive_eta_rounded);
    case _Transport.publicTransport:
      return (label: 'Public', icon: Icons.directions_bus_rounded);
    case _Transport.flight:
      return (label: 'Flight', icon: Icons.flight_rounded);
  }
}

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class ConveyanceScreen extends StatefulWidget {
  const ConveyanceScreen({super.key});

  @override
  State<ConveyanceScreen> createState() => _ConveyanceScreenState();
}

class _ConveyanceScreenState extends State<ConveyanceScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  // ── Draft entries for current month ──────────
  final List<_ConveyanceEntry> _draftEntries = [
    _ConveyanceEntry(
      id: 'e1',
      date: _d(2026, 4, 28),
      tripType: _TripType.clientMeeting,
      transport: _Transport.cab,
      fromLocation: 'Wadala HQ',
      toLocation: 'Andheri Client Office',
      amount: 450,
      hasReceipt: true,
      billableToClient: true,
    ),
    _ConveyanceEntry(
      id: 'e2',
      date: _d(2026, 4, 24),
      tripType: _TripType.officeVisit,
      transport: _Transport.ownVehicle,
      fromLocation: 'Home, Dadar',
      toLocation: 'Wadala HQ',
      distanceKm: 12.5,
      amount: 125,
      hasReceipt: false,
    ),
    _ConveyanceEntry(
      id: 'e3',
      date: _d(2026, 4, 22),
      tripType: _TripType.siteVisit,
      transport: _Transport.auto,
      fromLocation: 'Wadala HQ',
      toLocation: 'Kurla Data Center',
      amount: 180,
      hasReceipt: true,
    ),
  ];

  // ── Form state ───────────────────────────────
  DateTime? _formDate;
  _TripType? _tripType;
  _Transport? _transport;
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
  final _distCtrl = TextEditingController();
  final _amtCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _hasReceipt = false;
  bool _billableToClient = false;
  bool _addingEntry = false;
  bool _submitting = false;

  // ── History ──────────────────────────────────
  final List<_ConveyanceClaim> _claimHistory = List.from(_mockPastClaims);

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _distCtrl.addListener(_calcAmountFromDistance);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _fromCtrl.dispose();
    _toCtrl.dispose();
    _distCtrl.dispose();
    _amtCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _calcAmountFromDistance() {
    if (_transport == _Transport.ownVehicle) {
      final km = double.tryParse(_distCtrl.text) ?? 0;
      const rate = 8.0; // ₹8 per km
      setState(() => _amtCtrl.text = (km * rate).toStringAsFixed(0));
    }
  }

  double get _totalDraft => _draftEntries.fold(0.0, (s, e) => s + e.amount);

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

  Future<void> _pickDate() async {
    final p = await showDatePicker(
      context: context,
      initialDate: _formDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
                primary: _C.teal, onPrimary: Colors.white, surface: _C.card)),
        child: child!,
      ),
    );
    if (p != null) setState(() => _formDate = p);
  }

  void _addEntry() {
    if (_formDate == null) {
      _snack('Select a date', _C.error);
      return;
    }
    if (_tripType == null) {
      _snack('Select trip type', _C.error);
      return;
    }
    if (_transport == null) {
      _snack('Select transport mode', _C.error);
      return;
    }
    if (_fromCtrl.text.trim().isEmpty) {
      _snack('Enter from location', _C.error);
      return;
    }
    if (_toCtrl.text.trim().isEmpty) {
      _snack('Enter to location', _C.error);
      return;
    }
    final amount = double.tryParse(_amtCtrl.text);
    if (amount == null || amount <= 0) {
      _snack('Enter a valid amount', _C.error);
      return;
    }

    final entry = _ConveyanceEntry(
      id: 'e${_draftEntries.length + 1}',
      date: _formDate!,
      tripType: _tripType!,
      transport: _transport!,
      fromLocation: _fromCtrl.text.trim(),
      toLocation: _toCtrl.text.trim(),
      distanceKm: double.tryParse(_distCtrl.text),
      amount: amount,
      hasReceipt: _hasReceipt,
      billableToClient: _billableToClient,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );

    setState(() {
      _draftEntries.insert(0, entry);
      _addingEntry = false;
      _formDate = null;
      _tripType = null;
      _transport = null;
      _hasReceipt = false;
      _billableToClient = false;
      for (final c in [_fromCtrl, _toCtrl, _distCtrl, _amtCtrl, _noteCtrl]) {
        c.clear();
      }
    });

    _snack('Entry added — ${_fmtFull(amount)}', _C.successDark);
  }

  void _deleteEntry(String id) {
    setState(() => _draftEntries.removeWhere((e) => e.id == id));
    _snack('Entry removed', _C.textSec);
  }

  Future<void> _submitClaim() async {
    if (_draftEntries.isEmpty) {
      _snack('Add at least one expense entry', _C.error);
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Submit Conveyance Claim?',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _row('Entries', '${_draftEntries.length} trips'),
          _row('Total', _fmtFull(_totalDraft)),
          _row('Month', 'April 2026'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: _C.warningLight,
                borderRadius: BorderRadius.circular(10)),
            child: const Row(children: [
              Icon(Icons.info_outline_rounded, size: 14, color: _C.warningDark),
              SizedBox(width: 6),
              Expanded(
                  child: Text(
                'Ensure receipts are attached for amounts > ₹200. Claim will be reviewed by your manager.',
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
              _doSubmit();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.teal,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Submit Claim'),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
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

  Future<void> _doSubmit() async {
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final newClaim = _ConveyanceClaim(
      id: 'CNV-2026-00${5 + _claimHistory.length}',
      month: 'April 2026',
      entries: List.from(_draftEntries),
      total: _totalDraft,
      status: _ClaimStatus.submitted,
      submittedOn: 'Today',
    );

    setState(() {
      _submitting = false;
      _claimHistory.insert(0, newClaim);
      _draftEntries.clear();
      _tabCtrl.animateTo(1);
    });

    _snack('Conveyance claim ${newClaim.id} submitted ✅', _C.successDark);
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
          children: [_buildDraftTab(), _buildHistoryTab()],
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
        title: const Text('Conveyance',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            color: _C.textSec,
            onPressed: () => _snack('Conveyance summary shared', _C.textSec),
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
  // TAB BAR
  // ─────────────────────────────────────────────
  Widget _buildTabBar() => Container(
        color: _C.card,
        child: TabBar(
          controller: _tabCtrl,
          tabs: const [Tab(text: 'Current Month'), Tab(text: 'Claim History')],
          labelColor: _C.teal,
          unselectedLabelColor: _C.textSec,
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          indicatorColor: _C.teal,
          indicatorWeight: 2.5,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: _C.border,
        ),
      );

  // ─────────────────────────────────────────────
  // TAB 1: DRAFT / CURRENT MONTH
  // ─────────────────────────────────────────────
  Widget _buildDraftTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
      children: [
        _buildSummaryCard(),
        const SizedBox(height: 16),

        // Add entry button or form
        if (!_addingEntry) _buildAddEntryButton() else _buildAddEntryForm(),
        const SizedBox(height: 16),

        // Draft entries list
        if (_draftEntries.isNotEmpty) ...[
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Expense Entries',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary)),
            Text('${_draftEntries.length} trips · ${_fmtFull(_totalDraft)}',
                style: const TextStyle(fontSize: 12, color: _C.textSec)),
          ]),
          const SizedBox(height: 10),
          ..._draftEntries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _EntryCard(
                  entry: e,
                  onDelete: () => _deleteEntry(e.id),
                ),
              )),
          const SizedBox(height: 8),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submitClaim,
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.teal,
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
                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.send_outlined, size: 17),
                      const SizedBox(width: 8),
                      Text('Submit Claim (${_fmtFull(_totalDraft)})',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                    ]),
            ),
          ),
        ] else if (!_addingEntry) ...[
          _EmptyDraft(onAddTap: () => setState(() => _addingEntry = true)),
        ],
      ],
    );
  }

  // ─── Summary card ─────────────────────────────
  Widget _buildSummaryCard() {
    final receiptsCount = _draftEntries.where((e) => e.hasReceipt).length;
    final billableTotal = _draftEntries
        .where((e) => e.billableToClient)
        .fold(0.0, (s, e) => s + e.amount);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D9488), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: _C.teal.withValues(alpha: .3),
              blurRadius: 14,
              offset: const Offset(0, 5))
        ],
      ),
      child: Stack(children: [
        Positioned(
            right: -20,
            top: -20,
            child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: .06)))),
        Padding(
          padding: const EdgeInsets.all(18),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(8)),
                child: const Text('APRIL 2026',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(20)),
                child: Text('${_draftEntries.length} entries',
                    style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500)),
              ),
            ]),
            const SizedBox(height: 14),
            const Text('Total Draft Amount',
                style: TextStyle(fontSize: 12, color: Colors.white60)),
            const SizedBox(height: 2),
            Text(_fmtFull(_totalDraft),
                style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                    height: 1)),
            const SizedBox(height: 14),
            Row(children: [
              _heroStat('${_draftEntries.length}', 'Trips'),
              _heroDivider(),
              _heroStat('$receiptsCount', 'Receipts'),
              _heroDivider(),
              _heroStat(_fmtCurrency(billableTotal), 'Billable'),
              _heroDivider(),
              _heroStat('₹8/km', 'Own Veh.\nRate'),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _heroStat(String val, String lbl) => Expanded(
        child: Column(children: [
          Text(val,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          Text(lbl,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 9, color: Colors.white54, height: 1.3)),
        ]),
      );

  Widget _heroDivider() => Container(
      width: 1,
      height: 30,
      color: Colors.white.withValues(alpha: .2),
      margin: const EdgeInsets.symmetric(horizontal: 4));

  // ─── Add entry button ─────────────────────────
  Widget _buildAddEntryButton() => GestureDetector(
        onTap: () => setState(() => _addingEntry = true),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: _C.tealLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: _C.teal, width: 1.5, style: BorderStyle.solid),
          ),
          child:
              const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.add_circle_outline_rounded, size: 20, color: _C.teal),
            SizedBox(width: 8),
            Text('Add New Expense Entry',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: _C.teal)),
          ]),
        ),
      );

  // ─── Add entry form ───────────────────────────
  Widget _buildAddEntryForm() {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.teal, width: 1.5),
      ),
      child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: const BoxDecoration(
            color: _C.tealLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(19)),
          ),
          child: Row(children: [
            const Icon(Icons.add_circle_outline_rounded,
                size: 18, color: _C.teal),
            const SizedBox(width: 8),
            const Expanded(
                child: Text('Add Expense Entry',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _C.teal))),
            GestureDetector(
              onTap: () => setState(() => _addingEntry = false),
              child: const Icon(Icons.close_rounded, size: 20, color: _C.teal),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Date
            const _FormLabel('Date *'),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: _formDate != null ? _C.tealLight : _C.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: _formDate != null
                          ? _C.teal.withValues(alpha: .5)
                          : _C.border,
                      width: 1.5),
                ),
                child: Row(children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 15,
                      color: _formDate != null ? _C.teal : _C.textTert),
                  const SizedBox(width: 10),
                  Text(
                    _formDate != null ? _fmtDate(_formDate!) : 'Select date',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: _formDate != null
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color:
                            _formDate != null ? _C.textPrimary : _C.textTert),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 12),

            // Trip type
            const _FormLabel('Trip Type *'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: _TripType.values.map((t) {
                final m = _tripTypeMeta(t);
                final active = _tripType == t;
                return GestureDetector(
                  onTap: () => setState(() => _tripType = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? m.color : _C.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: active ? m.color : _C.border, width: 1.5),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(m.icon,
                          size: 12, color: active ? Colors.white : _C.textSec),
                      const SizedBox(width: 5),
                      Text(m.label,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: active ? Colors.white : _C.textSec)),
                    ]),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // From / To
            const _FormLabel('From Location *'),
            const SizedBox(height: 6),
            _textField(_fromCtrl, 'e.g. Wadala HQ', Icons.location_on_outlined),
            const SizedBox(height: 10),
            const _FormLabel('To Location *'),
            const SizedBox(height: 6),
            _textField(
                _toCtrl, 'e.g. Andheri Client Office', Icons.flag_outlined),
            const SizedBox(height: 12),

            // Transport mode
            const _FormLabel('Mode of Transport *'),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _Transport.values.map((t) {
                  final m = _transportMeta(t);
                  final active = _transport == t;
                  return Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _transport = t;
                          _calcAmountFromDistance();
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? _C.teal : _C.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: active ? _C.teal : _C.border, width: 1.5),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(m.icon,
                              size: 13,
                              color: active ? Colors.white : _C.textSec),
                          const SizedBox(width: 5),
                          Text(m.label,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: active ? Colors.white : _C.textSec)),
                        ]),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Distance (own vehicle only)
            if (_transport == _Transport.ownVehicle) ...[
              const _FormLabel('Distance (km)'),
              const SizedBox(height: 6),
              _textField(_distCtrl, 'e.g. 12.5', Icons.straighten_outlined,
                  keyboard: TextInputType.number, suffix: '@ ₹8/km'),
              const SizedBox(height: 12),
            ],

            // Amount
            const _FormLabel('Amount (₹) *'),
            const SizedBox(height: 6),
            TextField(
              controller: _amtCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                  fontSize: 14,
                  color: _C.textPrimary,
                  fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Enter amount',
                hintStyle: const TextStyle(fontSize: 13, color: _C.textTert),
                prefixText: '₹ ',
                prefixStyle: const TextStyle(
                    fontSize: 14, color: _C.teal, fontWeight: FontWeight.w600),
                filled: true,
                fillColor: _C.surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _C.border, width: 1.5)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _C.border, width: 1.5)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _C.teal, width: 1.5)),
              ),
            ),
            const SizedBox(height: 12),

            // Toggles row
            Row(children: [
              Expanded(
                  child: _toggleTile(
                'Has Receipt',
                Icons.receipt_outlined,
                _hasReceipt,
                (v) => setState(() => _hasReceipt = v),
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: _toggleTile(
                'Billable',
                Icons.attach_money_rounded,
                _billableToClient,
                (v) => setState(() => _billableToClient = v),
              )),
            ]),
            const SizedBox(height: 12),

            // Note
            const _FormLabel('Note (optional)'),
            const SizedBox(height: 6),
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              maxLength: 120,
              style: const TextStyle(fontSize: 13, color: _C.textPrimary),
              decoration: InputDecoration(
                hintText: 'Optional details…',
                hintStyle: const TextStyle(fontSize: 13, color: _C.textTert),
                filled: true,
                fillColor: _C.surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                counterStyle: const TextStyle(fontSize: 10, color: _C.textTert),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _C.border, width: 1.5)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _C.border, width: 1.5)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _C.teal, width: 1.5)),
              ),
            ),
            const SizedBox(height: 16),

            // Add button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _addEntry,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Entry',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.teal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _toggleTile(String label, IconData icon, bool value,
          void Function(bool) onChanged) =>
      GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: value ? _C.tealLight : _C.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: value ? _C.teal.withValues(alpha: .4) : _C.border, width: 1.5),
          ),
          child: Row(children: [
            Icon(icon, size: 15, color: value ? _C.teal : _C.textSec),
            const SizedBox(width: 6),
            Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: value ? _C.teal : _C.textSec))),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: value ? _C.teal : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border:
                    Border.all(color: value ? _C.teal : _C.border, width: 1.5),
              ),
              child: value
                  ? const Icon(Icons.check_rounded,
                      size: 11, color: Colors.white)
                  : null,
            ),
          ]),
        ),
      );

  Widget _textField(TextEditingController ctrl, String hint, IconData icon,
          {TextInputType? keyboard, String? suffix}) =>
      TextField(
        controller: ctrl,
        keyboardType: keyboard,
        style: const TextStyle(fontSize: 13, color: _C.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: _C.textTert),
          prefixIcon: Icon(icon, size: 16, color: _C.textSec),
          suffixText: suffix,
          suffixStyle: const TextStyle(fontSize: 11, color: _C.textSec),
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
              borderSide: const BorderSide(color: _C.teal, width: 1.5)),
        ),
      );

  // ─────────────────────────────────────────────
  // TAB 2: CLAIM HISTORY
  // ─────────────────────────────────────────────
  Widget _buildHistoryTab() {
    return _claimHistory.isEmpty
        ? Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    color: _C.tealLight,
                    borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.receipt_long_outlined,
                    size: 36, color: _C.teal)),
            const SizedBox(height: 16),
            const Text('No claims yet',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary)),
          ]))
        : ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 48),
            itemCount: _claimHistory.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _ClaimCard(
              claim: _claimHistory[i],
              onToggle: () => setState(
                  () => _claimHistory[i].expanded = !_claimHistory[i].expanded),
            ),
          );
  }
}

// ─────────────────────────────────────────────
// ENTRY CARD (draft list)
// ─────────────────────────────────────────────
class _EntryCard extends StatelessWidget {
  final _ConveyanceEntry entry;
  final VoidCallback onDelete;

  const _EntryCard({required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final tripMeta = _tripTypeMeta(entry.tripType);
    final transMeta = _transportMeta(entry.transport);

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
            color: _C.errorLight, borderRadius: BorderRadius.circular(14)),
        child:
            const Icon(Icons.delete_outline_rounded, color: _C.error, size: 24),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _C.border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: .04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            // Date box
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                  color: tripMeta.bg, borderRadius: BorderRadius.circular(12)),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${entry.date.day}',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: tripMeta.color,
                            height: 1)),
                    Text(_monthShort(entry.date.month),
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: tripMeta.color.withValues(alpha: .7))),
                  ]),
            ),
            const SizedBox(width: 10),

            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Route
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        size: 11, color: _C.textTert),
                    const SizedBox(width: 3),
                    Expanded(
                        child: Text(
                      '${entry.fromLocation}  →  ${entry.toLocation}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _C.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    )),
                  ]),
                  const SizedBox(height: 4),

                  // Chips
                  Row(children: [
                    _chip(tripMeta.label, tripMeta.color, tripMeta.bg),
                    const SizedBox(width: 5),
                    _chip(transMeta.label, _C.textSec, _C.surface),
                    if (entry.hasReceipt) ...[
                      const SizedBox(width: 5),
                      _chip('Receipt ✓', _C.successDark, _C.successLight),
                    ],
                    if (entry.billableToClient) ...[
                      const SizedBox(width: 5),
                      _chip('Billable', _C.primary, _C.primaryLight),
                    ],
                  ]),
                ])),

            const SizedBox(width: 8),
            Text(_fmtFull(entry.amount),
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w800, color: _C.teal)),
          ]),
        ),
      ),
    );
  }

  Widget _chip(String label, Color color, Color bg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: .2))),
        child: Text(label,
            style: TextStyle(
                fontSize: 9, fontWeight: FontWeight.w600, color: color)),
      );

  String _monthShort(int m) => [
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
      ][m];
}

// ─────────────────────────────────────────────
// CLAIM CARD (history)
// ─────────────────────────────────────────────
class _ClaimCard extends StatelessWidget {
  final _ConveyanceClaim claim;
  final VoidCallback onToggle;

  const _ClaimCard({required this.claim, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final meta = _claimStatusMeta(claim.status);

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: claim.expanded ? meta.color.withValues(alpha: .4) : _C.border,
              width: claim.expanded ? 1.5 : 1),
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
              Row(children: [
                Text(claim.id,
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
                  turns: claim.expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 18, color: _C.textTert),
                ),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Text(claim.month,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _C.textPrimary)),
                const Spacer(),
                Text(_fmtFull(claim.total),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _C.teal)),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 11, color: _C.textTert),
                const SizedBox(width: 4),
                Text('Submitted: ${claim.submittedOn}',
                    style: const TextStyle(fontSize: 10, color: _C.textTert)),
                if (claim.approvedOn != null) ...[
                  const SizedBox(width: 10),
                  const Icon(Icons.check_circle_outline_rounded,
                      size: 11, color: _C.textTert),
                  const SizedBox(width: 4),
                  Text('Approved: ${claim.approvedOn}',
                      style: const TextStyle(fontSize: 10, color: _C.textTert)),
                ],
              ]),
            ]),
          ),
          if (claim.expanded) ...[
            Container(
                height: 1,
                color: _C.border,
                margin: const EdgeInsets.symmetric(horizontal: 14)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (claim.managerComment != null)
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
                              const SizedBox(height: 5),
                              Text(claim.managerComment!,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: _C.textPrimary,
                                      height: 1.4)),
                            ]),
                      ),
                  ]),
            ),
          ],
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// EMPTY DRAFT STATE
// ─────────────────────────────────────────────
class _EmptyDraft extends StatelessWidget {
  final VoidCallback onAddTap;
  const _EmptyDraft({required this.onAddTap});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: _C.tealLight, borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.receipt_long_outlined,
                  size: 36, color: _C.teal)),
          const SizedBox(height: 16),
          const Text('No expenses added yet',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary)),
          const SizedBox(height: 6),
          const Text('Add your conveyance expenses for this month.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _C.textSec, height: 1.5)),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onAddTap,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add First Entry',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: _C.teal,
              side: const BorderSide(color: _C.teal, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ]),
      );
}

// ─────────────────────────────────────────────
// SHARED
// ─────────────────────────────────────────────
class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600, color: _C.textPrimary));
}

DateTime _d(int y, int m, int d) => DateTime(y, m, d);
