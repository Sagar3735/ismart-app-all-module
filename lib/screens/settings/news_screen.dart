// ============================================================
// ISF HR Portal — News & Updates Screen
// File: lib/screens/settings/news_screen.dart
//
// Features:
//   - Featured / hero article carousel (auto-scroll)
//   - Category filter chips (All / Company / Industry / HR / Tech / Events)
//   - News card grid/list with thumbnail, tag, read time, save
//   - Search bar
//   - Article detail bottom sheet (full content + share/bookmark)
//   - Bookmarked articles saved state
//   - "Trending" section
//   - External link articles
//
// Dependencies: none beyond flutter/material
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// INLINE THEME
// ─────────────────────────────────────────────
class _C {
  static const primary = Color(0xFF2563EB);
  static const primaryLight = Color(0xFFEFF6FF);
  static const accent = Color(0xFF6366F1);
  static const accentLight = Color(0xFFEEF2FF);
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
enum _Category { company, industry, hr, tech, events }

class _Article {
  final String id;
  final String title;
  final String summary;
  final String body;
  final _Category category;
  final String author;
  final String publishedOn;
  final String readTime;
  final bool isFeatured;
  final bool isTrending;
  final Color heroColor; // gradient background colour
  final Color heroColorEnd;
  final String? externalUrl;
  bool isBookmarked = false;
  bool isRead = false;

  _Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    required this.category,
    required this.author,
    required this.publishedOn,
    required this.readTime,
    this.isFeatured = false,
    this.isTrending = false,
    required this.heroColor,
    required this.heroColorEnd,
    this.externalUrl,
  });
}

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────
({String label, Color color, Color bg, IconData icon}) _catMeta(_Category c) {
  switch (c) {
    case _Category.company:
      return (
        label: 'Company',
        color: _C.primary,
        bg: _C.primaryLight,
        icon: Icons.business_outlined
      );
    case _Category.industry:
      return (
        label: 'Industry',
        color: _C.teal,
        bg: _C.tealLight,
        icon: Icons.trending_up_rounded
      );
    case _Category.hr:
      return (
        label: 'HR & People',
        color: _C.purple,
        bg: _C.purpleLight,
        icon: Icons.people_outline_rounded
      );
    case _Category.tech:
      return (
        label: 'Technology',
        color: _C.accent,
        bg: _C.accentLight,
        icon: Icons.computer_outlined
      );
    case _Category.events:
      return (
        label: 'Events',
        color: _C.orange,
        bg: _C.orangeLight,
        icon: Icons.celebration_outlined
      );
  }
}

