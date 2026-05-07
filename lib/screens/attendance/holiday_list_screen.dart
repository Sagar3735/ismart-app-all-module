// ============================================================
// ISF HR Portal — Holiday List Screen
// File: lib/screens/attendance/holiday_list_screen.dart
//
// Features:
//   - Year selector (2024 / 2025 / 2026 / 2027)
//   - 3-stat summary row (Total / Remaining / This Month)
//   - Filter chips (All / National / Regional / Festival / Optional)
//   - Holidays grouped by month with sticky-style section headers
//   - Holiday cards with colour-coded date box, type chip,
//     day-of-week, and "Today / Upcoming / X days away" badges
//   - Optional holidays section with max-2 checkbox selector
//   - "Add to Calendar" action per holiday
//   - Share / Download buttons in app bar
//   - Bottom sheet: holiday detail
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
  static const orange = Color(0xFFEA580C);
  static const orangeLight = Color(0xFFFFF7ED);
  static const bg = Color(0xFFF8FAFC);
  static const card = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF1F5F9);
  static const textPrimary = Color(0xFF0F172A);
  static const textSec = Color(0xFF64748B);
  static const textDisabled = Color(0xFFCBD5E1);
  static const border = Color(0xFFE2E8F0);
}

// ─────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────
enum _HolType { national, regional, festival, optional }

class _Holiday {
  final String id;
  final String name;
  final DateTime date;
  final _HolType type;
  final String? description;

  const _Holiday({
    required this.id,
    required this.name,
    required this.date,
    required this.type,
    this.description,
  });
}

// ─────────────────────────────────────────────
// MOCK DATA  (multi-year)
// ─────────────────────────────────────────────
final _holidays2026 = [
  _Holiday(
      id: 'h01',
      name: 'New Year\'s Day',
      date: _d(2026, 1, 1),
      type: _HolType.national,
      description: 'Celebration of the new calendar year.'),
  _Holiday(
      id: 'h02',
      name: 'Republic Day',
      date: _d(2026, 1, 26),
      type: _HolType.national,
      description:
          'India\'s Republic Day — constitution came into effect on 26 Jan 1950.'),
  _Holiday(
      id: 'h03',
      name: 'Holi',
      date: _d(2026, 3, 14),
      type: _HolType.festival,
      description: 'Festival of colours celebrated across India.'),
  _Holiday(
      id: 'h04',
      name: 'Good Friday',
      date: _d(2026, 4, 3),
      type: _HolType.national,
      description:
          'Christian observance commemorating the crucifixion of Jesus.'),
  _Holiday(
      id: 'h05',
      name: 'Ambedkar Jayanti',
      date: _d(2026, 4, 14),
      type: _HolType.national,
      description:
          'Birth anniversary of Dr. B. R. Ambedkar, architect of India\'s constitution.'),
  _Holiday(
      id: 'h06',
      name: 'Maharashtra Day',
      date: _d(2026, 5, 1),
      type: _HolType.regional,
      description: 'Formation day of Maharashtra state (1960).'),
  _Holiday(
      id: 'h07',
      name: 'Eid ul-Adha',
      date: _d(2026, 6, 16),
      type: _HolType.festival,
      description:
          'Islamic festival of sacrifice. Date subject to moon sighting.'),
  _Holiday(
      id: 'h08',
      name: 'Independence Day',
      date: _d(2026, 8, 15),
      type: _HolType.national,
      description:
          'India\'s Independence Day — freedom from British rule in 1947.'),
  _Holiday(
      id: 'h09',
      name: 'Ganesh Chaturthi',
      date: _d(2026, 8, 24),
      type: _HolType.regional,
      description:
          'Festival celebrating the birth of Lord Ganesha. Major in Maharashtra.'),
  _Holiday(
      id: 'h10',
      name: 'Gandhi Jayanti',
      date: _d(2026, 10, 2),
      type: _HolType.national,
      description:
          'Birth anniversary of Mahatma Gandhi, Father of the Nation.'),
  _Holiday(
      id: 'h11',
      name: 'Dussehra',
      date: _d(2026, 10, 21),
      type: _HolType.festival,
      description: 'Celebrates the victory of Lord Rama over Ravana.'),
  _Holiday(
      id: 'h12',
      name: 'Diwali',
      date: _d(2026, 11, 9),
      type: _HolType.festival,
      description:
          'Festival of lights — celebrated by lighting diyas and bursting crackers.'),
  _Holiday(
      id: 'h13',
      name: 'Diwali Laxmi Puja',
      date: _d(2026, 11, 10),
      type: _HolType.festival,
      description: 'Laxmi Puja day — main Diwali celebration.'),
  _Holiday(
      id: 'h14',
      name: 'Christmas',
      date: _d(2026, 12, 25),
      type: _HolType.national,
      description: 'Annual celebration of the birth of Jesus Christ.'),
  // Optional holidays
  _Holiday(
      id: 'o01',
      name: 'Muharram',
      date: _d(2026, 7, 6),
      type: _HolType.optional,
      description:
          'Islamic New Year. Optional holiday — choose if applicable to you.'),
  _Holiday(
      id: 'o02',
      name: 'Milad-un-Nabi',
      date: _d(2026, 9, 14),
      type: _HolType.optional,
      description: 'Prophet Muhammad\'s birthday. Optional holiday.'),
  _Holiday(
      id: 'o03',
      name: 'Guru Nanak Jayanti',
      date: _d(2026, 11, 3),
      type: _HolType.optional,
      description:
          'Birth anniversary of Guru Nanak Dev Ji, founder of Sikhism.'),
  _Holiday(
      id: 'o04',
      name: 'Christmas Eve',
      date: _d(2026, 12, 24),
      type: _HolType.optional,
      description: 'The evening/day before Christmas. Optional holiday.'),
];

