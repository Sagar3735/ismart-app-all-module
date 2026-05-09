// ============================================================
// ISF HR Portal — Tour Request Screen
// File: lib/screens/attendance/tour_request_screen.dart
//
// Features:
//   - Tab 1: New Request form
//       • Tour type chips (Local / Outstation / International)
//       • From/To location fields
//       • Departure & Return date pickers
//       • Purpose multiline field
//       • Mode of transport chip selector (with icons)
//       • Estimated budget field
//       • Accommodation toggle (with hotel preference)
//       • Advance required toggle
//       • Supporting doc attachment
//       • Animated submit with snackbar
//   - Tab 2: My Requests history
//       • Status filter chips
//       • Expandable request cards
//       • Expense claim CTA for completed tours
//       • Cancel draft option
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
  static const warningLight = Color(0xFFFEF9C3);
  static const warningDark = Color(0xFFCA8A04);
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFEF2F2);
  static const errorDark = Color(0xFFDC2626);
  static const teal = Color(0xFF0D9488);
  static const tealLight = Color(0xFFF0FDFA);
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
enum _TourType { local, outstation, international }

enum _Transport { flight, train, bus, selfDrive, cab }

enum _Hotel { budget, standard, business }

enum _TourStatus { draft, submitted, approved, rejected, completed }

class _TourRequest {
  final String id;
  final _TourType type;
  final String fromLocation;
  final String toLocation;
  final DateTime departureDate;
  final DateTime returnDate;
  final String purpose;
  final _Transport transport;
  final double? estimatedBudget;
  final bool needsAccommodation;
  final _Hotel? hotelPref;
  final bool needsAdvance;
  final double? advanceAmount;
  final _TourStatus status;
  final String appliedOn;
  final String? managerComment;
  bool expanded = false;

  _TourRequest({
    required this.id,
    required this.type,
    required this.fromLocation,
    required this.toLocation,
    required this.departureDate,
    required this.returnDate,
    required this.purpose,
    required this.transport,
    this.estimatedBudget,
    required this.needsAccommodation,
    this.hotelPref,
    required this.needsAdvance,
    this.advanceAmount,
    required this.status,
    required this.appliedOn,
    this.managerComment,
  });

  int get tripDays => returnDate.difference(departureDate).inDays + 1;
}

// ─────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────
final _mockRequests = [
  _TourRequest(
    id: 'TRV-2026-008',
    type: _TourType.outstation,
    fromLocation: 'Mumbai HQ',
    toLocation: 'Pune Client Office',
    departureDate: DateTime(2026, 5, 12),
    returnDate: DateTime(2026, 5, 13),
    purpose:
        'Client presentation for Q2 project deliverables and requirements gathering for Phase 2.',
    transport: _Transport.train,
    estimatedBudget: 8000,
    needsAccommodation: true,
    hotelPref: _Hotel.standard,
    needsAdvance: true,
    advanceAmount: 5000,
    status: _TourStatus.approved,
    appliedOn: '28 Apr 2026',
    managerComment: 'Approved. Book via Cleartrip corporate account.',
  ),
  _TourRequest(
    id: 'TRV-2026-005',
    type: _TourType.local,
    fromLocation: 'Mumbai HQ',
    toLocation: 'Andheri Data Center',
    departureDate: DateTime(2026, 4, 20),
    returnDate: DateTime(2026, 4, 20),
    purpose: 'Production server maintenance and infrastructure audit.',
    transport: _Transport.cab,
    estimatedBudget: 1200,
    needsAccommodation: false,
    needsAdvance: false,
    status: _TourStatus.completed,
    appliedOn: '18 Apr 2026',
    managerComment: 'Approved. Claim expenses with receipts.',
  ),
  _TourRequest(
    id: 'TRV-2026-011',
    type: _TourType.outstation,
    fromLocation: 'Mumbai HQ',
    toLocation: 'Bengaluru Tech Summit',
    departureDate: DateTime(2026, 6, 3),
    returnDate: DateTime(2026, 6, 5),
    purpose: 'Attending TechSummit India 2026 for learning and networking.',
    transport: _Transport.flight,
    estimatedBudget: 25000,
    needsAccommodation: true,
    hotelPref: _Hotel.business,
    needsAdvance: true,
    advanceAmount: 15000,
    status: _TourStatus.submitted,
    appliedOn: '02 May 2026',
  ),
  _TourRequest(
    id: 'TRV-2026-003',
    type: _TourType.international,
    fromLocation: 'Mumbai',
    toLocation: 'Singapore — ISF Asia HQ',
    departureDate: DateTime(2026, 3, 10),
    returnDate: DateTime(2026, 3, 13),
    purpose: 'Cross-functional team sync with ISF Asia technical leadership.',
    transport: _Transport.flight,
    estimatedBudget: 120000,
    needsAccommodation: true,
    hotelPref: _Hotel.business,
    needsAdvance: true,
    advanceAmount: 80000,
    status: _TourStatus.rejected,
    appliedOn: '25 Feb 2026',
    managerComment:
        'Budget not approved for Q1. Reschedule to Q3 after budget review.',
  ),
];

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────
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
  return '${d.day} ${months[d.month]} ${d.year}';
}

