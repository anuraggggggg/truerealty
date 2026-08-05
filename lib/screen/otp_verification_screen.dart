import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/provider/auth_provider.dart';
import 'package:truerealtycrm/router/app_router.dart';
import 'package:truerealtycrm/widget/app_loading.dart';
import 'package:url_launcher/url_launcher.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _expiryTimer;
  Timer? _resendTimer;
  int _expiresRemaining = 0;
  int _resendRemaining = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapTimers());
  }

  void _bootstrapTimers() {
    final challenge = context.read<AuthProvider>().otpChallenge;
    if (challenge == null) {
      Navigator.of(context).pushReplacementNamed(AppRouter.login);
      return;
    }
    _startTimers(
      expiresIn: challenge.expiresInSeconds,
      resendAfter: challenge.resendAfterSeconds,
    );
  }

  void _startTimers({required int expiresIn, required int resendAfter}) {
    _expiryTimer?.cancel();
    _resendTimer?.cancel();
    setState(() {
      _expiresRemaining = expiresIn;
      _resendRemaining = resendAfter;
    });

    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_expiresRemaining <= 1) {
        timer.cancel();
        setState(() => _expiresRemaining = 0);
        return;
      }
      setState(() => _expiresRemaining -= 1);
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendRemaining <= 1) {
        timer.cancel();
        setState(() => _resendRemaining = 0);
        return;
      }
      setState(() => _resendRemaining -= 1);
    });
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    _resendTimer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _verify() async {
    final auth = context.read<AuthProvider>();
    final response = await auth.verifyOtp(otp: _otpCode);
    if (!mounted) return;

    if (response != null && auth.isAuthenticated) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.dashboard,
        (route) => false,
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(auth.loginError ?? 'Invalid or expired OTP.'),
      ),
    );
  }

  Future<void> _resend() async {
    if (_resendRemaining > 0) return;
    final auth = context.read<AuthProvider>();
    final response = await auth.resendOtp();
    if (!mounted) return;

    if (response != null && auth.isAuthenticated) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.dashboard,
        (route) => false,
      );
      return;
    }

    if (response != null && auth.otpChallenge != null) {
      final challenge = auth.otpChallenge!;
      _startTimers(
        expiresIn: challenge.expiresInSeconds,
        resendAfter: challenge.resendAfterSeconds,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(challenge.message ?? 'OTP resent successfully.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(auth.loginError ?? 'Unable to resend OTP.'),
      ),
    );
  }

  Future<void> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final challenge = auth.otpChallenge;

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
                    const _OtpHeaderArt(),
                    Padding(
                      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 24.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () {
                              context.read<AuthProvider>().clearOtpChallenge();
                              Navigator.of(
                                context,
                              ).pushReplacementNamed(AppRouter.login);
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: AppColors.border),
                            ),
                            icon: const Icon(
                              Icons.chevron_left_rounded,
                              color: AppColors.navy,
                            ),
                          ),
                          SizedBox(height: 180.h),
                          _OtpCard(
                            deliveryTarget:
                                challenge?.deliveryTarget ??
                                'your registered phone',
                            controllers: _controllers,
                            focusNodes: _focusNodes,
                            expiresLabel: _formatDuration(_expiresRemaining),
                            resendLabel: _resendRemaining > 0
                                ? 'Resend OTP in ${_formatDuration(_resendRemaining)}'
                                : 'Resend OTP',
                            canResend: _resendRemaining <= 0 && !auth.isLoading,
                            isLoading: auth.isLoading,
                            isExpired: _expiresRemaining <= 0,
                            onVerify: _verify,
                            onResend: _resend,
                            onChangeIdentifier: () {
                              context.read<AuthProvider>().clearOtpChallenge();
                              Navigator.of(
                                context,
                              ).pushReplacementNamed(AppRouter.login);
                            },
                            onBackToLogin: () {
                              context.read<AuthProvider>().clearOtpChallenge();
                              Navigator.of(
                                context,
                              ).pushReplacementNamed(AppRouter.login);
                            },
                            onCallSupport: () => _launch(
                              Uri(scheme: 'tel', path: '+919876543210'),
                            ),
                            onEmailSupport: () => _launch(
                              Uri(
                                scheme: 'mailto',
                                path: 'support@truerootrealty.com',
                              ),
                            ),
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

class _OtpHeaderArt extends StatelessWidget {
  const _OtpHeaderArt();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280.h,
      width: double.infinity,
      child: Image.asset('assets/otp.png', fit: BoxFit.cover),
    );
  }
}

class _OtpCard extends StatelessWidget {
  const _OtpCard({
    required this.deliveryTarget,
    required this.controllers,
    required this.focusNodes,
    required this.expiresLabel,
    required this.resendLabel,
    required this.canResend,
    required this.isLoading,
    required this.isExpired,
    required this.onVerify,
    required this.onResend,
    required this.onChangeIdentifier,
    required this.onBackToLogin,
    required this.onCallSupport,
    required this.onEmailSupport,
  });

