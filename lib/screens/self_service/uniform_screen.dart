// ============================================================
// ISF HR Portal — Uniform Size Screen
// File: lib/screens/self_service/uniform_screen.dart
//
// Features:
//   - Current uniform summary card (clothing & accessories)
//   - Size measurement guide with visual reference
//   - Uniform type selector (Shirt/T-Shirt/Trouser/Jacket/Shoes)
//   - Size picker per category (grid selector)
//   - Fit preference toggle (Regular / Slim / Relaxed)
//   - Submit size update form
//   - Uniform request history
//   - Dispatch / collection status tracker
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
  static const accent = Color(0xFF6366F1);
  static const accentLight = Color(0xFFEEF2FF);
  static const success = Color(0xFF22C55E);
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
enum _FitPref { regular, slim, relaxed }

enum _RequestStatus { pending, processing, dispatched, collected, rejected }

class _UniformItem {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final Color bg;
  final List<String> sizes;
  String? selectedSize;

  _UniformItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.bg,
    required this.sizes,
    this.selectedSize,
  });
}

class _UniformRequest {
  final String id;
  final String requestedOn;
  final List<String> items;
  final _RequestStatus status;
  final String? expectedDate;
  final String? trackingNote;
  bool expanded = false;

  _UniformRequest({
    required this.id,
    required this.requestedOn,
    required this.items,
    required this.status,
    this.expectedDate,
    this.trackingNote,
  });
}

// ─────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────
final _uniformItems = [
  _UniformItem(
    id: 'shirt',
    name: 'Formal Shirt',
    icon: Icons.dry_cleaning_outlined,
    color: _C.primary,
    bg: _C.primaryLight,
    sizes: ['XS', 'S', 'M', 'L', 'XL', 'XXL', '3XL'],
    selectedSize: 'L',
  ),
  _UniformItem(
    id: 'tshirt',
    name: 'T-Shirt',
    icon: Icons.style_outlined,
    color: _C.teal,
    bg: _C.tealLight,
    sizes: ['XS', 'S', 'M', 'L', 'XL', 'XXL', '3XL'],
    selectedSize: 'L',
  ),
  _UniformItem(
    id: 'trouser',
    name: 'Trouser',
    icon: Icons.accessibility_outlined,
    color: _C.accent,
    bg: _C.accentLight,
    sizes: ['28', '30', '32', '34', '36', '38', '40', '42'],
    selectedSize: '32',
  ),
  _UniformItem(
    id: 'jacket',
    name: 'Jacket / Blazer',
    icon: Icons.local_laundry_service_outlined,
    color: _C.purple,
    bg: _C.purpleLight,
    sizes: ['XS', 'S', 'M', 'L', 'XL', 'XXL'],
    selectedSize: 'L',
  ),
  _UniformItem(
    id: 'shoes',
    name: 'Safety Shoes',
    icon: Icons.directions_walk_outlined,
    color: _C.orange,
    bg: _C.orangeLight,
    sizes: ['6', '7', '8', '9', '10', '11', '12'],
    selectedSize: '9',
  ),
];

final _mockHistory = [
  _UniformRequest(
    id: 'UNI-2026-003',
    requestedOn: '28 Apr 2026',
    items: ['Formal Shirt – L', 'T-Shirt – L', 'Trouser – 32'],
    status: _RequestStatus.dispatched,
    expectedDate: '08 May 2026',
    trackingNote: 'Dispatched via Blue Dart · AWB: BD123456789IN',
  ),
  _UniformRequest(
    id: 'UNI-2025-011',
    requestedOn: '15 Nov 2025',
    items: ['Jacket – L', 'Safety Shoes – 9'],
    status: _RequestStatus.collected,
    expectedDate: '22 Nov 2025',
    trackingNote: 'Collected from Admin Desk on 22 Nov 2025.',
  ),
  _UniformRequest(
    id: 'UNI-2024-005',
    requestedOn: '01 Apr 2024',
    items: ['Formal Shirt – M', 'Trouser – 30', 'T-Shirt – M'],
    status: _RequestStatus.collected,
    expectedDate: '10 Apr 2024',
    trackingNote: 'Initial joining kit. Collected from HR.',
  ),
];

