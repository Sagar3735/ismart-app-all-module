// ============================================================
// ISF HR Portal — My Profile Screen
// File: lib/screens/personal/my_profile_screen.dart
//
// Features:
//   - Read / Edit mode toggle
//   - Photo picker bottom sheet
//   - 3 sections: Personal Info, Contact Info, Emergency Contact
//   - Preferences section (language + notification toggles)
//   - Field-level validation on Save
//   - Animated save button with loading state
//
// Dependencies (already in pubspec.yaml):
//   cached_network_image, provider
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ─── Replace with actual imports ──────────────────────────
// import '../../theme/app_colors.dart';
// import '../../theme/app_text_styles.dart';
// import '../../data/mock_data.dart';
// ──────────────────────────────────────────────────────────

// ─────────────────────────────────────────────
// INLINE THEME
// ─────────────────────────────────────────────
class _C {
  static const primary = Color(0xFF2563EB);
  static const primaryLight = Color(0xFFEFF6FF);
  static const successLight = Color(0xFFDCFCE7);
  static const successDark = Color(0xFF16A34A);
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFEF2F2);
  static const bg = Color(0xFFF8FAFC);
  static const card = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF0F172A);
  static const textSec = Color(0xFF64748B);
  static const textTert = Color(0xFF94A3B8);
  static const textDisabled = Color(0xFFCBD5E1);
  static const border = Color(0xFFE2E8F0);
  static const borderFocus = Color(0xFF2563EB);
}