// ─────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────
final _articles = [
  // FEATURED
  _Article(
    id: 'n01',
    title: 'ISF Solutions Wins "Best Employer 2026" at HR Excellence Awards',
    summary:
        'ISF recognised for outstanding employee experience, diversity initiatives, and innovative HR practices at the national HR Excellence Awards ceremony.',
    body:
        '''ISF Solutions Pvt. Ltd. was honoured with the prestigious "Best Employer 2026" award at the National HR Excellence Awards held in Mumbai on 27 April 2026.

The award recognises organisations that have demonstrated exceptional commitment to employee wellbeing, inclusive culture, and forward-thinking human resource practices.

**Key Highlights That Led to the Award**

Our jury cited several initiatives that set ISF apart:
• Launch of the ISmart HR Portal — enabling fully digital HR self-service for 1,200+ employees
• Flexi-work policy introduced in May 2026, offering up to 3 WFH days per week
• 96% employee satisfaction score in the annual People Survey
• Zero-tolerance POSH policy with 100% training compliance
• Industry-leading maternity and paternity benefits

**CEO's Statement**

"This award reflects the dedication of every ISFian. Our people are our greatest asset, and we remain committed to creating an environment where everyone can do their best work," said Rajesh Gupta, CEO of ISF Solutions.

The award ceremony was attended by 300+ HR leaders from across India. ISF was selected from a pool of 450 companies across various industries.

We celebrate this achievement with all our 1,200+ team members across Mumbai, Pune, and Bengaluru.''',
    category: _Category.company,
    author: 'Communications Team',
    publishedOn: '28 Apr 2026',
    readTime: '3 min read',
    isFeatured: true,
    isTrending: true,
    heroColor: const Color(0xFF1D4ED8),
    heroColorEnd: const Color(0xFF6366F1),
  ),
  _Article(
    id: 'n02',
    title: 'ISF Opens New Bengaluru Office — 200 New Positions Available',
    summary:
        'Our Bengaluru expansion goes live with a state-of-the-art 50,000 sq ft campus. Internal referrals welcome.',
    body:
        '''We are thrilled to announce the opening of ISF Solutions' new Bengaluru development centre, our third location after Mumbai and Pune.

**About the New Campus**
📍 Address: 4th Floor, Embassy Golf Links, Bengaluru 560071
📐 Size: 50,000 sq ft, capacity 600 employees
🏋️ Facilities: Gym, cafeteria, gaming zone, meditation room, podcast studio

**200+ Open Positions Across:**
• Software Engineering (Full Stack, Backend, DevOps)
• Data Science & ML
• Product Management
• QA & Testing
• UX Design
• Finance & Accounting

**Internal Referral Bonus**
Refer a qualified candidate and earn ₹50,000 upon their joining and successful completion of 6 months. Refer via the ISmart Portal → Referrals module.

Interviews are currently underway. For internal transfers, please speak with your HR Business Partner.

Join us as we grow! 🚀''',
    category: _Category.company,
    author: 'HR Team',
    publishedOn: '25 Apr 2026',
    readTime: '2 min read',
    isFeatured: true,
    heroColor: const Color(0xFF0D9488),
    heroColorEnd: const Color(0xFF0EA5E9),
  ),
  _Article(
    id: 'n03',
    title: 'India\'s IT Sector Sees 18% Salary Growth in 2026 — Report',
    summary:
        'A new Nasscom report highlights robust hiring and salary growth trends across the Indian IT industry.',
    body:
        '''A new report by Nasscom in partnership with Mercer reveals that India's IT sector has seen an average salary growth of 18% in FY 2026, the highest in five years.

**Key Findings**

1. Demand for AI/ML engineers has grown by 42%, driving up specialisation premiums.
2. Mid-level professionals (4–8 years) are seeing the highest increment offers.
3. Bengaluru, Hyderabad, and Pune remain the hottest hiring markets.
4. Remote-first companies are paying a 12% premium to attract top talent.

**What This Means for ISFians**

ISF's compensation review cycle aligns with industry benchmarks. HR will be sharing individual compensation reviews in the upcoming performance review cycle (May–June 2026).

**Skills in Highest Demand**
• Generative AI & Prompt Engineering
• Cloud Architecture (AWS/Azure/GCP)
• Full Stack (React, Node.js, Flutter)
• Cybersecurity & SIEM

The report surveyed 1,200 organisations across 22 Indian cities.''',
    category: _Category.industry,
    author: 'Research Desk',
    publishedOn: '22 Apr 2026',
    readTime: '4 min read',
    isTrending: true,
    heroColor: const Color(0xFF0D9488),
    heroColorEnd: const Color(0xFF16A34A),
    externalUrl: 'https://nasscom.in/reports',
  ),
  _Article(
    id: 'n04',
    title: 'New WFH Policy: How It Works and What to Expect',
    summary:
        'A detailed breakdown of ISF\'s updated Work From Home policy, effective 1 May 2026.',
    body:
        '''Following employee feedback and industry benchmarking, ISF has updated its Work From Home policy. Here's everything you need to know.

**The Basics**
• Up to 3 WFH days per week, pre-approved by your manager
• Core hours: 10 AM – 4 PM mandatory on WFH days
• No WFH on days with mandatory events or client visits

**How to Request WFH**
1. Log your WFH request via the ISmart Portal → Attendance → WFH Request
2. Your manager gets a notification to approve
3. You'll receive confirmation within 4 hours

**Equipment & Connectivity**
ISF will provide a monthly ₹500 internet reimbursement for WFH days. Submit bills via Conveyance module.

**Who Is Eligible?**
• Permanent employees with 6+ months tenure
• Not applicable during probation or PIPs
• Contract staff — check with your HR BP

**FAQs**
Q: Can I do 4 WFH days in a week?
A: Only with SVP-level approval for exceptional circumstances.

Q: Can I WFH from another city?
A: Yes, with 48-hour advance approval.

Read the full policy in Notices → Policy section.''',
    category: _Category.hr,
    author: 'People & Culture',
    publishedOn: '20 Apr 2026',
    readTime: '3 min read',
    heroColor: const Color(0xFF7C3AED),
    heroColorEnd: const Color(0xFFEC4899),
  ),
  _Article(
    id: 'n05',
    title: 'How ISF Is Using AI to Transform HR Operations',
    summary:
        'From automated payroll to AI-driven talent matching — a look at ISF\'s technology roadmap for HR.',
    body:
        '''ISF's People Tech team has been quietly building an AI layer within the ISmart HR Portal. Here's an inside look at what's coming.

**1. AI-Powered Leave Prediction**
The system now analyses leave patterns to predict approval likelihood before you even submit. It also suggests optimal leave days based on team schedules.

**2. Smart Payslip Assistant**
A conversational interface is being piloted to let employees ask questions like "Why did my net pay decrease this month?" and get an instant breakdown.

**3. Talent Matching Engine**
HR BPs now have access to an AI tool that matches open roles to internal candidates based on skills, experience, and career goals — reducing external hiring costs.

**4. Sentiment Analysis**
Anonymous surveys are now analysed via NLP to surface team-level concerns early, before they escalate.

**What's Next?**
• Voice-enabled attendance log (pilot in Q3 2026)
• Personalised learning recommendations in LMS
• Automated compliance document generation

The roadmap targets full deployment by Q4 2026. Beta participants from each BU are being onboarded through May.''',
    category: _Category.tech,
    author: 'People Tech Team',
    publishedOn: '18 Apr 2026',
    readTime: '5 min read',
    isTrending: true,
    heroColor: const Color(0xFF6366F1),
    heroColorEnd: const Color(0xFF2563EB),
  ),
  _Article(
    id: 'n06',
    title: 'ISF Annual Sports Day 2026 — Registration Open!',
    summary:
        'Gear up for cricket, badminton, carrom, and more. Register your team before 15 May 2026.',
    body: '''The ISF Annual Sports Day 2026 is here — and it's bigger than ever!

📅 Date: 25 May 2026 (Sunday)
📍 Venue: MG Grounds, Dadar, Mumbai
🕗 Reporting: 8:00 AM | Events begin at 9:00 AM

**Events**
🏏 Cricket (5-over, teams of 8) — 3 slots available
🏸 Badminton (Singles & Doubles)
♟ Carrom (Singles & Doubles)
💪 Tug of War (dept-wise)
🏃 100m Sprint (open category)

**How to Register**
1. Open ISmart Portal → More → Sports Day 2026
2. Select your event(s) and add teammates
3. Registration closes: 15 May 2026

**Prizes**
🥇 Gold: Trophy + ₹5,000 Amazon vouchers per team
🥈 Silver: Trophy + ₹2,500 vouchers
🥉 Bronze: Trophy + ₹1,000 vouchers

**Food & Fun**
Free breakfast and lunch for all participants. Evening barbecue and music for all attendees.

Bring your ISF ID cards. Guests and family welcome for the evening event.

Let's play! 🏆''',
    category: _Category.events,
    author: 'Culture Committee',
    publishedOn: '15 Apr 2026',
    readTime: '2 min read',
    heroColor: const Color(0xFFEA580C),
    heroColorEnd: const Color(0xFFF59E0B),
  ),
  _Article(
    id: 'n07',
    title: 'Understanding the New Tax Regime: Should You Switch?',
    summary:
        'Our Finance team breaks down the key differences between old and new IT regimes for FY 2026-27.',
    body:
        '''Every year the same question: Old regime or new? Here's a simple guide for FY 2026-27.

**New Tax Regime (Default)**
Slabs (FY 2026-27):
• Up to ₹3L — Nil
• ₹3–7L — 5%
• ₹7–10L — 10%
• ₹10–12L — 15%
• ₹12–15L — 20%
• Above ₹15L — 30%

Rebate u/s 87A: No tax if income ≤ ₹7L

**Old Tax Regime**
Slabs (FY 2026-27):
• Up to ₹2.5L — Nil
• ₹2.5–5L — 5%
• ₹5–10L — 20%
• Above ₹10L — 30%

Deductions available: 80C (₹1.5L), 80D, HRA, 80E, 80G, standard deduction

**When Old Regime Wins**
If your total deductions (80C + HRA + 80D etc.) exceed ₹3.75L, the old regime typically saves more.

**When New Regime Wins**
For incomes below ₹7L with minimal investments, new regime is usually better.

**ISmart Calculator**
Go to Modules → Tax / IT to use the real-time calculator. It auto-recommends the better regime based on your declarations.

Consult your tax advisor for personalised advice.''',
    category: _Category.hr,
    author: 'Finance Team',
    publishedOn: '10 Apr 2026',
    readTime: '4 min read',
    heroColor: const Color(0xFF16A34A),
    heroColorEnd: const Color(0xFF0D9488),
  ),
  _Article(
    id: 'n08',
    title: 'Flutter 4.0 Released — What\'s New for Developers',
    summary:
        'Google announces Flutter 4.0 with native AI integration, improved performance, and a revamped Material 3 system.',
    body:
        '''Google has officially released Flutter 4.0, marking a significant leap forward for cross-platform development.

**Headline Features**

1. Native Gemini AI Integration
Flutter 4.0 ships with a first-party AI widget library powered by Gemini, enabling on-device LLM inference without external API calls.

2. Performance Improvements
• 40% reduction in cold start time
• Impeller renderer now default on all platforms including web
• 120fps support on more Android devices

3. Material 3 Complete
All Material components now fully implement M3 spec, including adaptive colour schemes and motion tokens.

4. Web & Desktop
• WebAssembly compilation now stable (10× faster web apps)
• Native Windows ARM64 support
• macOS menu bar improvements

5. Dart 3.4
• Pattern matching improvements
• New `when` expressions
• Enhanced async generators

**What This Means for ISmart**
The ISmart HR Portal is built on Flutter. The People Tech team is evaluating migration to Flutter 4.0 for the Q3 2026 release, which will bring significant performance improvements.

Check the full changelog at flutter.dev.''',
    category: _Category.tech,
    author: 'Tech Desk',
    publishedOn: '05 Apr 2026',
    readTime: '5 min read',
    heroColor: const Color(0xFF0EA5E9),
    heroColorEnd: const Color(0xFF6366F1),
    externalUrl: 'https://flutter.dev',
  ),
];