// ─────────────────────────────────────────────
// STATUS HELPERS
// ─────────────────────────────────────────────
({String label, Color color, Color bg, IconData icon}) _statusMeta(
    _RequestStatus s) {
  switch (s) {
    case _RequestStatus.pending:
      return (
        label: 'Pending',
        color: _C.warningDark,
        bg: _C.warningLight,
        icon: Icons.hourglass_top_rounded
      );
    case _RequestStatus.processing:
      return (
        label: 'Processing',
        color: _C.primary,
        bg: _C.primaryLight,
        icon: Icons.settings_outlined
      );
    case _RequestStatus.dispatched:
      return (
        label: 'Dispatched',
        color: _C.teal,
        bg: _C.tealLight,
        icon: Icons.local_shipping_outlined
      );
    case _RequestStatus.collected:
      return (
        label: 'Collected ✓',
        color: _C.successDark,
        bg: _C.successLight,
        icon: Icons.verified_outlined
      );
    case _RequestStatus.rejected:
      return (
        label: 'Rejected',
        color: _C.error,
        bg: _C.errorLight,
        icon: Icons.cancel_outlined
      );
  }
}

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class UniformScreen extends StatefulWidget {
  const UniformScreen({super.key});

  @override
  State<UniformScreen> createState() => _UniformScreenState();
}

