import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class AllModuleScreen extends StatefulWidget {
  const AllModuleScreen({super.key});

  @override
  State<AllModuleScreen> createState() => _AllModuleScreenState();
}

class _AllModuleScreenState extends State<AllModuleScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Personal',
    'Attendance',
    'Payroll',
    'Self Service',
    'Learning',
    'Settings'
  ];

  final List<Map<String, dynamic>> _modules = [
    {'label': 'Employee Details', 'icon': Icons.badge, 'color': Colors.blue, 'route': '/employee_details', 'category': 'Personal'},
    {'label': 'My Profile', 'icon': Icons.person, 'color': Colors.indigo, 'route': '/my_profile', 'category': 'Personal'},
    {'label': 'Documents', 'icon': Icons.description, 'color': Colors.teal, 'route': '/documents', 'category': 'Personal'},
    {'label': 'Contact HR', 'icon': Icons.headset_mic, 'color': Colors.green, 'route': '/contact_hr', 'category': 'Personal'},
    
    {'label': 'Monthly Report', 'icon': Icons.bar_chart, 'color': Colors.blue, 'route': '/monthly_report', 'category': 'Attendance', 'new': true},
    {'label': 'Reliever', 'icon': Icons.people_alt, 'color': Colors.purple, 'route': '/reliever', 'category': 'Attendance'},
    {'label': 'Leave Apply', 'icon': Icons.event_note, 'color': Colors.orange, 'route': '/leave_apply', 'category': 'Attendance'},
    {'label': 'Leave Balance', 'icon': Icons.event_available, 'color': Colors.green, 'route': '/leave_balance', 'category': 'Attendance'},
    {'label': 'Overtime', 'icon': Icons.timer, 'color': Colors.red, 'route': '/overtime', 'category': 'Attendance'},
    {'label': 'Tour Request', 'icon': Icons.flight_takeoff, 'color': Colors.teal, 'route': '/tour_request', 'category': 'Attendance'},
    {'label': 'Holiday List', 'icon': Icons.beach_access, 'color': Colors.amber.shade700, 'route': '/holiday_list', 'category': 'Attendance'},
    {'label': 'Regularize', 'icon': Icons.edit_calendar, 'color': Colors.indigo, 'route': '/regularize', 'category': 'Attendance'},
    
    {'label': 'Payslip', 'icon': Icons.receipt_long, 'color': Colors.green, 'route': '/payslip', 'category': 'Payroll', 'new': true},
    {'label': 'ESIC Form', 'icon': Icons.health_and_safety, 'color': Colors.blue, 'route': '/esic', 'category': 'Payroll'},
    {'label': 'PF Details', 'icon': Icons.account_balance, 'color': Colors.teal, 'route': '/pf_details', 'category': 'Payroll'},
    {'label': 'Benefits', 'icon': Icons.card_giftcard, 'color': Colors.purple, 'route': '/benefits', 'category': 'Payroll'},
    {'label': 'Advance', 'icon': Icons.payments, 'color': Colors.orange, 'route': '/advance', 'category': 'Payroll'},
    {'label': 'Tax / IT', 'icon': Icons.calculate, 'color': Colors.red, 'route': '/tax', 'category': 'Payroll'},
    
    {'label': 'Uniform Size', 'icon': Icons.checkroom, 'color': Colors.indigo, 'route': '/uniform', 'category': 'Self Service'},
    {'label': 'Conveyance', 'icon': Icons.directions_car, 'color': Colors.blue, 'route': '/conveyance', 'category': 'Self Service'},
    {'label': 'Tickets', 'icon': Icons.confirmation_number, 'color': Colors.orange, 'route': '/tickets', 'category': 'Self Service'},
    {'label': 'Voice Messages', 'icon': Icons.mic, 'color': Colors.purple, 'route': '/voice_messages', 'category': 'Self Service'},
    
    {'label': 'LMS Training', 'icon': Icons.school, 'color': Colors.blue, 'route': '/lms', 'category': 'Learning'},
    {'label': 'Grooming Std.', 'icon': Icons.star, 'color': Colors.amber.shade700, 'route': '/grooming', 'category': 'Learning'},
    {'label': 'Career Path', 'icon': Icons.trending_up, 'color': Colors.green, 'route': '/career_path', 'category': 'Learning'},
    {'label': 'Certificates', 'icon': Icons.workspace_premium, 'color': Colors.teal, 'route': '/certificates', 'category': 'Learning'},
    {'label': 'Feedback', 'icon': Icons.rate_review, 'color': Colors.orange, 'route': '/feedback', 'category': 'Learning'},
    {'label': 'Goals', 'icon': Icons.flag, 'color': Colors.red, 'route': '/goals', 'category': 'Learning'},
    {'label': 'Language', 'icon': Icons.translate, 'color': Colors.indigo, 'route': '/language', 'category': 'Learning'},
    {'label': 'My Reports', 'icon': Icons.insights, 'color': Colors.blue, 'route': '/my_reports', 'category': 'Learning'},
    
    {'label': 'Notifications', 'icon': Icons.notifications, 'color': Colors.orange, 'route': '/notifications', 'category': 'Settings'},
    {'label': 'Notices', 'icon': Icons.campaign, 'color': Colors.teal, 'route': '/notices', 'category': 'Settings'},
    {'label': 'Help & Support', 'icon': Icons.help, 'color': Colors.green, 'route': '/help', 'category': 'Settings'},
    {'label': 'News & Updates', 'icon': Icons.newspaper, 'color': Colors.blue, 'route': '/news', 'category': 'Settings'},
    {'label': 'Settings', 'icon': Icons.settings, 'color': Colors.grey, 'route': '/settings', 'category': 'Settings'},
    {'label': 'Logout', 'icon': Icons.logout, 'color': Colors.red, 'route': null, 'category': 'Settings'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(context),
          ),
          ..._buildFilteredSections(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF002D1F),
            Color(0xFF003F2D),
            Color(0xFF004D38),
            Color(0xFF005A40),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All Modules',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    ),
                  ),
                  Text(
                    'Everything you need, in one place',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tune, color: Colors.white, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 16),
          _buildCategoryPills(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.white.withValues(alpha: 0.6), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  cursorColor: Colors.white,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search modules...',
                    hintStyle: GoogleFonts.dmSans(
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : Colors.white.withValues(alpha: 0.1),
                  border: Border.all(
                    color: isSelected ? AppColors.accent : Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected 
                      ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 3))]
                      : [],
                ),
                child: Text(
                  category,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? const Color(0xFF002D1F) : Colors.white.withValues(alpha: 0.75),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildFilteredSections() {
    List<Widget> slivers = [];
    
    final categoriesToRender = _selectedCategory == 'All' 
        ? _categories.where((c) => c != 'All').toList() 
        : [_selectedCategory];

    for (var category in categoriesToRender) {
      final categoryModules = _modules.where((m) {
        final matchesCategory = m['category'] == category;
        final matchesSearch = m['label'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();

      if (categoryModules.isNotEmpty) {
        slivers.add(
          SliverToBoxAdapter(
            child: _buildSectionHeader(category),
          ),
        );
        slivers.add(
          SliverPadding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 12,
                childAspectRatio: 0.65,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _QuickAccessItem(module: categoryModules[index]);
                },
                childCount: categoryModules.length,
              ),
            ),
          ),
        );
      }
    }
    
    slivers.add(const SliverPadding(padding: EdgeInsets.only(bottom: 40)));

    if (slivers.length == 1) { // Only the bottom padding
      return [
        SliverFillRemaining(
          child: Center(
            child: Text(
              'No modules found.',
              style: GoogleFonts.dmSans(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ];
    }

    return slivers;
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 16, 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.accent, AppColors.successDark],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF4A7C6B),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAccessItem extends StatefulWidget {
  final Map<String, dynamic> module;
  const _QuickAccessItem({required this.module});

  @override
  State<_QuickAccessItem> createState() => _QuickAccessItemState();
}

class _QuickAccessItemState extends State<_QuickAccessItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        if (widget.module['route'] != null) {
          context.push(widget.module['route']);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${widget.module['label']} action completed')),
          );
        }
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(color: Color(0x19003F2D), blurRadius: 12, offset: Offset(0, 3)),
                  BoxShadow(color: Color(0x0C003F2D), blurRadius: 0, spreadRadius: 1),
                ],
              ),
              alignment: Alignment.center,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    widget.module['icon'],
                    color: widget.module['color'],
                    size: 26,
                  ),
                  if (widget.module['new'] == true)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5252),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                widget.module['label'],
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