String _fmtDateShort(DateTime d) {
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
  return '${d.day} ${months[d.month]}';
}

String _fmtCurrency(double v) {
  if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
  if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(0)}K';
  return '₹${v.toStringAsFixed(0)}';
}

({String label, Color color, Color bg, IconData icon}) _tourTypeMeta(
    _TourType t) {
  switch (t) {
    case _TourType.local:
      return (
        label: 'Local',
        color: _C.teal,
        bg: _C.tealLight,
        icon: Icons.location_city_outlined
      );
    case _TourType.outstation:
      return (
        label: 'Outstation',
        color: _C.primary,
        bg: _C.primaryLight,
        icon: Icons.train_outlined
      );
    case _TourType.international:
      return (
        label: 'International',
        color: _C.purple,
        bg: _C.purpleLight,
        icon: Icons.flight_outlined
      );
  }
}

({String label, Color color, Color bg, IconData icon}) _statusMeta(
    _TourStatus s) {
  switch (s) {
    case _TourStatus.draft:
      return (
        label: 'Draft',
        color: _C.textSec,
        bg: _C.surface,
        icon: Icons.edit_outlined
      );
    case _TourStatus.submitted:
      return (
        label: 'Submitted',
        color: _C.warningDark,
        bg: _C.warningLight,
        icon: Icons.hourglass_top_rounded
      );
    case _TourStatus.approved:
      return (
        label: 'Approved',
        color: _C.successDark,
        bg: _C.successLight,
        icon: Icons.check_circle_outline_rounded
      );
    case _TourStatus.rejected:
      return (
        label: 'Rejected',
        color: _C.errorDark,
        bg: _C.errorLight,
        icon: Icons.cancel_outlined
      );
    case _TourStatus.completed:
      return (
        label: 'Completed',
        color: _C.primary,
        bg: _C.primaryLight,
        icon: Icons.verified_outlined
      );
  }
}

({String label, IconData icon}) _transportMeta(_Transport t) {
  switch (t) {
    case _Transport.flight:
      return (label: 'Flight', icon: Icons.flight_rounded);
    case _Transport.train:
      return (label: 'Train', icon: Icons.train_rounded);
    case _Transport.bus:
      return (label: 'Bus', icon: Icons.directions_bus_rounded);
    case _Transport.selfDrive:
      return (label: 'Self-Drive', icon: Icons.drive_eta_rounded);
    case _Transport.cab:
      return (label: 'Cab', icon: Icons.local_taxi_rounded);
  }
}

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class TourRequestScreen extends StatefulWidget {
  const TourRequestScreen({super.key});

  @override
  State<TourRequestScreen> createState() => _TourRequestScreenState();
}