  final String deliveryTarget;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final String expiresLabel;
  final String resendLabel;
  final bool canResend;
  final bool isLoading;
  final bool isExpired;
  final VoidCallback onVerify;
  final VoidCallback onResend;
  final VoidCallback onChangeIdentifier;
  final VoidCallback onBackToLogin;
  final VoidCallback onCallSupport;
  final VoidCallback onEmailSupport;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 18.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlue18,
            blurRadius: 24.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: const BoxDecoration(
                  color: AppColors.orangeDeep,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mail_outline_rounded,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Two-factor verification',
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 13.5.sp,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
              children: [
                const TextSpan(
                  text: "We've sent a 6-digit OTP by SMS to ",
                ),
                TextSpan(
                  text: deliveryTarget,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 22.h),
          Text(
            'Enter the 6-digit code',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          SizedBox(height: 12.h),
          _OtpBoxes(controllers: controllers, focusNodes: focusNodes),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.softBlue,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 18.sp,
                  color: AppColors.blueBright,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: isExpired
                              ? 'OTP expired. Please resend a new code.'
                              : 'OTP will expire in ',
                        ),
                        if (!isExpired)
                          TextSpan(
                            text: expiresLabel,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w800,
                              color: AppColors.orangeDeep,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          InkWell(
            onTap: canResend ? onResend : null,
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: Row(
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    size: 18.sp,
                    color: canResend
                        ? AppColors.navy
                        : AppColors.textTertiary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    resendLabel,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: canResend
                          ? AppColors.navy
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 52.h,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading || isExpired ? null : onVerify,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orangeDeep,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: isLoading
                  ? const AppInlineLoader(color: Colors.white)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Verify OTP',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Icon(Icons.arrow_forward_rounded, size: 20.sp),
                      ],
                    ),
            ),
          ),
          SizedBox(height: 18.h),
          const _DividerLabel('or'),
          SizedBox(height: 14.h),
          _OutlinedActionButton(
            icon: Icons.mail_outline_rounded,
            label: 'Change Email / Mobile Number',
            onPressed: onChangeIdentifier,
          ),
          SizedBox(height: 10.h),
          _OutlinedActionButton(
            icon: Icons.arrow_back_rounded,
            label: 'Back to Login',
            onPressed: onBackToLogin,
          ),
          SizedBox(height: 16.h),
          _SupportPanel(
            onCallSupport: onCallSupport,
            onEmailSupport: onEmailSupport,
          ),
        ],
      ),
    );
  }
}

class _OtpBoxes extends StatelessWidget {
  const _OtpBoxes({
    required this.controllers,
    required this.focusNodes,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = ((constraints.maxWidth - 30.w) / 6)
            .clamp(42.0, 52.0)
            .toDouble();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(controllers.length, (index) {
            return SizedBox(
              width: boxWidth,
              height: 56.h,
              child: TextField(
                controller: controllers[index],
                focusNode: focusNodes[index],
                autofocus: index == 0,
                keyboardType: TextInputType.number,
                textInputAction: index == controllers.length - 1
                    ? TextInputAction.done
                    : TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(1),
                ],
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AppColors.navy,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(
                      color: AppColors.vividBlue,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && index < controllers.length - 1) {
                    focusNodes[index + 1].requestFocus();
                  }
                  if (value.isEmpty && index > 0) {
                    focusNodes[index - 1].requestFocus();
                  }
                },
              ),
            );
          }),
        );
      },
    );
  }
}

class _OutlinedActionButton extends StatelessWidget {
  const _OutlinedActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        icon: Icon(icon, size: 18.sp),
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: AppColors.textTertiary,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}

class _SupportPanel extends StatelessWidget {
  const _SupportPanel({
    required this.onCallSupport,
    required this.onEmailSupport,
  });

  final VoidCallback onCallSupport;
  final VoidCallback onEmailSupport;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.headset_mic_outlined,
                size: 18.sp,
                color: AppColors.blueBright,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Need help? Contact our support team',
                  style: GoogleFonts.inter(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          InkWell(
            onTap: onCallSupport,
            child: Row(
              children: [
                Icon(Icons.call_outlined, size: 16.sp, color: AppColors.navy),
                SizedBox(width: 8.w),
                Text(
                  '+91 98765 43210',
                  style: GoogleFonts.inter(
                    fontSize: 12.5.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          InkWell(
            onTap: onEmailSupport,
            child: Row(
              children: [
                Icon(Icons.mail_outline, size: 16.sp, color: AppColors.navy),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    'support@truerootrealty.com',
                    style: GoogleFonts.inter(
                      fontSize: 12.5.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
