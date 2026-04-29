import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../providers/employee_provider.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  bool _isEditing = false;
  bool _isLoading = false;

  void _toggleEdit() async {
    if (_isEditing) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 1200));
      setState(() {
        _isLoading = false;
        _isEditing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully ✅'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      setState(() => _isEditing = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final employee = context.watch<EmployeeProvider>().employee;
    if (employee == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            pinned: true,
            title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.w600)),
            actions: [
              TextButton(
                onPressed: _isLoading ? null : _toggleEdit,
                child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_isEditing ? 'Save' : 'Edit', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildHeroSection(employee),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildSectionCard('Personal Info', [
                        _buildField('First Name', employee.name.split(' ').first),
                        _buildField('Last Name', employee.name.split(' ').length > 1 ? employee.name.split(' ').last : ''),
                        _buildField('Date of Birth', '15 Aug 1990'),
                        _buildField('Gender', 'Male'),
                        _buildField('Blood Group', employee.bloodGroup),
                      ]),
                      const SizedBox(height: 16),
                      _buildSectionCard('Contact Info', [
                        _buildField('Mobile Number', employee.phone),
                        _buildField('Personal Email', employee.email),
                        _buildField('Current Address', employee.workLocation),
                      ]),
                      const SizedBox(height: 16),
                      _buildSectionCard('Preferences', [
                        _buildField('App Language', 'English'),
                        _buildSwitch('Leave Updates', true),
                        _buildSwitch('Payslip Alerts', true),
                      ]),
                      const SizedBox(height: 40),
                      if (_isEditing)
                         SizedBox(
                           width: double.infinity,
                           height: 52,
                           child: ElevatedButton(
                             style: ElevatedButton.styleFrom(
                               backgroundColor: AppColors.primary,
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                             ),
                             onPressed: _isLoading ? null : _toggleEdit,
                             child: _isLoading 
                               ? const CircularProgressIndicator(color: Colors.white)
                               : const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                           ),
                         )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(dynamic employee) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 3),
                  image: DecorationImage(
                    image: NetworkImage(employee.profilePhoto),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (_isEditing)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(employee.name, style: AppTextStyles.heading2),
          const SizedBox(height: 4),
          Text('${employee.designation} · ${employee.department}', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.successDark, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('Active Employee', style: AppTextStyles.caption.copyWith(color: AppColors.successDark, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          _isEditing 
            ? TextFormField(
                initialValue: value,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                ),
              )
            : Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSwitch(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
          Switch(
            value: value,
            onChanged: _isEditing ? (v) {} : null,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