const _filterLabels = [
  'All',
  'Company',
  'Industry',
  'HR & People',
  'Technology',
  'Events'
];

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final List<_Article> _articles = List.from(_articlesData);
  String _activeFilter = 'All';
  String _searchQuery = '';
  bool _showSearch = false;
  final _searchCtrl = TextEditingController();

  // Carousel
  final _carouselCtrl = PageController(viewportFraction: 0.92);
  int _carouselIndex = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _carouselCtrl.dispose();
    _autoScrollTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final featured = _featuredArticles;
      if (featured.isEmpty) return;
      final next = (_carouselIndex + 1) % featured.length;
      _carouselCtrl.animateToPage(next,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  // ── Filters ────────────────────────────────
  List<_Article> get _featuredArticles =>
      _articles.where((a) => a.isFeatured).toList();

  List<_Article> get _trendingArticles =>
      _articles.where((a) => a.isTrending && !a.isFeatured).toList();

  List<_Article> get _filteredArticles {
    List<_Article> list = _articles.where((a) => !a.isFeatured).toList();

    if (_activeFilter != 'All') {
      list = list.where((a) {
        final m = _catMeta(a.category);
        return m.label == _activeFilter;
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((a) =>
              a.title.toLowerCase().contains(q) ||
              a.summary.toLowerCase().contains(q) ||
              a.author.toLowerCase().contains(q))
          .toList();
    }

    return list;
  }

  void _openArticle(_Article article) {
    setState(() => article.isRead = true);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ArticleSheet(
        article: article,
        onBookmark: () =>
            setState(() => article.isBookmarked = !article.isBookmarked),
        onShare: () => _snack('Article link copied to clipboard', _C.textSec),
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

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _buildAppBar(),
      body: Column(children: [
        if (_showSearch) _buildSearchBar(),
        _buildFilterChips(),
        Expanded(child: _buildBody()),
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
        title: const Text('News & Updates',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
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
              final cnt = _articles.where((a) => a.isBookmarked).length;
              _snack(
                  '$cnt article${cnt != 1 ? "s" : ""} bookmarked', _C.textSec);
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
  Widget _buildSearchBar() => Container(
        color: _C.card,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        child: TextField(
          controller: _searchCtrl,
          autofocus: true,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: const TextStyle(fontSize: 14, color: _C.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search news & articles…',
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
                    })
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

  // ─────────────────────────────────────────────
  // FILTER CHIPS
  // ─────────────────────────────────────────────
  Widget _buildFilterChips() => Container(
        color: _C.card,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
              children: _filterLabels.map((label) {
            final active = label == _activeFilter;
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
                  child: Text(label,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: active ? Colors.white : _C.textSec)),
                ),
              ),
            );
          }).toList()),
        ),
      );

  // ─────────────────────────────────────────────
  // BODY
  // ─────────────────────────────────────────────
  Widget _buildBody() {
    final filtered = _filteredArticles;
    final trending = _trendingArticles;

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 48),
      children: [
        // Featured carousel (only when no search/filter active)
        if (_activeFilter == 'All' && _searchQuery.isEmpty) ...[
          _buildCarousel(),
          const SizedBox(height: 18),
        ],

        // Trending section
        if (trending.isNotEmpty &&
            _activeFilter == 'All' &&
            _searchQuery.isEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SectionLabel('🔥 Trending', trending.length),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: trending.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _TrendingCard(
                article: trending[i],
                onTap: () => _openArticle(trending[i]),
                onBookmark: () => setState(
                    () => trending[i].isBookmarked = !trending[i].isBookmarked),
              ),
            ),
          ),
          const SizedBox(height: 18),
        ],

        // All articles
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _SectionLabel(
            _searchQuery.isNotEmpty ? 'Search Results' : 'Latest News',
            filtered.length,
          ),
        ),
        const SizedBox(height: 10),

        if (filtered.isEmpty)
          _EmptyState(query: _searchQuery, filter: _activeFilter)
        else
          ...filtered.map((a) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: _NewsCard(
                  article: a,
                  onTap: () => _openArticle(a),
                  onBookmark: () =>
                      setState(() => a.isBookmarked = !a.isBookmarked),
                ),
              )),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // CAROUSEL
  // ─────────────────────────────────────────────
  Widget _buildCarousel() {
    final featured = _featuredArticles;
    if (featured.isEmpty) return const SizedBox.shrink();

    return Column(children: [
      SizedBox(
        height: 220,
        child: PageView.builder(
          controller: _carouselCtrl,
          itemCount: featured.length,
          onPageChanged: (i) => setState(() => _carouselIndex = i),
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: _FeaturedCard(
              article: featured[i],
              onTap: () => _openArticle(featured[i]),
              onBookmark: () => setState(
                  () => featured[i].isBookmarked = !featured[i].isBookmarked),
            ),
          ),
        ),
      ),
      const SizedBox(height: 10),
      // Dots
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
            featured.length,
            (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _carouselIndex ? 20 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: i == _carouselIndex ? _C.primary : _C.textDisabled,
                    borderRadius: BorderRadius.circular(4),
                  ),
                )),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────