final _holidays2025 = [
  _Holiday(
      id: '25h01',
      name: 'Republic Day',
      date: _d(2025, 1, 26),
      type: _HolType.national),
  _Holiday(
      id: '25h02',
      name: 'Holi',
      date: _d(2025, 3, 14),
      type: _HolType.festival),
  _Holiday(
      id: '25h03',
      name: 'Ambedkar Jayanti',
      date: _d(2025, 4, 14),
      type: _HolType.national),
  _Holiday(
      id: '25h04',
      name: 'Maharashtra Day',
      date: _d(2025, 5, 1),
      type: _HolType.regional),
  _Holiday(
      id: '25h05',
      name: 'Independence Day',
      date: _d(2025, 8, 15),
      type: _HolType.national),
  _Holiday(
      id: '25h06',
      name: 'Gandhi Jayanti',
      date: _d(2025, 10, 2),
      type: _HolType.national),
  _Holiday(
      id: '25h07',
      name: 'Diwali',
      date: _d(2025, 10, 20),
      type: _HolType.festival),
  _Holiday(
      id: '25h08',
      name: 'Christmas',
      date: _d(2025, 12, 25),
      type: _HolType.national),
];

// ignore: non_constant_identifier_names
DateTime _d(int y, int m, int dd) => DateTime(y, m, dd);

final _byYear = <int, List<_Holiday>>{
  2025: _holidays2025,
  2026: _holidays2026,
};

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────
({String label, Color color, Color bg, Color dateBox}) _typeMeta(_HolType t) {
  switch (t) {
    case _HolType.national:
      return (
        label: 'National',
        color: _C.primary,
        bg: _C.primaryLight,
        dateBox: _C.primary
      );
    case _HolType.regional:
      return (
        label: 'Regional',
        color: _C.successDark,
        bg: _C.successLight,
        dateBox: _C.successDark
      );
    case _HolType.festival:
      return (
        label: 'Festival',
        color: _C.orange,
        bg: _C.orangeLight,
        dateBox: _C.orange
      );
    case _HolType.optional:
      return (
        label: 'Optional',
        color: _C.textSec,
        bg: _C.surface,
        dateBox: _C.textSec
      );
  }
}

