import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/router/app_router.dart';
import 'package:truerealtycrm/screen/dashboard_screen.dart';


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

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              const _OtpHeader(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  children: [
                    SizedBox(height: 265.h),
                    _OtpCard(controllers: _controllers),
                    SizedBox(height: 28.h),
                    const _SecurityNote(),
                    SizedBox(height: 26.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpHeader extends StatelessWidget {
  const _OtpHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 296.h,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/otp.png', fit: BoxFit.fill),
          ),
          Positioned(
            left: 12.w,
            top: 1.h,
            child: SizedBox(
              height: 38.h,
              width: 38.w,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: AppColors.white,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Icon(
                  Icons.chevron_left,
                  color: AppColors.navy,
                  size: 22.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MailIllustration extends StatelessWidget {
  const _MailIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92.h,
      width: 94.w,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            top: 0,
            child: Container(
              width: 54.w,
              height: 54.h,
              decoration: BoxDecoration(
                color: AppColors.orange,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Icon(Icons.home, color: AppColors.white, size: 25.sp),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: 76.w,
              height: 61.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE6EEFF),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: CustomPaint(
              size: Size(76.w, 61.h),
              painter: _EnvelopePainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _EnvelopePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final light = Paint()..color = const Color(0xFFD9E6FF);
    final blue = Paint()..color = const Color(0xFFC2D2F6);

    final left = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height * .55)
      ..lineTo(0, size.height)
      ..close();
    final right = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width / 2, size.height * .55)
      ..lineTo(size.width, size.height)
      ..close();
    final bottom = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, size.height * .43)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(left, light);
    canvas.drawPath(right, light);
    canvas.drawPath(bottom, blue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OtpCard extends StatelessWidget {
  const _OtpCard({required this.controllers});

  final List<TextEditingController> controllers;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 18.h, 14.w, 18.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlue18,
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verify Your Email',
            style: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              height: 1.33,
              letterSpacing: 0,
              color: const Color(0xFF002149),
            ),
          ),
          SizedBox(height: 12.h),
          RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.normal,
                height: 1.43,
                color: const Color(0xFF43474F),
              ),
              children: const [
                TextSpan(
                  text: 'We’ve sent a 6-digit OTP to your email address ',
                ),
                TextSpan(
                  text: 'johndoetruerootrealtycom',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF002149),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30.h),
          _OtpBoxes(controllers: controllers),
          SizedBox(height: 20.h),
          Center(
            child: Text(
              'Enter the 6-digit code sent to your email',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.normal,
                height: 1.5,
                color: AppColors.mutedNavy,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          const _ResendPanel(),
          SizedBox(height: 24.h),
          SizedBox(
            height: 54.h,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Verify & Continue',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(width: 8.w),
                  Icon(Icons.arrow_forward, size: 18.sp),
                ],
              ),
            ),
          ),
          SizedBox(height: 25.h),
          const _DividerLabel('or try another way'),
          SizedBox(height: 20.h),
          SizedBox(
            height: 50.h,
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRouter.forgotPassword);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              icon: Icon(
                Icons.email_outlined,
                color: AppColors.navy,
                size: 22.sp,
              ),
              label: Text(
                'Change Email',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  height: 1.5,
                  color: const Color(0xFF002149),
                ),
              ),
              ),
            ),

        ],
      ),
    );
  }
}

class _OtpBoxes extends StatelessWidget {
  const _OtpBoxes({required this.controllers});

  final List<TextEditingController> controllers;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = ((constraints.maxWidth - 30.w) / 6)
            .clamp(42.0, 52.0)
            .toDouble();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            controllers.length,
            (index) => SizedBox(
              width: boxWidth,
              height: 60.h,
              child: TextField(
                controller: controllers[index],
                autofocus: index == 0,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w800,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(
                      color: AppColors.vividBlue,
                      width: 2.5,
                    ),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && index < controllers.length - 1) {
                    FocusScope.of(context).nextFocus();
                  }
                  if (value.isEmpty && index > 0) {
                    FocusScope.of(context).previousFocus();
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ResendPanel extends StatelessWidget {
  const _ResendPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: AppColors.supportCircleBg,
            child: Icon(
              Icons.info_outline,
              color: AppColors.vividBlue,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Didn\'t receive the code?',
                  textAlign: TextAlign.left,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    height: 1.5,
                    color: AppColors.mutedNavy,
                  ),
                ),

                SizedBox(height: 4.h),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Resend OTP',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.33,
                          letterSpacing: 0.6,
                          color: AppColors.navy,
                        ),
                      ),
                      TextSpan(
                        text: ' in ',
                        style: TextStyle(
                          color: const Color(0xFF4B5565),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: '00:45',
                        style: TextStyle(
                          color: AppColors.orange,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
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
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.normal,
              height: 1.5,
              color: const Color(0xFF747781),
            ),
          ),
        ),

        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}

class _SecurityNote extends StatelessWidget {
  const _SecurityNote();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            // backgroundColor: AppColors.supportCircleBg,
            child: Image.asset('assets/otp_secure.png')
            // Icon(
            //   Icons.verified_user_outlined,
            //   color: AppColors.navy,
            //   size: 24.sp,
            // ),
          ),
          SizedBox(width: 18.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure & Trusted',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Your information is protected with enterprise grade security.',
                  style: TextStyle(
                    color: const Color(0xFF4B5565),
                    fontSize: 14.sp,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
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