// FEATURED CARD (carousel)
// ─────────────────────────────────────────────
class _FeaturedCard extends StatelessWidget {
  final _Article article;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _FeaturedCard({
    required this.article,
    required this.onTap,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final cat = _catMeta(article.category);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [article.heroColor, article.heroColorEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: article.heroColor.withValues(alpha: .35),
                blurRadius: 14,
                offset: const Offset(0, 5))
          ],
        ),
        child: Stack(children: [
          // Decorative circle
          Positioned(
              right: -20,
              top: -20,
              child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: .08)))),
          Positioned(
              right: 30,
              bottom: -25,
              child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: .05)))),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top: category + bookmark
                Row(children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .2),
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(cat.icon, size: 11, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(cat.label,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ]),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onBookmark,
                    child: Icon(
                      article.isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_outline_rounded,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                ]),

                // Title
                Text(article.title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.3),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),

                // Bottom: author + read time
                Row(children: [
                  const Icon(Icons.person_outline_rounded,
                      size: 12, color: Colors.white60),
                  const SizedBox(width: 4),
                  Expanded(
                      child: Text(article.author,
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white60),
                          overflow: TextOverflow.ellipsis)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .18),
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.schedule_outlined,
                          size: 10, color: Colors.white70),
                      const SizedBox(width: 3),
                      Text(article.readTime,
                          style: const TextStyle(
                              fontSize: 9, color: Colors.white70)),
                    ]),
                  ),
                ]),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TRENDING CARD (horizontal scroll)