// ─────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────
class _ProfileData {
  String firstName = 'Amit';
  String lastName = 'Patil';
  String dob = '23 Apr 1997';
  String gender = 'Male';
  String bloodGroup = 'B+';
  String maritalStatus = 'Married';
  String mobile = '+91 98765 43210';
  String altPhone = '+91 91234 56789';
  String personalEmail = 'amit.patil.personal@gmail.com';
  String address =
      '12, Shivaji Nagar, Wadala East, Mumbai – 400037, Maharashtra';
  String emergName = 'Sunita Patil';
  String emergRelation = 'Spouse';
  String emergPhone = '+91 91234 56789';
  String language = 'English';
  bool notifLeave = true;
  bool notifPayslip = true;
  bool notifAttendance = true;
  bool notifNotice = true;
  String get fullName => '$firstName $lastName';
  static const photo = 'https://i.pravatar.cc/150?img=12';
  static const id = 'ISF-2024-0042';
  static const designation = 'Full Stack Developer';
  static const department = 'Information Technology';
}

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen>
    with SingleTickerProviderStateMixin {
  // ── State ───────────────────────────────────
  bool _editMode = false;
  bool _saving = false;
  bool _hasChanges = false;
  final _formKey = GlobalKey<FormState>();
  final _data = _ProfileData();

  // ── Controllers ─────────────────────────────
  late final _firstNameCtrl = TextEditingController(text: _data.firstName);
  late final _lastNameCtrl = TextEditingController(text: _data.lastName);
  late final _mobileCtrl = TextEditingController(text: _data.mobile);
  late final _altPhoneCtrl = TextEditingController(text: _data.altPhone);
  late final _emailCtrl = TextEditingController(text: _data.personalEmail);
  late final _addressCtrl = TextEditingController(text: _data.address);
  late final _emergNameCtrl = TextEditingController(text: _data.emergName);
  late final _emergRelCtrl = TextEditingController(text: _data.emergRelation);
  late final _emergPhoneCtrl = TextEditingController(text: _data.emergPhone);

  // ── Scroll ──────────────────────────────────
  final _scrollCtrl = ScrollController();
  bool _collapsed = false;

  // ── Dropdown values ─────────────────────────
  String? _gender, _bloodGroup, _maritalStatus, _language;

  @override
  void initState() {
    super.initState();
    _gender = _data.gender;
    _bloodGroup = _data.bloodGroup;
    _maritalStatus = _data.maritalStatus;
    _language = _data.language;
    _scrollCtrl.addListener(_onScroll);
    for (final c in _allControllers) {
      c.addListener(() => setState(() => _hasChanges = true));
    }
  }

  List<TextEditingController> get _allControllers => [
        _firstNameCtrl,
        _lastNameCtrl,
        _mobileCtrl,
        _altPhoneCtrl,
        _emailCtrl,
        _addressCtrl,
        _emergNameCtrl,
        _emergRelCtrl,
        _emergPhoneCtrl,
      ];

  void _onScroll() {
    final collapsed = _scrollCtrl.offset > 100;
    if (collapsed != _collapsed) setState(() => _collapsed = collapsed);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    for (final c in _allControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Edit / Save / Cancel ────────────────────
  void _toggleEdit() {
    setState(() {
      _editMode = true;
      _hasChanges = false;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 1300));
    setState(() {
      _saving = false;
      _editMode = false;
      _hasChanges = false;
      _data.firstName = _firstNameCtrl.text;
      _data.lastName = _lastNameCtrl.text;
      _data.gender = _gender ?? _data.gender;
      _data.bloodGroup = _bloodGroup ?? _data.bloodGroup;
      _data.maritalStatus = _maritalStatus ?? _data.maritalStatus;
      _data.mobile = _mobileCtrl.text;
      _data.altPhone = _altPhoneCtrl.text;
      _data.personalEmail = _emailCtrl.text;
      _data.address = _addressCtrl.text;
      _data.emergName = _emergNameCtrl.text;
      _data.emergRelation = _emergRelCtrl.text;
      _data.emergPhone = _emergPhoneCtrl.text;
      _data.language = _language ?? _data.language;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(_snackbar(
        'Profile updated successfully ✅',
        _C.successDark,
      ));
    }
  }

  void _cancel() {
    setState(() {
      _editMode = false;
      _hasChanges = false;
      _firstNameCtrl.text = _data.firstName;
      _lastNameCtrl.text = _data.lastName;
      _mobileCtrl.text = _data.mobile;
      _altPhoneCtrl.text = _data.altPhone;
      _emailCtrl.text = _data.personalEmail;
      _addressCtrl.text = _data.address;
      _emergNameCtrl.text = _data.emergName;
      _emergRelCtrl.text = _data.emergRelation;
      _emergPhoneCtrl.text = _data.emergPhone;
      _gender = _data.gender;
      _bloodGroup = _data.bloodGroup;
      _maritalStatus = _data.maritalStatus;
      _language = _data.language;
    });
  }

  SnackBar _snackbar(String msg, Color bg) => SnackBar(
        content: Text(msg,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      );

  // ── Photo picker sheet ───────────────────────
  void _showPhotoPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _PhotoPickerSheet(),
    );
  }

  // ── Build ────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: Form(
        key: _formKey,
        child: NestedScrollView(
          controller: _scrollCtrl,
          headerSliverBuilder: (_, inner) => [_buildAppBar(inner)],
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              _buildHeroCard(),
              const SizedBox(height: 16),
              _buildSection(
                title: 'Personal Information',
                icon: Icons.person_outline_rounded,
                children: _buildPersonalFields(),
              ),
              const SizedBox(height: 12),
              _buildSection(
                title: 'Contact Information',
                icon: Icons.contact_phone_outlined,
                children: _buildContactFields(),
              ),
              const SizedBox(height: 12),
              _buildSection(
                title: 'Emergency Contact',
                icon: Icons.emergency_outlined,
                children: _buildEmergencyFields(),
              ),
              const SizedBox(height: 12),
              _buildSection(
                title: 'Preferences',
                icon: Icons.tune_rounded,
                children: _buildPreferenceFields(),
              ),
              const SizedBox(height: 24),
              if (_editMode) _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // ── App Bar ──────────────────────────────────
  Widget _buildAppBar(bool innerScrolled) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: _C.card,
      surfaceTintColor: Colors.transparent,
      elevation: innerScrolled ? 1 : 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        color: _C.textPrimary,
        onPressed: () {
          if (_editMode && _hasChanges) {
            _showDiscardDialog();
          } else {
            context.pop();
          }
        },
      ),
      title: AnimatedOpacity(
        opacity: _collapsed ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_data.fullName,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _C.textPrimary)),
            const Text(_ProfileData.designation,
                style: TextStyle(fontSize: 11, color: _C.textSec)),
          ],
        ),
      ),
      actions: [
        if (!_editMode)
          TextButton.icon(
            onPressed: _toggleEdit,
            icon: const Icon(Icons.edit_outlined, size: 16, color: _C.primary),
            label: const Text('Edit',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _C.primary)),
          )
        else
          TextButton(
            onPressed: _saving ? null : _cancel,
            child: Text('Cancel',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _saving ? _C.textDisabled : _C.textSec)),
          ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Hero card ────────────────────────────────
  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
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
                  border: Border.all(color: _C.primary, width: 2.5),
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: _ProfileData.photo,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _avatarPlaceholder(36),
                    errorWidget: (_, __, ___) => _avatarPlaceholder(36),
                  ),
                ),
              ),
              if (_editMode)
                GestureDetector(
                  onTap: _showPhotoPicker,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: _C.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: _C.card, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        size: 15, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(_data.fullName,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary,
                  letterSpacing: -0.3)),
          const SizedBox(height: 2),
          const Text(_ProfileData.designation,
              style: TextStyle(fontSize: 13, color: _C.textSec)),
          const SizedBox(height: 2),
          const Text(_ProfileData.department,
              style: TextStyle(fontSize: 12, color: _C.textTert)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _heroBadge(_ProfileData.id, Icons.badge_outlined, _C.primary,
                  _C.primaryLight),
              const SizedBox(width: 8),
              _heroBadge(
                  'Active', Icons.circle, _C.successDark, _C.successLight),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatarPlaceholder(double fontSize) => Container(
        color: _C.primaryLight,
        child: Center(
          child: Text('AP',
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: _C.primary)),
        ),
      );

  Widget _heroBadge(String label, IconData icon, Color color, Color bg) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ]),
      );

  // ── Section wrapper ──────────────────────────
  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    color: _C.primaryLight,
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 15, color: _C.primary),
              ),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _C.textPrimary)),
            ]),
          ),
          Container(height: 1, color: _C.border),
          ...children,
        ],
      ),
    );
  }

  // ── Personal Info fields ─────────────────────
  List<Widget> _buildPersonalFields() => [
        _fieldRow('First Name', _firstNameCtrl,
            isLast: false,
            validator: (v) =>
                v!.trim().isEmpty ? 'First name is required' : null),
        _fieldRow('Last Name', _lastNameCtrl,
            isLast: false,
            validator: (v) =>
                v!.trim().isEmpty ? 'Last name is required' : null),
        _dropdownRow('Date of Birth', _data.dob, [],
            isReadOnly: true, isLast: false),
        _dropdownFieldRow(
          'Gender',
          _gender,
          ['Male', 'Female', 'Other'],
          onChanged: (v) => setState(() => _gender = v),
          isLast: false,
        ),
        _dropdownFieldRow(
          'Blood Group',
          _bloodGroup,
          ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
          onChanged: (v) => setState(() => _bloodGroup = v),
          valueColor: _C.error,
          valueBg: _C.errorLight,
          isLast: false,
        ),
        _dropdownFieldRow(
          'Marital Status',
          _maritalStatus,
          ['Single', 'Married', 'Divorced', 'Widowed'],
          onChanged: (v) => setState(() => _maritalStatus = v),
          isLast: true,
        ),
      ];

  // ── Contact Info fields ──────────────────────
  List<Widget> _buildContactFields() => [
        _fieldRow('Mobile Number', _mobileCtrl,
            keyboard: TextInputType.phone, isLast: false, validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Mobile is required';
          final digits = v.replaceAll(RegExp(r'\D'), '');
          if (digits.length < 10) return 'Enter a valid 10-digit number';
          return null;
        }),
        _fieldRow('Alternate Number', _altPhoneCtrl,
            keyboard: TextInputType.phone, isLast: false),
        _fieldRow('Personal Email', _emailCtrl,
            keyboard: TextInputType.emailAddress,
            isLast: false, validator: (v) {
          if (v == null || v.trim().isEmpty) return null;
          final emailReg = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
          if (!emailReg.hasMatch(v)) return 'Enter a valid email';
          return null;
        }),
        _multilineFieldRow('Current Address', _addressCtrl, isLast: true),
      ];

  // ── Emergency Contact fields ─────────────────
  List<Widget> _buildEmergencyFields() => [
        _fieldRow('Full Name', _emergNameCtrl,
            isLast: false,
            validator: (v) => v!.trim().isEmpty
                ? 'Emergency contact name is required'
                : null),
        _fieldRow('Relationship', _emergRelCtrl, isLast: false),
        _fieldRow('Phone Number', _emergPhoneCtrl,
            keyboard: TextInputType.phone, isLast: true, validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Phone is required';
          return null;
        }),
      ];

  // ── Preferences ──────────────────────────────
  List<Widget> _buildPreferenceFields() => [
        _dropdownFieldRow(
          'App Language',
          _language,
          ['English', 'Hindi', 'Marathi', 'Tamil', 'Telugu', 'Bengali'],
          onChanged: (v) => setState(() => _language = v),
          isLast: false,
        ),
        _notifToggleRow('Leave Updates', _data.notifLeave,
            (v) => setState(() => _data.notifLeave = v),
            isLast: false),
        _notifToggleRow('Payslip Alerts', _data.notifPayslip,
            (v) => setState(() => _data.notifPayslip = v),
            isLast: false),
        _notifToggleRow('Attendance Alerts', _data.notifAttendance,
            (v) => setState(() => _data.notifAttendance = v),
            isLast: false),
        _notifToggleRow('Notice Board', _data.notifNotice,
            (v) => setState(() => _data.notifNotice = v),
            isLast: true),
      ];

  // ─────────────────────────────────────────────
  // FIELD BUILDERS
  // ─────────────────────────────────────────────

  Widget _fieldRow(
    String label,
    TextEditingController ctrl, {
    TextInputType? keyboard,
    String? Function(String?)? validator,
    bool isLast = false,
  }) {
    return _rowWrapper(
      label: label,
      isLast: isLast,
      child: _editMode
          ? _inputField(ctrl, keyboard: keyboard, validator: validator)
          : _readText(ctrl.text),
    );
  }

  Widget _multilineFieldRow(
    String label,
    TextEditingController ctrl, {
    bool isLast = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(children: [
            Text(label,
                style: const TextStyle(fontSize: 12, color: _C.textSec)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
          child: _editMode
              ? TextFormField(
                  controller: ctrl,
                  maxLines: 3,
                  maxLength: 200,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _C.textPrimary),
                  decoration: _inputDeco(null, counter: true),
                )
              : Text(ctrl.text,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _C.textPrimary),
                  maxLines: 3),
        ),
        if (!isLast)
          Container(
              height: 1,
              color: _C.border,
              margin: const EdgeInsets.symmetric(horizontal: 16)),
      ],
    );
  }

  Widget _dropdownRow(
    String label,
    String value,
    List<String> options, {
    bool isReadOnly = false,
    bool isLast = false,
  }) {
    return _rowWrapper(
      label: label,
      isLast: isLast,
      child: _readText(value),
    );
  }

  Widget _dropdownFieldRow(
    String label,
    String? value,
    List<String> options, {
    required void Function(String?) onChanged,
    Color? valueColor,
    Color? valueBg,
    bool isLast = false,
  }) {
    return _rowWrapper(
      label: label,
      isLast: isLast,
      child: _editMode
          ? SizedBox(
              height: 38,
              child: DropdownButtonFormField<String>(
                initialValue: value,
                onChanged: onChanged,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _C.textPrimary),
                decoration: _inputDeco(null).copyWith(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8)),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    size: 18, color: _C.textSec),
                items: options
                    .map((o) => DropdownMenuItem(
                          value: o,
                          child: Text(o, style: const TextStyle(fontSize: 13)),
                        ))
                    .toList(),
              ),
            )
          : (valueBg != null
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: valueBg, borderRadius: BorderRadius.circular(6)),
                  child: Text(value ?? '—',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: valueColor ?? _C.textPrimary)),
                )
              : _readText(value ?? '—')),
    );
  }

  Widget _notifToggleRow(
    String label,
    bool value,
    void Function(bool) onChanged, {
    bool isLast = false,
  }) {
    return _rowWrapper(
      label: label,
      isLast: isLast,
      child: Transform.scale(
        scale: 0.85,
        alignment: Alignment.centerRight,
        child: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: _C.primary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  // ── Row wrapper ──────────────────────────────
  Widget _rowWrapper({
    required String label,
    required Widget child,
    required bool isLast,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 130,
                child: Text(label,
                    style: const TextStyle(fontSize: 12, color: _C.textSec)),
              ),
              const SizedBox(width: 8),
              Expanded(child: child),
            ],
          ),
        ),
        if (!isLast)
          Container(
              height: 1,
              color: _C.border,
              margin: const EdgeInsets.symmetric(horizontal: 16)),
      ],
    );
  }

  // ── Input helpers ────────────────────────────
  Widget _inputField(
    TextEditingController ctrl, {
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      height: 38,
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w500, color: _C.textPrimary),
        decoration: _inputDeco(null),
      ),
    );
  }

  Widget _readText(String text) => Text(
        text.isEmpty ? '—' : text,
        style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: text.isEmpty ? _C.textTert : _C.textPrimary),
        textAlign: TextAlign.end,
        overflow: TextOverflow.ellipsis,
      );

  InputDecoration _inputDeco(String? hint, {bool counter = false}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: _C.textTert),
        filled: true,
        fillColor: _C.bg,
        isDense: true,
        counterText: counter ? null : '',
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _C.border, width: 1.5)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _C.border, width: 1.5)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _C.borderFocus, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _C.error, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _C.error, width: 1.5)),
        errorStyle: const TextStyle(fontSize: 11, color: _C.error),
      );

  // ── Action buttons ───────────────────────────
  Widget _buildActionButtons() {
    return Column(children: [
      SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: _C.primary,
            disabledBackgroundColor: _C.textDisabled,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: _saving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : const Text('Save Changes',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: _saving ? null : _cancel,
          style: OutlinedButton.styleFrom(
            foregroundColor: _C.textSec,
            side: const BorderSide(color: _C.border, width: 1.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Cancel',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        ),
      ),
    ]);
  }

  // ── Discard dialog ───────────────────────────
  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Discard changes?',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary)),
        content: const Text(
            'You have unsaved changes. Are you sure you want to discard them?',
            style: TextStyle(fontSize: 14, color: _C.textSec)),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Keep Editing',
                style:
                    TextStyle(color: _C.primary, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              _cancel();
              context.pop();
            },
            child: const Text('Discard',
                style: TextStyle(color: _C.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PHOTO PICKER BOTTOM SHEET
// ─────────────────────────────────────────────
class _PhotoPickerSheet extends StatelessWidget {
  final _options = const [
    (Icons.camera_alt_outlined, 'Take Photo', 'Open camera'),
    (
      Icons.photo_library_outlined,
      'Choose from Gallery',
      'Pick from your photos'
    ),
    (Icons.delete_outline_rounded, 'Remove Photo', 'Reset to default avatar'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: _C.border, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 18),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Update Profile Photo',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: _C.textPrimary)),
          ),
          const SizedBox(height: 4),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Choose how you\'d like to update your photo',
                style: TextStyle(fontSize: 13, color: _C.textSec)),
          ),
          const SizedBox(height: 16),
          ..._options.map((opt) {
            final (icon, title, sub) = opt;
            final isRemove = title == 'Remove Photo';
            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: isRemove ? _C.errorLight : _C.primaryLight,
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon,
                    size: 20, color: isRemove ? _C.error : _C.primary),
              ),
              title: Text(title,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isRemove ? _C.error : _C.textPrimary)),
              subtitle: Text(sub,
                  style: const TextStyle(fontSize: 12, color: _C.textSec)),
              onTap: () {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$title — feature coming soon'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.all(16),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