class _TourRequestScreenState extends State<TourRequestScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  // ── Form state ──────────────────────────────
  _TourType? _tourType;
  _Transport? _transport;
  _Hotel? _hotelPref = _Hotel.standard;
  bool _needsAccom = false;
  bool _needsAdvance = false;
  bool _hasDoc = false;
  bool _submitting = false;

  DateTime? _departureDate;
  DateTime? _returnDate;

  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _advanceCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // ── History state ───────────────────────────
  _TourStatus? _filterStatus;
  final List<_TourRequest> _requests = List.from(_mockRequests);

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _fromCtrl.dispose();
    _toCtrl.dispose();
    _purposeCtrl.dispose();
    _budgetCtrl.dispose();
    _advanceCtrl.dispose();
    super.dispose();
  }

  // ── Date pickers ─────────────────────────────
  Future<void> _pickDeparture() async {
    final p = await showDatePicker(
      context: context,
      initialDate:
          _departureDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: _datePkrTheme,
    );
    if (p != null) {
      setState(() {
        _departureDate = p;
        if (_returnDate != null && _returnDate!.isBefore(p)) _returnDate = p;
      });
    }
  }

  Future<void> _pickReturn() async {
    final p = await showDatePicker(
      context: context,
      initialDate: _returnDate ??
          _departureDate ??
          DateTime.now().add(const Duration(days: 1)),
      firstDate: _departureDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: _datePkrTheme,
    );
    if (p != null) setState(() => _returnDate = p);
  }

  Widget Function(BuildContext, Widget?) get _datePkrTheme =>
      (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(
                primary: _C.teal,
                onPrimary: Colors.white,
                surface: _C.card,
              ),
            ),
            child: child!,
          );

  // ── Submit ───────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tourType == null) {
      _snack('Select tour type', _C.error);
      return;
    }
    if (_transport == null) {
      _snack('Select transport mode', _C.error);
      return;
    }
    if (_departureDate == null) {
      _snack('Select departure date', _C.error);
      return;
    }
    if (_returnDate == null) {
      _snack('Select return date', _C.error);
      return;
    }

    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final reqId = 'TRV-2026-0${15 + _requests.length}';
    setState(() {
      _requests.insert(
          0,
          _TourRequest(
            id: reqId,
            type: _tourType!,
            fromLocation: _fromCtrl.text.trim(),
            toLocation: _toCtrl.text.trim(),
            departureDate: _departureDate!,
            returnDate: _returnDate!,
            purpose: _purposeCtrl.text.trim(),
            transport: _transport!,
            estimatedBudget: double.tryParse(_budgetCtrl.text),
            needsAccommodation: _needsAccom,
            hotelPref: _needsAccom ? _hotelPref : null,
            needsAdvance: _needsAdvance,
            advanceAmount:
                _needsAdvance ? double.tryParse(_advanceCtrl.text) : null,
            status: _TourStatus.submitted,
            appliedOn: _fmtDate(DateTime.now()),
          ));
      _submitting = false;
    });

    _resetForm();
    _snack('Tour Request $reqId submitted ✅', _C.successDark);
    _tabCtrl.animateTo(1);
  }

  void _resetForm() {
    _tourType = null;
    _transport = null;
    _hotelPref = _Hotel.standard;
    _needsAccom = false;
    _needsAdvance = false;
    _hasDoc = false;
    _departureDate = null;
    _returnDate = null;
    for (final c in [
      _fromCtrl,
      _toCtrl,
      _purposeCtrl,
      _budgetCtrl,
      _advanceCtrl
    ]) {
      c.clear();
    }
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
              _buildFormTab(),
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
        title: const Text('Tour Request',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _C.tealLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.map_outlined, size: 13, color: _C.teal),
              const SizedBox(width: 4),
              Text('${_requests.length} Tours',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _C.teal)),
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
  Widget _buildTabBar() => Container(
        color: _C.card,
        child: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(text: 'New Request'),
            Tab(text: 'My Requests'),
          ],
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
  // TAB 1: FORM
  // ─────────────────────────────────────────────
  Widget _buildFormTab() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
        children: [
          // Info banner
          const _InfoBanner(
            'Tour requests must be submitted at least 3 working days in advance.',
            Icons.info_outline_rounded,
            _C.teal,
            _C.tealLight,
          ),
          const SizedBox(height: 16),

          _formCard(),
        ],
      ),
    );
  }

  Widget _formCard() {
    final tripDays = (_departureDate != null && _returnDate != null)
        ? _returnDate!.difference(_departureDate!).inDays + 1
        : 0;

    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Column(children: [
        const _CardHeader(
            'Tour Details',
            Icons.map_outlined,
            _C.teal,
            _C.tealLight),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Tour type ─────────────────────
              const _FieldLabel('Tour Type *'),
              const SizedBox(height: 8),
              Row(
                  children: _TourType.values.map((t) {
                final meta = _tourTypeMeta(t);
                final active = _tourType == t;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: t != _TourType.international ? 8 : 0),
                    child: GestureDetector(
                      onTap: () => setState(() => _tourType = t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        height: 56,
                        decoration: BoxDecoration(
                          color: active ? meta.color : _C.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: active ? meta.color : _C.border,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(meta.icon,
                                size: 18,
                                color: active ? Colors.white : _C.textSec),
                            const SizedBox(height: 3),
                            Text(meta.label,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: active ? Colors.white : _C.textSec)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList()),
              const SizedBox(height: 16),

              // ── Locations ─────────────────────
              const _FieldLabel('From Location *'),
              const SizedBox(height: 8),
              _textField(
                ctrl: _fromCtrl,
                hint: 'e.g. Mumbai HQ',
                icon: Icons.location_on_outlined,
                iconColor: _C.teal,
                validator: (v) => v!.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              const _FieldLabel('To Location *'),
              const SizedBox(height: 8),
              _textField(
                ctrl: _toCtrl,
                hint: 'e.g. Pune Client Office',
                icon: Icons.flag_outlined,
                iconColor: _C.teal,
                validator: (v) => v!.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // ── Dates ─────────────────────────
              const _FieldLabel('Travel Dates *'),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                    child: _DatePickerField(
                  label: 'Departure',
                  value: _departureDate,
                  onTap: _pickDeparture,
                  color: _C.teal,
                )),
                const SizedBox(width: 10),
                Expanded(
                    child: _DatePickerField(
                  label: 'Return',
                  value: _returnDate,
                  onTap: _returnDate != null || _departureDate != null
                      ? _pickReturn
                      : null,
                  color: _C.teal,
                  enabled: _departureDate != null,
                )),
              ]),
              if (tripDays > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _C.tealLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _C.teal.withValues(alpha: .3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.event_note_outlined,
                        size: 15, color: _C.teal),
                    const SizedBox(width: 8),
                    Text(
                      'Trip Duration: $tripDays day${tripDays != 1 ? "s" : ""}  ·  '
                      '${_fmtDateShort(_departureDate!)} – ${_fmtDateShort(_returnDate!)}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _C.teal),
                    ),
                  ]),
                ),
              ],
              const SizedBox(height: 16),

              // ── Purpose ───────────────────────
              const _FieldLabel('Purpose of Visit *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _purposeCtrl,
                maxLines: 3,
                maxLength: 300,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (v.trim().length < 10) return 'Min 10 characters';
                  return null;
                },
                style: const TextStyle(fontSize: 13, color: _C.textPrimary),
                decoration: _inputDeco('Describe the purpose of this tour…'),
              ),
              const SizedBox(height: 16),

              // ── Transport ─────────────────────
              const _FieldLabel('Mode of Transport *'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _Transport.values.map((t) {
                  final meta = _transportMeta(t);
                  final active = _transport == t;
                  return GestureDetector(
                    onTap: () => setState(() => _transport = t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: active ? _C.teal : _C.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active ? _C.teal : _C.border,
                          width: 1.5,
                        ),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(meta.icon,
                            size: 14,
                            color: active ? Colors.white : _C.textSec),
                        const SizedBox(width: 6),
                        Text(meta.label,
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

              // ── Budget ────────────────────────
              const _FieldLabel('Estimated Budget (₹)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _budgetCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontSize: 14, color: _C.textPrimary),
                decoration: _inputDeco('e.g. 15000').copyWith(
                  prefixText: '₹ ',
                  prefixStyle: const TextStyle(
                      fontSize: 14,
                      color: _C.textSec,
                      fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 16),

              // ── Accommodation toggle ───────────
              _ToggleSection(
                title: 'Accommodation Required?',
                subtitle: 'Hotel stay during the tour',
                icon: Icons.hotel_outlined,
                value: _needsAccom,
                color: _C.teal,
                onChanged: (v) => setState(() => _needsAccom = v),
                child: _needsAccom
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          const Text('Hotel Preference',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _C.textPrimary)),
                          const SizedBox(height: 8),
                          Row(
                              children: _Hotel.values.map((h) {
                            final active = _hotelPref == h;
                            final label = h == _Hotel.budget
                                ? 'Budget'
                                : h == _Hotel.standard
                                    ? 'Standard'
                                    : 'Business';
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    right: h != _Hotel.business ? 8 : 0),
                                child: GestureDetector(
                                  onTap: () => setState(() => _hotelPref = h),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: active ? _C.teal : _C.card,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: active ? _C.teal : _C.border,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(label,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: active
                                                  ? Colors.white
                                                  : _C.textSec)),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList()),
                        ],
                      )
                    : null,
              ),
              const SizedBox(height: 12),

              // ── Advance toggle ─────────────────
              _ToggleSection(
                title: 'Advance Required?',
                subtitle: 'Request travel advance payment',
                icon: Icons.account_balance_wallet_outlined,
                value: _needsAdvance,
                color: _C.teal,
                onChanged: (v) => setState(() => _needsAdvance = v),
                child: _needsAdvance
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _advanceCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            style: const TextStyle(
                                fontSize: 14, color: _C.textPrimary),
                            decoration: _inputDeco('Advance amount').copyWith(
                              prefixText: '₹ ',
                              prefixStyle: const TextStyle(
                                  fontSize: 14,
                                  color: _C.textSec,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
              const SizedBox(height: 12),

              // ── Attachment ────────────────────
              GestureDetector(
                onTap: () => setState(() => _hasDoc = !_hasDoc),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _hasDoc ? _C.successLight : _C.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _hasDoc ? _C.success.withValues(alpha: .4) : _C.border,
                      width: _hasDoc ? 1.5 : 1,
                    ),
                  ),
                  child: Row(children: [
                    Icon(
                      _hasDoc
                          ? Icons.check_circle_outline_rounded
                          : Icons.attach_file_rounded,
                      size: 20,
                      color: _hasDoc ? _C.successDark : _C.textSec,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _hasDoc
                            ? 'client_invitation.pdf attached'
                            : 'Attach supporting document (optional)',
                        style: TextStyle(
                            fontSize: 13,
                            color: _hasDoc ? _C.successDark : _C.textSec),
                      ),
                    ),
                    if (_hasDoc)
                      GestureDetector(
                        onTap: () => setState(() => _hasDoc = false),
                        child: const Icon(Icons.close_rounded,
                            size: 16, color: _C.textSec),
                      ),
                  ]),
                ),
              ),
              const SizedBox(height: 24),

              // ── Submit ────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
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
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_outlined, size: 17),
                            SizedBox(width: 8),
                            Text('Submit Request',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton(
                  onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _C.textSec,
                    side: const BorderSide(color: _C.border, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancel',
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

  // ─────────────────────────────────────────────
  // TAB 2: HISTORY
  // ─────────────────────────────────────────────
  Widget _buildHistoryTab() {
    final filtered = _filterStatus == null
        ? _requests
        : _requests.where((r) => r.status == _filterStatus).toList();

    return Column(children: [
      // Filter row
      Container(
        color: _C.card,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _filterChip('All', _filterStatus == null,
                () => setState(() => _filterStatus = null)),
            ..._TourStatus.values.map((s) {
              final m = _statusMeta(s);
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _filterChip(
                  m.label,
                  _filterStatus == s,
                  () => setState(() => _filterStatus = s),
                ),
              );
            }),
          ]),
        ),
      ),
      Container(height: 1, color: _C.border),

      // List
      Expanded(
        child: filtered.isEmpty
            ? _EmptyState()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 48),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _RequestCard(
                  request: filtered[i],
                  onToggle: () => setState(
                      () => filtered[i].expanded = !filtered[i].expanded),
                  onClaim: filtered[i].status == _TourStatus.completed
                      ? () => _showExpenseClaim(filtered[i])
                      : null,
                  onCancel: filtered[i].status == _TourStatus.draft ||
                          filtered[i].status == _TourStatus.submitted
                      ? () => _cancelRequest(filtered[i])
                      : null,
                ),
              ),
      ),
    ]);
  }

  Widget _filterChip(String label, bool active, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: active ? _C.teal : _C.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: active ? _C.teal : _C.border),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : _C.textSec)),
        ),
      );

  void _showExpenseClaim(_TourRequest req) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ExpenseClaimSheet(
        request: req,
        onSubmit: () {
          Navigator.pop(context);
          _snack('Expense claim submitted ✅', _C.successDark);
        },
      ),
    );
  }

  void _cancelRequest(_TourRequest req) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Request?',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        content: Text('Cancel tour request ${req.id}?',
            style: const TextStyle(fontSize: 14, color: _C.textSec)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Keep', style: TextStyle(color: _C.textSec))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _requests.removeWhere((r) => r.id == req.id));
              _snack('Request ${req.id} cancelled', _C.textSec);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // ── Shared form helpers ────────────────────
  Widget _textField({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    Color iconColor = _C.teal,
    String? Function(String?)? validator,
    TextInputType? keyboard,
  }) =>
      TextFormField(
        controller: ctrl,
        validator: validator,
        keyboardType: keyboard,
        style: const TextStyle(fontSize: 14, color: _C.textPrimary),
        decoration: _inputDeco(hint).copyWith(
          prefixIcon: Icon(icon, size: 18, color: iconColor),
        ),
      );

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
            borderSide: const BorderSide(color: _C.teal, width: 1.5)),
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
// DATE PICKER FIELD
// ─────────────────────────────────────────────
class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback? onTap;
  final Color color;
  final bool enabled;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
    required this.color,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: enabled ? _C.surface : _C.surface.withValues(alpha: .5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value != null ? color.withValues(alpha: .5) : _C.border,
            width: value != null ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 10, color: _C.textSec)),
            const SizedBox(height: 3),
            Row(children: [
              Icon(Icons.calendar_today_outlined,
                  size: 13, color: value != null ? color : _C.textTert),
              const SizedBox(width: 5),
              Text(
                value != null ? _fmtDate(value!) : 'Pick date',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        value != null ? FontWeight.w600 : FontWeight.w400,
                    color: value != null ? _C.textPrimary : _C.textTert),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TOGGLE SECTION
// ─────────────────────────────────────────────
class _ToggleSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final Color color;
  final void Function(bool) onChanged;
  final Widget? child;

  const _ToggleSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.color,
    required this.onChanged,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: value ? color.withValues(alpha: .06) : _C.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? color.withValues(alpha: .3) : _C.border,
          width: value ? 1.5 : 1,
        ),
      ),
      child: Column(children: [
        Row(children: [
          Icon(icon, size: 18, color: value ? color : _C.textSec),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: value ? color : _C.textPrimary)),
              Text(subtitle,
                  style: const TextStyle(fontSize: 11, color: _C.textSec)),
            ],
          )),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: color,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ]),
        if (child != null) child!,
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// REQUEST CARD (history)
// ─────────────────────────────────────────────
class _RequestCard extends StatelessWidget {
  final _TourRequest request;
  final VoidCallback onToggle;
  final VoidCallback? onClaim;
  final VoidCallback? onCancel;