// ─────────────────────────────────────────────
class _TrendingCard extends StatelessWidget {
  final _Article article;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _TrendingCard({
    required this.article,
    required this.onTap,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final cat = _catMeta(article.category);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: .04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Category + bookmark
              Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                      color: cat.bg, borderRadius: BorderRadius.circular(20)),
                  child: Text(cat.label,
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: cat.color)),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onBookmark,
                  child: Icon(
                    article.isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    size: 18,
                    color: article.isBookmarked ? _C.primary : _C.textTert,
                  ),
                ),
              ]),

              // Title
              Text(article.title,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary,
                      height: 1.3),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis),

              // Footer
              Row(children: [
                const Icon(Icons.local_fire_department_outlined,
                    size: 12, color: _C.orange),
                const SizedBox(width: 3),
                const Text('Trending',
                    style: TextStyle(
                        fontSize: 9,
                        color: _C.orange,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(article.readTime,
                    style: const TextStyle(fontSize: 9, color: _C.textTert)),
              ]),
            ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// NEWS CARD (main list)
// ─────────────────────────────────────────────
class _NewsCard extends StatelessWidget {
  final _Article article;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _NewsCard({
    required this.article,
    required this.onTap,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final cat = _catMeta(article.category);
    final isUnread = !article.isRead;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isUnread ? _C.primary.withValues(alpha: .2) : _C.border,
              width: isUnread ? 1.5 : 1),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: .04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Colour strip
            Container(
              width: 4,
              height: 70,
              decoration: BoxDecoration(
                  color: article.heroColor,
                  borderRadius: BorderRadius.circular(2)),
              margin: const EdgeInsets.only(right: 12),
            ),

            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Category + read time
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                          color: cat.bg,
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(cat.icon, size: 10, color: cat.color),
                        const SizedBox(width: 3),
                        Text(cat.label,
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: cat.color)),
                      ]),
                    ),
                    if (article.isTrending) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: _C.orangeLight,
                            borderRadius: BorderRadius.circular(20)),
                        child: const Text('🔥', style: TextStyle(fontSize: 9)),
                      ),
                    ],
                    if (article.externalUrl != null) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: _C.surface,
                            borderRadius: BorderRadius.circular(20)),
                        child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.open_in_new_rounded,
                                  size: 9, color: _C.textSec),
                              SizedBox(width: 2),
                              Text('External',
                                  style: TextStyle(
                                      fontSize: 8, color: _C.textSec)),
                            ]),
                      ),
                    ],
                    const Spacer(),
                    if (isUnread)
                      Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: _C.primary, shape: BoxShape.circle)),
                  ]),
                  const SizedBox(height: 7),

                  // Title
                  Text(article.title,
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
                  Text(article.summary,
                      style: const TextStyle(
                          fontSize: 12, color: _C.textSec, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),

                  // Footer
                  Row(children: [
                    const Icon(Icons.person_outline_rounded,
                        size: 11, color: _C.textTert),
                    const SizedBox(width: 3),
                    Expanded(
                        child: Text(article.author,
                            style: const TextStyle(
                                fontSize: 10, color: _C.textTert),
                            overflow: TextOverflow.ellipsis)),
                    const Icon(Icons.schedule_outlined,
                        size: 11, color: _C.textTert),
                    const SizedBox(width: 3),
                    Text(article.readTime,
                        style:
                            const TextStyle(fontSize: 10, color: _C.textTert)),
                    const SizedBox(width: 10),
                    Text(article.publishedOn,
                        style:
                            const TextStyle(fontSize: 10, color: _C.textTert)),
                  ]),
                ])),

            // Bookmark
            GestureDetector(
              onTap: onBookmark,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  article.isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  size: 20,
                  color: article.isBookmarked ? _C.primary : _C.textTert,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ARTICLE DETAIL SHEET
// ─────────────────────────────────────────────
class _ArticleSheet extends StatelessWidget {
  final _Article article;
  final VoidCallback onBookmark;
  final VoidCallback onShare;

  const _ArticleSheet({
    required this.article,
    required this.onBookmark,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final cat = _catMeta(article.category);

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.96,
      minChildSize: 0.5,
      expand: false,
      builder: (_, ctrl) => Column(children: [
        // Fixed header
        Container(
          color: _C.card,
          child: Column(children: [
            const SizedBox(height: 12),
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: _C.border,
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 14),

            // Action bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: cat.bg, borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(cat.icon, size: 12, color: cat.color),
                    const SizedBox(width: 4),
                    Text(cat.label,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: cat.color)),
                  ]),
                ),
                const Spacer(),
                // Share
                IconButton(
                  icon: const Icon(Icons.share_outlined, size: 20),
                  color: _C.textSec,
                  onPressed: () {
                    onShare();
                    Navigator.pop(context);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                // Bookmark
                GestureDetector(
                  onTap: () {
                    onBookmark();
                    Navigator.pop(context);
                  },
                  child: Icon(
                    article.isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    size: 22,
                    color: article.isBookmarked ? _C.primary : _C.textSec,
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 14),
            Container(height: 1, color: _C.border),
          ]),
        ),

        // Scrollable content
        Expanded(
          child: ListView(
            controller: ctrl,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            children: [
              // Title
              Text(article.title,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _C.textPrimary,
                      height: 1.3)),
              const SizedBox(height: 12),

              // Meta strip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                    color: _C.surface, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: article.heroColor, shape: BoxShape.circle),
                    child: Center(
                        child: Text(
                      article.author.isNotEmpty
                          ? article.author[0].toUpperCase()
                          : 'A',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    )),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(article.author,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _C.textPrimary)),
                        Text('${article.publishedOn} · ${article.readTime}',
                            style: const TextStyle(
                                fontSize: 11, color: _C.textSec)),
                      ])),
                  if (article.isTrending)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: _C.orangeLight,
                          borderRadius: BorderRadius.circular(20)),
                      child:
                          const Row(mainAxisSize: MainAxisSize.min, children: [
                        Text('🔥', style: TextStyle(fontSize: 10)),
                        SizedBox(width: 3),
                        Text('Trending',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _C.orange)),
                      ]),
                    ),
                ]),
              ),
              const SizedBox(height: 18),

              // Body
              ..._parseBody(article.body),
              const SizedBox(height: 20),

              // External link
              if (article.externalUrl != null) ...[
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _C.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _C.primary.withValues(alpha: .2)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.open_in_new_rounded,
                          size: 20, color: _C.primary),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            const Text('Read Full Article',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _C.primary)),
                            Text(article.externalUrl!,
                                style: const TextStyle(
                                    fontSize: 11, color: _C.textSec),
                                overflow: TextOverflow.ellipsis),
                          ])),
                    ]),
                  ),
                ),
                const SizedBox(height: 16),
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

  // Simple markdown-ish body parser: renders ** headings and bullet points
  List<Widget> _parseBody(String body) {
    final widgets = <Widget>[];
    final lines = body.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.startsWith('**') && line.endsWith('**')) {
        final text = line.substring(2, line.length - 2);
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(text,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _C.textPrimary)),
        ));
      } else if (line.startsWith('• ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 5),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                width: 5,
                height: 5,
                margin: const EdgeInsets.only(top: 7, right: 8),
                decoration: const BoxDecoration(
                    color: _C.primary, shape: BoxShape.circle)),
            Expanded(
                child: Text(line.substring(2),
                    style: const TextStyle(
                        fontSize: 14, color: _C.textPrimary, height: 1.6))),
          ]),
        ));
      } else if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 6));
      } else if (RegExp(r'^\d+\.').hasMatch(line)) {
        // Numbered list
        final dotIdx = line.indexOf('.');
        final num = line.substring(0, dotIdx + 1);
        final rest = line.substring(dotIdx + 1).trim();
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              width: 22,
              child: Text(num,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _C.primary)),
            ),
            Expanded(
                child: Text(rest,
                    style: const TextStyle(
                        fontSize: 14, color: _C.textPrimary, height: 1.6))),
          ]),
        ));
      } else if (line.startsWith('📅') ||
          line.startsWith('📍') ||
          line.startsWith('🕙') ||
          line.startsWith('📐') ||
          line.startsWith('🏋️') ||
          line.startsWith('🥇') ||
          line.startsWith('🥈') ||
          line.startsWith('🥉') ||
          line.startsWith('🏏') ||
          line.startsWith('🏸') ||
          line.startsWith('♟') ||
          line.startsWith('💪') ||
          line.startsWith('🏃')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 5),
          child: Text(line,
              style: const TextStyle(
                  fontSize: 14, color: _C.textPrimary, height: 1.6)),
        ));
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(line,
              style: const TextStyle(
                  fontSize: 14, color: _C.textPrimary, height: 1.7)),
        ));
      }
    }
    return widgets;
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
  Widget build(BuildContext context) => Row(children: [
        Text(label,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _C.textPrimary)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
              color: _C.surface, borderRadius: BorderRadius.circular(10)),
          child: Text('$count',
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _C.textSec)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 1, color: _C.border)),
      ]);
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
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(
              query.isNotEmpty
                  ? Icons.search_off_rounded
                  : Icons.newspaper_outlined,
              size: 52,
              color: _C.textDisabled,
            ),
            const SizedBox(height: 14),
            Text(
              query.isNotEmpty
                  ? 'No results for "$query"'
                  : 'No $filter news yet',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text('Check back later for updates.',
                style: TextStyle(fontSize: 13, color: _C.textSec)),
          ]),
        ),
      );
}

// expose mock articles under a different name to avoid naming conflict
final _articlesData = _articles; // forward ref resolved at runtime