const _monthNames = [
  '',
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
const _monthShort = [
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
  'Dec',
];
const _dayNames = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class HolidayListScreen extends StatefulWidget {
  const HolidayListScreen({super.key});

  @override
  State<HolidayListScreen> createState() => _HolidayListScreenState();
}

class _HolidayListScreenState extends State<HolidayListScreen> {
  int _year = 2026;
  _HolType? _filter; // null = All (excludes optional in main list)
  bool _showOptional = true;

  // Optional holiday selection (max 2)
  final Set<String> _selectedOptional = {};

  List<_Holiday> get _allForYear => _byYear[_year] ?? [];

  List<_Holiday> get _mainHolidays => _allForYear
      .where((h) => h.type != _HolType.optional)
      .where((h) => _filter == null || h.type == _filter)
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  List<_Holiday> get _optionalHolidays =>
      _allForYear.where((h) => h.type == _HolType.optional).toList()
        ..sort((a, b) => a.date.compareTo(b.date));

  // Group main holidays by month
  Map<int, List<_Holiday>> get _byMonth {
    final map = <int, List<_Holiday>>{};
    for (final h in _mainHolidays) {
      (map[h.date.month] ??= []).add(h);
    }
    return map;
  }

  // Stats
  int get _totalHolidays =>
      _allForYear.where((h) => h.type != _HolType.optional).length;

  int get _remaining {
    final now = DateTime.now();
    return _allForYear
        .where((h) =>
            h.type != _HolType.optional &&
            h.date.isAfter(now.subtract(const Duration(days: 1))))
        .length;
  }

  String get _thisMonthLabel {
    final now = DateTime.now();
    final count = _allForYear
        .where((h) =>
            h.type != _HolType.optional &&
            h.date.year == now.year &&
            h.date.month == now.month)
        .length;
    return '$count';
  }

  // Proximity label for a holiday
  String? _proximityLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final hDay = DateTime(d.year, d.month, d.day);
    final diff = hDay.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff > 0 && diff <= 7) return '$diff days away';
    if (diff < 0) return null; // past
    return null;
  }

  bool _isPast(DateTime d) {
    final today = DateTime.now();
    return d.isBefore(DateTime(today.year, today.month, today.day));
  }

  @override
  Widget build(BuildContext context) {
    final months = _byMonth;
    final sortedMonths = months.keys.toList()..sort();

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _buildAppBar(),
      body: Column(children: [
        _buildYearSelector(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 48),
            children: [
              _buildSummaryRow(),
              const SizedBox(height: 14),
              _buildFilterChips(),
              const SizedBox(height: 14),

              // ── Month sections ───────────────
              ...sortedMonths.map((month) {
                final hols = months[month]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMonthHeader(month, hols.length),
                    const SizedBox(height: 8),
                    ...hols.asMap().entries.map((e) => _HolidayCard(
                          holiday: e.value,
                          proximityLabel: _proximityLabel(e.value.date),
                          isPast: _isPast(e.value.date),
                          onTap: () => _showDetail(e.value),
                          onAddToCalendar: () => _snack(
                              '${e.value.name} added to calendar 📅',
                              _C.successDark),
                        )),
                    const SizedBox(height: 18),
                  ],
                );
              }),

              // ── Optional holidays ─────────────
              if (_optionalHolidays.isNotEmpty && _filter == null) ...[
                _buildOptionalSection(),
                const SizedBox(height: 16),
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
        title: const Text('Holiday List',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            color: _C.textSec,
            onPressed: () => _snack('Holiday calendar shared', _C.textSec),
            tooltip: 'Share',
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined, size: 21),
            color: _C.textSec,
            onPressed: () =>
                _snack('Holiday list PDF downloaded ✅', _C.successDark),
            tooltip: 'Download PDF',
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _C.border),
        ),
      );

  // ─────────────────────────────────────────────
  // YEAR SELECTOR
  // ─────────────────────────────────────────────
  Widget _buildYearSelector() {
    const years = [2025, 2026, 2027];
    return Container(
      color: _C.card,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(children: [
        const Text('Year:',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500, color: _C.textSec)),
        const SizedBox(width: 12),
        ...years.map((y) {
          final active = y == _year;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() {
                _year = y;
                _filter = null;
                _selectedOptional.clear();
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: active ? _C.primary : _C.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active ? _C.primary : _C.border,
                  ),
                ),
                child: Text('$y',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: active ? Colors.white : _C.textSec)),
              ),
            ),
          );
        }),
        const Spacer(),
        // ISF company indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
              color: _C.orangeLight, borderRadius: BorderRadius.circular(20)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.business_outlined, size: 11, color: _C.orange),
            SizedBox(width: 4),
            Text('ISF Portal',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _C.orange)),
          ]),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────
  // SUMMARY ROW
  // ─────────────────────────────────────────────
  Widget _buildSummaryRow() {
    final items = [
      (
        '$_totalHolidays',
        'Total',
        _C.primary,
        _C.primaryLight,
        Icons.event_outlined
      ),
      (
        '$_remaining',
        'Remaining',
        _C.successDark,
        _C.successLight,
        Icons.event_available_outlined
      ),
      (
        _thisMonthLabel,
        'This Month',
        _C.orange,
        _C.orangeLight,
        Icons.calendar_month_outlined
      ),
    ];

    return Row(
        children: items.map((item) {
      final (value, label, color, bg, icon) = item;
      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: item != items.last ? 10 : 0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: .2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(value,
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: color,
                            height: 1)),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          color: color.withValues(alpha: .15),
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(icon, size: 16, color: color),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color.withValues(alpha: .8))),
              ],
            ),
          ),
        ),
      );
    }).toList());
  }

  // ─────────────────────────────────────────────
  // FILTER CHIPS
  // ─────────────────────────────────────────────
  Widget _buildFilterChips() {
    final allCount =
        _allForYear.where((h) => h.type != _HolType.optional).length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        _filterChip('All', _filter == null, allCount,
            () => setState(() => _filter = null)),
        ...[_HolType.national, _HolType.regional, _HolType.festival].map((t) {
          final meta = _typeMeta(t);
          final cnt = _allForYear.where((h) => h.type == t).length;
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _filterChip(
              meta.label,
              _filter == t,
              cnt,
              () => setState(() => _filter = _filter == t ? null : t),
              color: meta.color,
            ),
          );
        }),
      ]),
    );
  }

  Widget _filterChip(
    String label,
    bool active,
    int count,
    VoidCallback onTap, {
    Color? color,
  }) {
    final activeColor = color ?? _C.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? activeColor : _C.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? activeColor : _C.border),
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
              borderRadius: BorderRadius.circular(10),
            ),
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

  // ─────────────────────────────────────────────
  // MONTH HEADER
  // ─────────────────────────────────────────────
  Widget _buildMonthHeader(int month, int count) {
    final now = DateTime.now();
    final isCurrent = _year == now.year && month == now.month;

    return Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isCurrent ? _C.primary : _C.textPrimary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (isCurrent) ...[
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          Text(_monthNames[month],
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          if (isCurrent) ...[
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Current',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ],
        ]),
      ),
      const SizedBox(width: 10),
      Expanded(child: Container(height: 1, color: _C.border)),
      const SizedBox(width: 10),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: _C.surface, borderRadius: BorderRadius.circular(10)),
        child: Text(
          '$count holiday${count != 1 ? "s" : ""}',
          style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: _C.textSec),
        ),
      ),
    ]);
  }

  // ─────────────────────────────────────────────
  // OPTIONAL HOLIDAYS SECTION
  // ─────────────────────────────────────────────
  Widget _buildOptionalSection() {
    final selectedCount = _selectedOptional.length;
    const maxSelect = 2;

    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Column(children: [
        // Header
        InkWell(
          onTap: () => setState(() => _showOptional = !_showOptional),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    color: _C.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _C.border)),
                child: const Icon(Icons.check_box_outlined,
                    size: 16, color: _C.textSec),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Optional Holidays',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _C.textPrimary)),
                  Text(
                      'Choose any $maxSelect from ${_optionalHolidays.length} options',
                      style: const TextStyle(fontSize: 11, color: _C.textSec)),
                ],
              )),
              // Counter
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: selectedCount == maxSelect
                      ? _C.successLight
                      : _C.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$selectedCount of $maxSelect selected',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: selectedCount == maxSelect
                          ? _C.successDark
                          : _C.primary),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedRotation(
                turns: _showOptional ? 0.5 : 0,
                duration: const Duration(milliseconds: 220),
                child: const Icon(Icons.keyboard_arrow_down_rounded,
                    size: 20, color: _C.textSec),
              ),
            ]),
          ),
        ),

        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _showOptional
              ? Column(children: [
                  Container(height: 1, color: _C.border),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Info note
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _C.warningLight,
                            borderRadius: BorderRadius.circular(10),
                            border:
                                Border.all(color: _C.warning.withValues(alpha: .3)),
                          ),
                          child: const Row(children: [
                            Icon(Icons.info_outline_rounded,
                                size: 14, color: _C.warningDark),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Select up to 2 optional holidays applicable to you. Submit selection by 31 Jan.',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: _C.warningDark,
                                    height: 1.4),
                              ),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 12),

                        // Optional holiday rows
                        ..._optionalHolidays.map((h) {
                          final isSelected = _selectedOptional.contains(h.id);
                          final canSelect =
                              isSelected || selectedCount < maxSelect;
                          final past = _isPast(h.date);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: past
                                  ? null
                                  : !canSelect
                                      ? () => _snack(
                                          'Max $maxSelect selections reached',
                                          _C.error)
                                      : () => setState(() {
                                            if (isSelected) {
                                              _selectedOptional.remove(h.id);
                                            } else {
                                              _selectedOptional.add(h.id);
                                            }
                                          }),
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected ? _C.primaryLight : _C.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? _C.primary.withValues(alpha: .4)
                                        : _C.border,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(children: [
                                  // Checkbox
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? _C.primary
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color:
                                            isSelected ? _C.primary : _C.border,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(Icons.check_rounded,
                                            size: 14, color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),

                                  // Date box
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: past ? _C.surface : _C.surface,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: _C.border),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${h.date.day}',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: past
                                                  ? _C.textDisabled
                                                  : _C.textPrimary,
                                              height: 1),
                                        ),
                                        Text(
                                          _monthShort[h.date.month],
                                          style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w600,
                                              color: past
                                                  ? _C.textDisabled
                                                  : _C.textSec),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Info
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        h.name,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: past
                                              ? _C.textDisabled
                                              : isSelected
                                                  ? _C.primary
                                                  : _C.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _dayNames[h.date.weekday],
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: past
                                                ? _C.textDisabled
                                                : _C.textSec),
                                      ),
                                    ],
                                  )),

                                  if (past)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                          color: _C.surface,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: const Text('Past',
                                          style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w600,
                                              color: _C.textDisabled)),
                                    ),
                                ]),
                              ),
                            ),
                          );
                        }),

                        if (selectedCount > 0) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton(
                              onPressed: selectedCount == 0
                                  ? null
                                  : () => _snack(
                                      'Optional holiday selection saved ✅',
                                      _C.successDark),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _C.primary,
                                disabledBackgroundColor: _C.textDisabled,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                selectedCount == 0
                                    ? 'Select holidays above'
                                    : 'Save Selection ($selectedCount selected)',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ])
              : const SizedBox.shrink(),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────
  // DETAIL BOTTOM SHEET
  // ─────────────────────────────────────────────
  void _showDetail(_Holiday h) {
    final meta = _typeMeta(h.type);
    final prox = _proximityLabel(h.date);
    final isPast = _isPast(h.date);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 20),

            // Date hero
            Row(children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: isPast ? _C.surface : meta.bg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: isPast ? _C.border : meta.color.withValues(alpha: .3)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${h.date.day}',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: isPast ? _C.textDisabled : meta.dateBox,
                            height: 1)),
                    Text(_monthShort[h.date.month],
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isPast
                                ? _C.textDisabled
                                : meta.dateBox.withValues(alpha: .7))),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(h.name,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _C.textPrimary)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                          color: meta.bg,
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: meta.color.withValues(alpha: .3))),
                      child: Text(meta.label,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: meta.color)),
                    ),
                    if (prox != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                            color: prox == 'Today'
                                ? _C.successLight
                                : _C.warningLight,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(prox,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: prox == 'Today'
                                    ? _C.successDark
                                    : _C.warningDark)),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 4),
                  Text(
                    '${_dayNames[h.date.weekday]}, '
                    '${h.date.day} ${_monthNames[h.date.month]} ${h.date.year}',
                    style: const TextStyle(fontSize: 12, color: _C.textSec),
                  ),
                ],
              )),
            ]),

            if (h.description != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _C.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(h.description!,
                    style: const TextStyle(
                        fontSize: 13, color: _C.textPrimary, height: 1.6)),
              ),
            ],
            const SizedBox(height: 16),

            // Action buttons
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _snack('${h.name} added to calendar 📅', _C.successDark);
                  },
                  icon: const Icon(Icons.calendar_month_outlined, size: 17),
                  label: const Text('Add to Calendar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _C.primary,
                    side: const BorderSide(color: _C.primary, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _snack('${h.name} shared', _C.textSec);
                  },
                  icon: const Icon(Icons.share_outlined, size: 17),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
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
      duration: const Duration(seconds: 2),
    ));
  }
}