  const _RequestCard({
    required this.request,
    required this.onToggle,
    this.onClaim,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final typeMeta = _tourTypeMeta(request.type);
    final statusMeta = _statusMeta(request.status);
    final transMeta = _transportMeta(request.transport);

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                request.expanded ? typeMeta.color.withValues(alpha: .4) : _C.border,
            width: request.expanded ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: .04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
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
                        color: statusMeta.bg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: statusMeta.color.withValues(alpha: .3))),
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
                    turns: request.expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 18, color: _C.textTert),
                  ),
                ]),
                const SizedBox(height: 10),

                // Route row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: typeMeta.bg,
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(typeMeta.icon, size: 11, color: typeMeta.color),
                        const SizedBox(width: 4),
                        Text(typeMeta.label,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: typeMeta.color)),
                      ]),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: _C.textTert),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        '${request.fromLocation}  →  ${request.toLocation}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _C.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Dates + duration
                Row(children: [
                  const Icon(Icons.calendar_month_outlined,
                      size: 13, color: _C.textSec),
                  const SizedBox(width: 4),
                  Text(
                    '${_fmtDate(request.departureDate)} – ${_fmtDate(request.returnDate)}',
                    style: const TextStyle(fontSize: 12, color: _C.textSec),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: _C.surface,
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      '${request.tripDays}d',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _C.textPrimary),
                    ),
                  ),
                ]),
                const SizedBox(height: 6),

                // Transport + budget
                Row(children: [
                  Icon(transMeta.icon, size: 13, color: _C.textSec),
                  const SizedBox(width: 4),
                  Text(transMeta.label,
                      style: const TextStyle(fontSize: 11, color: _C.textSec)),
                  if (request.estimatedBudget != null) ...[
                    const SizedBox(width: 10),
                    const Icon(Icons.account_balance_wallet_outlined,
                        size: 13, color: _C.textSec),
                    const SizedBox(width: 4),
                    Text(
                      _fmtCurrency(request.estimatedBudget!),
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _C.textSec),
                    ),
                  ],
                  if (request.needsAccommodation) ...[
                    const SizedBox(width: 10),
                    const Icon(Icons.hotel_outlined,
                        size: 13, color: _C.textSec),
                    const SizedBox(width: 3),
                    Text(
                      request.hotelPref == _Hotel.budget
                          ? 'Budget'
                          : request.hotelPref == _Hotel.standard
                              ? 'Standard'
                              : 'Business',
                      style: const TextStyle(fontSize: 11, color: _C.textSec),
                    ),
                  ],
                ]),
              ],
            ),
          ),

          // ── Expanded ──────────────────────────
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
                  _detailRow('Purpose', request.purpose),
                  if (request.needsAdvance && request.advanceAmount != null)
                    _detailRow('Advance', _fmtCurrency(request.advanceAmount!)),
                  _detailRow('Applied On', request.appliedOn),

                  if (request.managerComment != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusMeta.bg,
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: statusMeta.color.withValues(alpha: .2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(Icons.comment_outlined,
                                size: 13, color: statusMeta.color),
                            const SizedBox(width: 5),
                            Text('Manager Comment',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: statusMeta.color)),
                          ]),
                          const SizedBox(height: 5),
                          Text(request.managerComment!,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: _C.textPrimary,
                                  height: 1.4)),
                        ],
                      ),
                    ),
                  ],

                  // Action buttons
                  if (onClaim != null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: onClaim,
                        icon: const Icon(Icons.receipt_long_outlined, size: 17),
                        label: const Text('Claim Expenses',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _C.teal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                  if (onCancel != null) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _C.error,
                          side: const BorderSide(color: _C.error, width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Cancel Request',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
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

  Widget _detailRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
              child: Text(label,
                  style: const TextStyle(fontSize: 11, color: _C.textSec)),
            ),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _C.textPrimary,
                      height: 1.4)),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────