class _UniformScreenState extends State<UniformScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  _FitPref _fitPref = _FitPref.regular;
  bool _submitting = false;
  final _notesCtrl = TextEditingController();

  final List<_UniformRequest> _history = List.from(_mockHistory);

  // Which items are requested this time
  final Set<String> _selectedForRequest = {'shirt', 'tshirt', 'trouser'};

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
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

  void _showSubmitDialog() {
    final selectedItems = _uniformItems
        .where(
            (i) => _selectedForRequest.contains(i.id) && i.selectedSize != null)
        .toList();

    if (selectedItems.isEmpty) {
      _snack('Please select at least one uniform item', _C.error);
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Submit Uniform Request?',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sizes to be ordered:',
                style: TextStyle(fontSize: 12, color: _C.textSec)),
            const SizedBox(height: 8),
            ...selectedItems.map((i) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [
                    Icon(i.icon, size: 14, color: i.color),
                    const SizedBox(width: 6),
                    Text('${i.name} — ${i.selectedSize}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _C.textPrimary)),
                  ]),
                )),
            const SizedBox(height: 8),
            Text(
                'Fit: ${_fitPref.name[0].toUpperCase()}${_fitPref.name.substring(1)}',
                style: const TextStyle(fontSize: 12, color: _C.textSec)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _C.warningLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(children: [
                Icon(Icons.info_outline_rounded,
                    size: 14, color: _C.warningDark),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Uniforms will be dispatched within 7 working days.',
                    style: TextStyle(
                        fontSize: 11, color: _C.warningDark, height: 1.4),
                  ),
                ),
              ]),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: _C.textSec))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitRequest(selectedItems);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRequest(List<_UniformItem> items) async {
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final newReq = _UniformRequest(
      id: 'UNI-2026-00${4 + _history.length}',
      requestedOn: 'Today',
      items: items.map((i) => '${i.name} – ${i.selectedSize}').toList(),
      status: _RequestStatus.pending,
      expectedDate: 'Within 7 working days',
      trackingNote: 'Request under review by Admin.',
    );

    setState(() {
      _submitting = false;
      _history.insert(0, newReq);
      _tabCtrl.animateTo(1);
    });

    _snack('Uniform request ${newReq.id} submitted ✅', _C.successDark);
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
        title: const Text('Uniform Sizes',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, size: 20),
            color: _C.textSec,
            onPressed: _showSizeGuide,
            tooltip: 'Size Guide',
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
          tabs: const [
            Tab(text: 'Request Uniform'),
            Tab(text: 'History'),
          ],
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
  // TAB 1: REQUEST
  // ─────────────────────────────────────────────
  Widget _buildRequestTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
      children: [
        // Current sizes summary card
        _buildCurrentSummaryCard(),
        const SizedBox(height: 16),

        // Info banner
        const _InfoBanner(
          'Select the items you need and confirm your sizes. '
          'Uniforms are dispatched once approved by Admin.',
          Icons.info_outline_rounded,
          _C.primary,
          _C.primaryLight,
        ),
        const SizedBox(height: 16),

        // Uniform items
        _buildItemSelectionCard(),
        const SizedBox(height: 16),

        // Fit preference
        _buildFitPreferenceCard(),
        const SizedBox(height: 16),

        // Notes
        _buildNotesCard(),
        const SizedBox(height: 16),

        // Submit button
        _buildSubmitButton(),
        const SizedBox(height: 16),

        // Size guide card
        _buildSizeGuideTeaser(),
      ],
    );
  }

  // ─── Current summary card ─────────────────────
  Widget _buildCurrentSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: _C.primary.withValues(alpha: .25),
              blurRadius: 14,
              offset: const Offset(0, 5)),
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
        Positioned(
            right: 40,
            bottom: -25,
            child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: .04)))),
        Padding(
          padding: const EdgeInsets.all(18),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.dry_cleaning_outlined,
                      size: 14, color: Colors.white),
                  SizedBox(width: 6),
                  Text('CURRENT UNIFORM SIZES',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.8)),
                ]),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _C.success.withValues(alpha: .25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.circle, size: 7, color: _C.success),
                  SizedBox(width: 4),
                  Text('On Record',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ]),
              ),
            ]),
            const SizedBox(height: 16),

            // Size pills grid
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _uniformItems.map((item) {
                final size = item.selectedSize ?? '—';
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: .2)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(item.icon, size: 14, color: Colors.white70),
                    const SizedBox(width: 6),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name,
                              style: const TextStyle(
                                  fontSize: 9, color: Colors.white60)),
                          Text(size,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1)),
                        ]),
                  ]),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            const Row(children: [
              Icon(Icons.person_outline_rounded,
                  size: 12, color: Colors.white54),
              SizedBox(width: 5),
              Text('Amit Patil  ·  ',
                  style: TextStyle(fontSize: 10, color: Colors.white54)),
              Icon(Icons.refresh_rounded,
                  size: 11, color: Colors.white54),
              SizedBox(width: 4),
              Text('Last updated: Nov 2025',
                  style: TextStyle(fontSize: 10, color: Colors.white54)),
            ]),
          ]),
        ),
      ]),
    );
  }

  // ─── Item selection card ──────────────────────
  Widget _buildItemSelectionCard() {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Column(children: [
        const _CardHdr('Select Items & Sizes', Icons.checkroom_outlined, _C.primary,
            _C.primaryLight),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: _uniformItems.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final isSelected = _selectedForRequest.contains(item.id);
              final isLast = i == _uniformItems.length - 1;

              return Column(children: [
                _UniformItemRow(
                  item: item,
                  isSelected: isSelected,
                  onToggleSelect: () => setState(() {
                    if (isSelected) {
                      _selectedForRequest.remove(item.id);
                    } else {
                      _selectedForRequest.add(item.id);
                    }
                  }),
                  onSizeChanged: (size) => setState(() {
                    item.selectedSize = size;
                  }),
                ),
                if (!isLast)
                  Container(
                      height: 1,
                      color: _C.border,
                      margin: const EdgeInsets.symmetric(vertical: 4)),
              ]);
            }).toList(),
          ),
        ),
      ]),
    );
  }

  // ─── Fit preference card ──────────────────────
  Widget _buildFitPreferenceCard() {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                color: _C.tealLight, borderRadius: BorderRadius.circular(7)),
            child: const Icon(Icons.tune_rounded, size: 15, color: _C.teal),
          ),
          const SizedBox(width: 10),
          const Text('Fit Preference',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary)),
        ]),
        const SizedBox(height: 12),
        Row(
            children: _FitPref.values.map((f) {
          final active = _fitPref == f;
          final label = f.name[0].toUpperCase() + f.name.substring(1);
          final desc = f == _FitPref.regular
              ? 'Standard cut'
              : f == _FitPref.slim
                  ? 'Tailored fit'
                  : 'Loose comfort';
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: f != _FitPref.relaxed ? 8 : 0),
              child: GestureDetector(
                onTap: () => setState(() => _fitPref = f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: active ? _C.teal : _C.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: active ? _C.teal : _C.border, width: 1.5),
                  ),
                  child: Column(children: [
                    Text(label,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: active ? Colors.white : _C.textPrimary)),
                    const SizedBox(height: 2),
                    Text(desc,
                        style: TextStyle(
                            fontSize: 9,
                            color: active ? Colors.white70 : _C.textSec)),
                  ]),
                ),
              ),
            ),
          );
        }).toList()),
      ]),
    );
  }

  // ─── Notes card ───────────────────────────────
  Widget _buildNotesCard() {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Additional Notes (optional)',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          controller: _notesCtrl,
          maxLines: 2,
          maxLength: 150,
          style: const TextStyle(fontSize: 13, color: _C.textPrimary),
          decoration: InputDecoration(
            hintText: 'Any special requirements or measurement notes…',
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
                borderSide: const BorderSide(color: _C.primary, width: 1.5)),
          ),
        ),
      ]),
    );
  }

  // ─── Submit button ────────────────────────────
  Widget _buildSubmitButton() {
    final selectedCount = _selectedForRequest.length;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _submitting ? null : _showSubmitDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: _C.primary,
          disabledBackgroundColor: _C.textDisabled,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _submitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send_outlined, size: 17),
                  const SizedBox(width: 8),
                  Text(
                    selectedCount == 0
                        ? 'Select items to request'
                        : 'Submit Request ($selectedCount item${selectedCount != 1 ? "s" : ""})',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }

  // ─── Size guide teaser ────────────────────────
  Widget _buildSizeGuideTeaser() {
    return GestureDetector(
      onTap: _showSizeGuide,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.border),
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: _C.accentLight, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.straighten_outlined,
                size: 22, color: _C.accent),
          ),
          const SizedBox(width: 12),
          const Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Size Measurement Guide',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _C.textPrimary)),
                Text('How to measure correctly for the best fit',
                    style: TextStyle(fontSize: 11, color: _C.textSec)),
              ])),
          const Icon(Icons.chevron_right_rounded, size: 20, color: _C.textSec),
        ]),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TAB 2: HISTORY
  // ─────────────────────────────────────────────
  Widget _buildHistoryTab() {
    return _history.isEmpty
        ? _EmptyHistory()
        : ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 48),
            itemCount: _history.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _RequestCard(
              request: _history[i],
              onToggle: () =>
                  setState(() => _history[i].expanded = !_history[i].expanded),
            ),
          );
  }

  // ─────────────────────────────────────────────
  // SIZE GUIDE SHEET
  // ─────────────────────────────────────────────
  void _showSizeGuide() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, ctrl) => _SizeGuideSheet(scrollCtrl: ctrl),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// UNIFORM ITEM ROW (size selector inline)
