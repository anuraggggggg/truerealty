import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/provider/employee_provider.dart';
import 'package:truerealtycrm/provider/auth_provider.dart';
import 'package:truerealtycrm/widget/app_loading.dart';

class PersonalSettingsScreen extends StatefulWidget {
  const PersonalSettingsScreen({super.key});

  @override
  State<PersonalSettingsScreen> createState() => _PersonalSettingsScreenState();
}

class _PersonalSettingsScreenState extends State<PersonalSettingsScreen> {
  final _profileKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _employeeId;
  String? _imageUrl;
  bool _loading = true;
  bool _savingProfile = false;
  bool _savingPassword = false;
  bool _hidePassword = true;
  bool _hideConfirmation = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    final provider = context.read<EmployeeProvider>();
    final response = await provider.fetchCurrentEmployee();
    if (!mounted) return;
    final profile = _settingsMap(response?.data);
    if (profile.isEmpty) {
      setState(() {
        _loading = false;
        _loadError = provider.error ?? 'Unable to load your profile.';
      });
      return;
    }
    setState(() {
      _employeeId = _settingText(profile, const ['id', 'employeeId']);
      _nameController.text = _settingText(profile, const ['fullName', 'name']);
      _emailController.text = _settingText(profile, const ['email']);
      _phoneController.text = _settingText(profile, const ['phone', 'mobile']);
      _addressController.text = _settingText(profile, const ['address']);
      _imageUrl = _settingText(profile, const ['image', 'imageUrl']);
      _loading = false;
    });
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();
    if (!_profileKey.currentState!.validate() || _employeeId == null) return;
    setState(() => _savingProfile = true);
    final provider = context.read<EmployeeProvider>();
    final response = await provider.updateEmployee(
      employeeId: _employeeId!,
      body: {
        'fullName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
      },
    );
    if (!mounted) return;
    setState(() => _savingProfile = false);
    _showResult(
      response != null ? 'Profile updated successfully.' : provider.error,
      isError: response == null,
    );
  }

  Future<void> _savePassword() async {
    FocusScope.of(context).unfocus();
    if (!_passwordKey.currentState!.validate() || _employeeId == null) return;
    setState(() => _savingPassword = true);
    final provider = context.read<EmployeeProvider>();
    final response = await provider.updateEmployee(
      employeeId: _employeeId!,
      body: {'password': _passwordController.text},
    );
    if (!mounted) return;
    setState(() => _savingPassword = false);
    if (response != null) {
      _passwordController.clear();
      _confirmPasswordController.clear();
    }
    _showResult(
      response != null ? 'Password updated successfully.' : provider.error,
      isError: response == null,
    );
  }

  void _showResult(String? message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Something went wrong.'),
        backgroundColor: isError ? const Color(0xFFD92D20) : AppColors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          'Settings',
          style: GoogleFonts.inter(
            color: AppColors.navy,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: AppListSkeleton(itemCount: 3, itemHeight: 180),
              )
            : _loadError != null
            ? _SettingsError(message: _loadError!, onRetry: _loadProfile)
            : LayoutBuilder(
                builder: (context, constraints) {
                  final horizontal = constraints.maxWidth >= 900;
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth >= 600 ? 32 : 16,
                      vertical: 24,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1360),
                        child: Builder(builder: (context) {
                          final authProvider = context.watch<AuthProvider>();
                          final isRestrictedRole = authProvider.role == UserRole.telecaller ||
                              authProvider.role == UserRole.fieldExecutive;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Personal Settings',
                                style: GoogleFonts.inter(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.navy,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                isRestrictedRole
                                    ? 'Update your personal details.'
                                    : 'Update your personal details and manage your account password.',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.mutedNavy,
                                ),
                              ),
                              const SizedBox(height: 22),
                              if (horizontal)
                                IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(child: _buildProfileCard()),
                                      if (!isRestrictedRole) ...[
                                        const SizedBox(width: 24),
                                        Expanded(child: _buildSecurityCard()),
                                      ],
                                    ],
                                  ),
                                )
                              else
                                Column(
                                  children: [
                                    _buildProfileCard(),
                                    if (!isRestrictedRole) ...[
                                      const SizedBox(height: 18),
                                      _buildSecurityCard(),
                                    ],
                                  ],
                                ),
                            ],
                          );
                        }),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return _SettingsCard(
      icon: Icons.person_outline,
      title: 'Profile Details',
      subtitle: 'Update your name and contact details',
      child: Form(
        key: _profileKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFFF0F4F9),
                  backgroundImage:
                      _imageUrl != null && _imageUrl!.trim().isNotEmpty
                      ? NetworkImage(_imageUrl!)
                      : null,
                  child: _imageUrl == null || _imageUrl!.trim().isEmpty
                      ? Text(
                          _initials(_nameController.text),
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Profile photo is managed by the employee image upload service.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.mutedNavy,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SettingsField(
              controller: _nameController,
              label: 'Full Name',
              validator: _required,
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final sideBySide = constraints.maxWidth >= 520;
                final fields = [
                  Expanded(
                    flex: sideBySide ? 1 : 0,
                    child: _SettingsField(
                      controller: _emailController,
                      label: 'Email (Read-only)',
                      enabled: false,
                    ),
                  ),
                  SizedBox(
                    width: sideBySide ? 16 : 0,
                    height: sideBySide ? 0 : 16,
                  ),
                  Expanded(
                    flex: sideBySide ? 1 : 0,
                    child: _SettingsField(
                      controller: _phoneController,
                      label: 'Contact Phone',
                      keyboardType: TextInputType.phone,
                      validator: _required,
                    ),
                  ),
                ];
                return sideBySide
                    ? Row(children: fields)
                    : Column(children: fields);
              },
            ),
            const SizedBox(height: 16),
            _SettingsField(
              controller: _addressController,
              label: 'Residential Address',
              maxLines: 4,
              validator: _required,
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: _OrangeButton(
                label: _savingProfile ? 'Saving...' : 'Save Profile',
                loading: _savingProfile,
                onPressed: _savingProfile ? null : _saveProfile,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityCard() {
    return _SettingsCard(
      icon: Icons.shield_outlined,
      title: 'Security & Password',
      subtitle: 'Secure your account by updating your login password',
      child: Form(
        key: _passwordKey,
        child: Column(
          children: [
            _SettingsField(
              controller: _passwordController,
              label: 'New Password',
              obscureText: _hidePassword,
              suffixIcon: IconButton(
                onPressed: () => setState(() => _hidePassword = !_hidePassword),
                icon: Icon(
                  _hidePassword ? Icons.visibility_off : Icons.visibility,
                ),
              ),
              validator: (value) {
                if ((value ?? '').length < 8) {
                  return 'Password must be at least 8 characters.';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            _SettingsField(
              controller: _confirmPasswordController,
              label: 'Confirm New Password',
              obscureText: _hideConfirmation,
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _hideConfirmation = !_hideConfirmation),
                icon: Icon(
                  _hideConfirmation ? Icons.visibility_off : Icons.visibility,
                ),
              ),
              validator: (value) => value != _passwordController.text
                  ? 'Passwords do not match.'
                  : null,
            ),
            const SizedBox(height: 28),
            Align(
              alignment: Alignment.centerRight,
              child: _OrangeButton(
                label: _savingPassword ? 'Updating...' : 'Update Password',
                loading: _savingPassword,
                onPressed: _savingPassword ? null : _savePassword,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDE5F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.navy),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.mutedNavy,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class _SettingsField extends StatelessWidget {
  const _SettingsField({
    required this.controller,
    required this.label,
    this.enabled = true,
    this.maxLines = 1,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final bool enabled;
  final int maxLines;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xFFF3F6F9),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(11)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: Color(0xFFD8E1ED)),
        ),
      ),
    );
  }
}

class _OrangeButton extends StatelessWidget {
  const _OrangeButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
      child: loading
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _SettingsError extends StatelessWidget {
  const _SettingsError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 42),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

Map<String, dynamic> _settingsMap(Object? source) {
  if (source is! Map) return const {};
  final map = Map<String, dynamic>.from(source);
  if (map['data'] is Map) {
    return Map<String, dynamic>.from(map['data'] as Map);
  }
  return map;
}

String _settingText(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }
  }
  return '';
}

String? _required(String? value) =>
    (value ?? '').trim().isEmpty ? 'This field is required.' : null;

String _initials(String value) {
  final words = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();
  if (words.isEmpty) return '--';
  return words.take(2).map((word) => word[0].toUpperCase()).join();
}