// ─────────────────────────────────────────────
// HOLIDAY CARD
// ─────────────────────────────────────────────
class _HolidayCard extends StatelessWidget {
  final _Holiday holiday;
  final String? proximityLabel;
  final bool isPast;
  final VoidCallback onTap;
  final VoidCallback onAddToCalendar;

  const _HolidayCard({
    required this.holiday,
    required this.proximityLabel,
    required this.isPast,
    required this.onTap,
    required this.onAddToCalendar,
  });

  @override
  Widget build(BuildContext context) {
    final h = holiday;
    final meta = _typeMeta(h.type);
    final prox = proximityLabel;
    final isToday = prox == 'Today';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: isToday ? _C.successLight : _C.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isToday ? _C.success.withValues(alpha: .4) : _C.border,
              width: isToday ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              // Date box
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: isPast ? _C.surface : meta.bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isPast ? _C.border : meta.color.withValues(alpha: .25),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${h.date.day}',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isPast ? _C.textDisabled : meta.dateBox,
                          height: 1),
                    ),
                    Text(
                      _monthShort[h.date.month],
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isPast
                              ? _C.textDisabled
                              : meta.dateBox.withValues(alpha: .7)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + proximity badge
                  Row(children: [
                    Expanded(
                      child: Text(
                        h.name,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isPast ? _C.textDisabled : _C.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (prox != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: isToday ? _C.successDark : _C.warningLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(prox,
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color:
                                    isToday ? Colors.white : _C.warningDark)),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 4),

                  // Day name + type chip
                  Row(children: [
                    Text(
                      _dayNames[h.date.weekday],
                      style: TextStyle(
                          fontSize: 11,
                          color: isPast ? _C.textDisabled : _C.textSec),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPast ? _C.surface : meta.bg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              isPast ? _C.border : meta.color.withValues(alpha: .3),
                        ),
                      ),
                      child: Text(meta.label,
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: isPast ? _C.textDisabled : meta.color)),
                    ),
                  ]),
                ],
              )),

              // Add to calendar button
              if (!isPast)
                GestureDetector(
                  onTap: onAddToCalendar,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: meta.bg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.add_circle_outline_rounded,
                      size: 18,
                      color: meta.color,
                    ),
                  ),
                )
              else
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _C.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18,
                    color: _C.textDisabled,
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}