// ─────────────────────────────────────────────
class _UniformItemRow extends StatelessWidget {
  final _UniformItem item;
  final bool isSelected;
  final VoidCallback onToggleSelect;
  final void Function(String) onSizeChanged;

  const _UniformItemRow({
    required this.item,
    required this.isSelected,
    required this.onToggleSelect,
    required this.onSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header row with checkbox
        Row(children: [
          GestureDetector(
            onTap: onToggleSelect,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? _C.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: isSelected ? _C.primary : _C.border, width: 1.5),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: item.bg, borderRadius: BorderRadius.circular(9)),
            child: Icon(item.icon, size: 17, color: item.color),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text(item.name,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? _C.textPrimary : _C.textSec))),
          if (item.selectedSize != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: isSelected ? item.bg : _C.surface,
                  borderRadius: BorderRadius.circular(20)),
              child: Text(item.selectedSize!,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? item.color : _C.textSec)),
            ),
        ]),

        // Size grid (shown only when selected)
        if (isSelected) ...[
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: item.sizes.map((size) {
                final isCurrent = item.selectedSize == size;
                return Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: GestureDetector(
                    onTap: () => onSizeChanged(size),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 44,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isCurrent ? item.color : _C.surface,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: isCurrent ? item.color : _C.border,
                          width: isCurrent ? 0 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(size,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isCurrent ? Colors.white : _C.textSec)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// REQUEST HISTORY CARD
// ─────────────────────────────────────────────
class _RequestCard extends StatelessWidget {
  final _UniformRequest request;
  final VoidCallback onToggle;

  const _RequestCard({required this.request, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final meta = _statusMeta(request.status);

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
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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

              // Items
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: request.items
                    .map((item) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: _C.primaryLight,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: _C.primary.withValues(alpha: .2))),
                          child: Text(item,
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _C.primary)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),

              // Meta row
              Row(children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 11, color: _C.textTert),
                const SizedBox(width: 4),
                Text('Requested: ${request.requestedOn}',
                    style: const TextStyle(fontSize: 10, color: _C.textTert)),
                if (request.expectedDate != null) ...[
                  const SizedBox(width: 10),
                  const Icon(Icons.event_available_outlined,
                      size: 11, color: _C.textTert),
                  const SizedBox(width: 4),
                  Text('Expected: ${request.expectedDate}',
                      style: const TextStyle(fontSize: 10, color: _C.textTert)),
                ],
              ]),
            ]),
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
                    // Status tracker
                    _StatusTracker(currentStatus: request.status),
                    const SizedBox(height: 12),

                    // Tracking note
                    if (request.trackingNote != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: meta.bg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: meta.color.withValues(alpha: .2)),
                        ),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(meta.icon, size: 14, color: meta.color),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(request.trackingNote!,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: _C.textPrimary,
                                        height: 1.4)),
                              ),
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
// STATUS TRACKER
// ─────────────────────────────────────────────
class _StatusTracker extends StatelessWidget {
  final _RequestStatus currentStatus;
  const _StatusTracker({required this.currentStatus});