// EXPENSE CLAIM SHEET
// ─────────────────────────────────────────────
class _ExpenseClaimSheet extends StatefulWidget {
  final _TourRequest request;
  final VoidCallback onSubmit;

  const _ExpenseClaimSheet({required this.request, required this.onSubmit});

  @override
  State<_ExpenseClaimSheet> createState() => _ExpenseClaimSheetState();
}

class _ExpenseClaimSheetState extends State<_ExpenseClaimSheet> {
  bool _submitting = false;

  final _items = [
    {'label': 'Travel (Train/Cab)', 'amount': TextEditingController()},
    {'label': 'Accommodation', 'amount': TextEditingController()},
    {'label': 'Food & Per Diem', 'amount': TextEditingController()},
    {'label': 'Miscellaneous', 'amount': TextEditingController()},
  ];

  double get _total => _items.fold(0.0, (sum, item) {
        final v =
            double.tryParse((item['amount'] as TextEditingController).text);
        return sum + (v ?? 0);
      });

  @override
  void dispose() {
    for (final item in _items) {
      (item['amount'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, 32 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: _C.border,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 18),

            // Header
            const Text('Claim Expenses',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary)),
            Text(
                '${widget.request.id} · ${widget.request.fromLocation} → ${widget.request.toLocation}',
                style: const TextStyle(fontSize: 12, color: _C.textSec)),
            const SizedBox(height: 16),

            // Expense rows
            ..._items.asMap().entries.map((e) {
              final item = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  Expanded(
                    flex: 2,
                    child: Text(item['label'] as String,
                        style: const TextStyle(
                            fontSize: 13,
                            color: _C.textPrimary,
                            fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatefulBuilder(
                      builder: (_, setSt) => TextField(
                        controller: item['amount'] as TextEditingController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(
                            fontSize: 14, color: _C.textPrimary),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: const TextStyle(color: _C.textTert),
                          prefixText: '₹ ',
                          prefixStyle: const TextStyle(
                              fontSize: 13,
                              color: _C.textSec,
                              fontWeight: FontWeight.w500),
                          filled: true,
                          fillColor: _C.surface,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
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
                              borderSide:
                                  const BorderSide(color: _C.teal, width: 1.5)),
                        ),
                      ),
                    ),
                  ),
                ]),
              );
            }),

            const Divider(color: _C.border, thickness: 1),
            const SizedBox(height: 8),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Claim',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _C.textPrimary)),
                Text('₹ ${_total.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _C.teal)),
              ],
            ),
            const SizedBox(height: 20),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitting
                    ? null
                    : () async {
                        setState(() => _submitting = true);
                        await Future.delayed(
                            const Duration(milliseconds: 1300));
                        if (mounted) widget.onSubmit();
                      },
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
                    : const Text('Submit Expense Claim',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED SMALL WIDGETS
// ─────────────────────────────────────────────
class _InfoBanner extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color;
  final Color bg;

  const _InfoBanner(this.message, this.icon, this.color, this.bg);

  @override
  Widget build(BuildContext context) => Container(
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

class _CardHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Color bg;

  const _CardHeader(this.title, this.icon, this.color, this.bg);

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

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: _C.textPrimary));
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    color: _C.tealLight,
                    borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.map_outlined, size: 36, color: _C.teal),
              ),
              const SizedBox(height: 16),
              const Text('No tour requests',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary)),
              const SizedBox(height: 6),
              const Text('Submit a new tour request to see it here.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 13, color: _C.textSec, height: 1.5)),
            ],
          ),
        ),
      );
}
