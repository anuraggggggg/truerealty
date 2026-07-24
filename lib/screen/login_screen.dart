import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/constant/screen_utils.dart';
import 'package:truerealtycrm/provider/auth_provider.dart';
import 'package:truerealtycrm/router/app_router.dart';
import 'package:truerealtycrm/screen/forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = true;
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),

                child: Stack(
                  children: [
                    const _HeaderArt(),
                    SizedBox(height: 40.h),
                    Padding(
                      padding: EdgeInsets.fromLTRB(2.w, 0.h, 0.w, 0.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20.h),
                          CommonWidgets.backButton(context),
                          SizedBox(height: 24.h),
                          SizedBox(height: 196.h),
                          _LoginCard(
                            emailController: _emailController,
                            passwordController: _passwordController,
                            rememberMe: _rememberMe,
                            hidePassword: _hidePassword,
                            onRememberChanged: (value) {
                              setState(() => _rememberMe = value ?? false);
                            },
                            onPasswordVisibilityChanged: () {
                              setState(() => _hidePassword = !_hidePassword);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeaderArt extends StatelessWidget {
  const _HeaderArt();

  @override
  Widget build(BuildContext context) {
    return Stack(children: [Image.asset("assets/login.png")]);
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.emailController,
    required this.passwordController,
    required this.rememberMe,
    required this.hidePassword,
    required this.onRememberChanged,
    required this.onPasswordVisibilityChanged,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool rememberMe;
  final bool hidePassword;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onPasswordVisibilityChanged;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    Future<void> loginWithEmailAndPassword() async {
      final email = emailController.text.trim();
      final password = passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter email and password.')),
        );
        return;
      }

      final response = await context.read<AuthProvider>().login(
        email: email,
        password: password,
      );

      if (!context.mounted) {
        return;
      }

      if (response != null) {
        Navigator.of(context).pushReplacementNamed(AppRouter.dashboard);
        return;
      }

      final error = context.read<AuthProvider>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Login failed. Please try again.')),
      );
    }

    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlue18,
            blurRadius: 28.r,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back!',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.33, // line-height equivalent
              color: Color(0xFF002149),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Login to your TrueRoot Realty account and manage your property leads.',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.normal,
              height: 1.5,
              color: Color(0xFF43474F),
            ),
          ),

          SizedBox(height: 26.h),
          CommonWidgets.fieldLabel('Email Address'),
          SizedBox(height: 10.h),
          _LoginInputField(
            icon: Icons.email_outlined,
            hint: 'Enter your registered email',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !authProvider.isLoading,
          ),
          SizedBox(height: 20.h),
          CommonWidgets.fieldLabel('Password'),
          SizedBox(height: 10.h),
          _LoginInputField(
            icon: Icons.lock_outline,
            hint: 'Enter your password',
            controller: passwordController,
            obscureText: hidePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (!authProvider.isLoading) {
                loginWithEmailAndPassword();
              }
            },
            enabled: !authProvider.isLoading,
            suffix: IconButton(
              onPressed: authProvider.isLoading
                  ? null
                  : onPasswordVisibilityChanged,
              icon: Icon(
                hidePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.mutedNavy,
                size: 24.sp,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          CommonWidgets.fieldLabel('Select Role (For Demo)'),
          SizedBox(height: 10.h),
          DropdownButtonFormField<UserRole>(
            initialValue: context.watch<AuthProvider>().role,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 18.w,
                vertical: 20.h,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(color: AppColors.navy, width: 1.4),
              ),
            ),
            items: [
              // Owner app login is temporarily hidden for the current rollout.
              DropdownMenuItem(
                value: UserRole.telecaller,
                child: Text(
                  'Telecaller App',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: UserRole.fieldExecutive,
                child: Text(
                  'Field Executive App',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ],
            onChanged: (UserRole? value) {
              if (value != null) {
                context.read<AuthProvider>().setRole(value);
              }
            },
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              SizedBox(
                width: 24.w,
                height: 24.h,
                child: Checkbox(
                  value: rememberMe,
                  onChanged: authProvider.isLoading ? null : onRememberChanged,
                  activeColor: AppColors.navy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Remember me',
                  style: TextStyle(
                    color: AppColors.mutedNavy,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w800,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          SizedBox(
            height: 58.h,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: authProvider.isLoading
                  ? null
                  : loginWithEmailAndPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: authProvider.isLoading
                  ? SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Icon(Icons.arrow_forward, size: 24.sp),
                      ],
                    ),
            ),
          ),
          SizedBox(height: 24.h),
          const _HelpPanel(),
        ],
      ),
    );
  }
}

class _LoginInputField extends StatelessWidget {
  const _LoginInputField({
    required this.icon,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffix,
    this.onSubmitted,
    this.enabled = true,
  });

  final IconData icon;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      onSubmitted: onSubmitted,
      enabled: enabled,
      style: AppStyles.inputText,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppStyles.inputHint,
        prefixIcon: Container(
          width: 54.w,
          height: 54.h,
          margin: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: AppColors.inputIconBg,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: AppColors.navy, size: 24.sp),
        ),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppColors.navy, width: 1.4),
        ),
      ),
    );
  }
}

class _HelpPanel extends StatelessWidget {
  const _HelpPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: AppColors.supportCircleBg,
            child: Icon(
              Icons.headset_mic_outlined,
              color: AppColors.navy,
              size: 30.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need help?',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.78,
                    letterSpacing: 0.6,
                    color: AppColors.navy,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Contact our support team',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.78,
                    color: Color(0xFF43474F),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Icon(Icons.phone, color: AppColors.navy, size: 18.sp),
        ],
      ),
    );
  }
}