  static const _steps = [
    (
      label: 'Pending',
      icon: Icons.hourglass_top_rounded,
      status: _RequestStatus.pending
    ),
    (
      label: 'Processing',
      icon: Icons.settings_outlined,
      status: _RequestStatus.processing
    ),
    (
      label: 'Dispatched',
      icon: Icons.local_shipping_outlined,
      status: _RequestStatus.dispatched
    ),
    (
      label: 'Collected',
      icon: Icons.verified_outlined,
      status: _RequestStatus.collected
    ),
  ];

  int get _currentIndex {
    if (currentStatus == _RequestStatus.rejected) return -1;
    return _steps.indexWhere((s) => s.status == currentStatus);
  }

  @override
  Widget build(BuildContext context) {
    if (currentStatus == _RequestStatus.rejected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
            color: _C.errorLight, borderRadius: BorderRadius.circular(10)),
        child: const Row(children: [
          Icon(Icons.cancel_outlined, size: 16, color: _C.error),
          SizedBox(width: 8),
          Text('Request rejected by Admin.',
              style: TextStyle(fontSize: 12, color: _C.error)),
        ]),
      );
    }

    final idx = _currentIndex;

    return Row(
      children: _steps.asMap().entries.map((e) {
        final i = e.key;
        final step = e.value;
        final done = i <= idx;
        final curr = i == idx;

        return Expanded(
            child: Row(children: [
          Expanded(
              child: Column(children: [
            // Circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: done ? _C.primary : _C.surface,
                shape: BoxShape.circle,
                border: Border.all(
                    color: done ? _C.primary : _C.border,
                    width: curr ? 2.5 : 1),
              ),
              child: Icon(step.icon,
                  size: 14, color: done ? Colors.white : _C.textDisabled),
            ),
            const SizedBox(height: 4),
            Text(step.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: done ? _C.primary : _C.textDisabled)),
          ])),

          // Connector line (not after last)
          if (i < _steps.length - 1)
            Expanded(
                child: Container(
              height: 2,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: i < idx ? _C.primary : _C.border,
                borderRadius: BorderRadius.circular(1),
              ),
            )),
        ]));
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────
// SIZE GUIDE SHEET
// ─────────────────────────────────────────────
class _SizeGuideSheet extends StatelessWidget {
  final ScrollController scrollCtrl;
  const _SizeGuideSheet({required this.scrollCtrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(
            child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: _C.border, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        const Text('Size Measurement Guide',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _C.textPrimary)),
        const SizedBox(height: 4),
        const Text('Take measurements over light clothing for accuracy',
            style: TextStyle(fontSize: 13, color: _C.textSec)),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(controller: scrollCtrl, children: [
            // Body measurement guide
            _measureSection('Upper Body', const [
              _MeasureTip(Icons.expand_outlined, 'Chest',
                  'Measure around the fullest part of your chest, keeping tape level.'),
              _MeasureTip(Icons.height_outlined, 'Shoulder',
                  'Measure from one shoulder tip to the other across your back.'),
              _MeasureTip(Icons.straighten_outlined, 'Sleeve',
                  'From shoulder tip to wrist with arm slightly bent.'),
            ]),
            const SizedBox(height: 14),
            _measureSection('Lower Body', const [
              _MeasureTip(Icons.airline_seat_legroom_normal_outlined, 'Waist',
                  'Measure around your natural waistline, 2 fingers above hip.'),
              _MeasureTip(Icons.straighten_outlined, 'Hip',
                  'Measure around the widest part of your hips/seat.'),
              _MeasureTip(Icons.height_outlined, 'Inseam',
                  'From crotch to ankle along inside of leg.'),
            ]),
            const SizedBox(height: 14),

            // Size chart
            _sizeChart(),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _C.primaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _C.primary.withValues(alpha: .2)),
              ),
              child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.tips_and_updates_outlined,
                        size: 16, color: _C.primary),
                    SizedBox(width: 8),
                    Expanded(
                        child: Text(
                      'If between sizes, go one size up for comfort. '
                      'Contact HR at uniform@isf.com for custom measurements.',
                      style: TextStyle(
                          fontSize: 12, color: _C.primary, height: 1.4),
                    )),
                  ]),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _measureSection(String title, List<_MeasureTip> tips) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary)),
          const SizedBox(height: 8),
          ...tips.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: _C.surface,
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                          color: _C.primaryLight,
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(t.icon, size: 16, color: _C.primary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(t.label,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _C.textPrimary)),
                          Text(t.desc,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: _C.textSec,
                                  height: 1.4)),
                        ])),
                  ]),
                ),
              )),
        ],
      );

  Widget _sizeChart() {
    final headers = ['Size', 'Chest (in)', 'Waist (in)', 'Hip (in)'];
    final rows = [
      ['XS', '34–35', '28–29', '34–35'],
      ['S', '36–37', '30–31', '36–37'],
      ['M', '38–39', '32–33', '38–39'],
      ['L', '40–41', '34–35', '40–41'],
      ['XL', '42–43', '36–37', '42–43'],
      ['XXL', '44–45', '38–39', '44–45'],
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _C.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
          decoration: const BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
              children: headers
                  .map((h) => Expanded(
                        child: Text(h,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _C.textSec)),
                      ))
                  .toList()),
        ),
        ...rows.asMap().entries.map((e) {
          final i = e.key;
          final row = e.value;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
            decoration: BoxDecoration(
              color: i.isOdd ? _C.surface.withValues(alpha: .4) : Colors.transparent,
            ),
            child: Row(
              children: row
                  .asMap()
                  .entries
                  .map((ce) => Expanded(
                        child: Text(ce.value,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: ce.key == 0
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color:
                                    ce.key == 0 ? _C.primary : _C.textPrimary)),
                      ))
                  .toList(),
            ),
          );
        }),
      ]),
    );
  }
}

class _MeasureTip {
  final IconData icon;
  final String label;
  final String desc;
  const _MeasureTip(this.icon, this.label, this.desc);
}

// ─────────────────────────────────────────────
// SHARED SMALL WIDGETS
// ─────────────────────────────────────────────
class _CardHdr extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color, bg;
  const _CardHdr(this.title, this.icon, this.color, this.bg);

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

class _InfoBanner extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color, bg;
  const _InfoBanner(this.message, this.icon, this.color, this.bg);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: .3)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 10),
          Expanded(
              child: Text(message,
                  style: TextStyle(fontSize: 12, color: color, height: 1.4))),
        ]),
      );
}

class _EmptyHistory extends StatelessWidget {
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
                child: const Icon(Icons.dry_cleaning_outlined,
                    size: 36, color: _C.primary)),
            const SizedBox(height: 16),
            const Text('No uniform requests yet',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary)),
            const SizedBox(height: 6),
            const Text('Submit a uniform request to see it here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: _C.textSec, height: 1.5)),
          ]),
        ),
      );
}
