import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/constant/screen_utils.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Stack(
                  children: [
                    const _HeaderArt(),
                    Padding(
                      padding: EdgeInsets.fromLTRB(10.w, 36.h, 20.w, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonWidgets.backButton(context),
                          SizedBox(height: 20.h),
                          const _BrandBlock(),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(
                        top: 252.h,
                        left: 0.w,
                        right: 0.w,
                        bottom: 15.h,
                      ),
                      padding: EdgeInsets.fromLTRB(16.w, 32.h, 16.w, 28.h),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(22.r),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.06),
                            offset: Offset(0, -8),
                            blurRadius: 24,
                          ),
                        ],
                      ),
                      child: const _ForgotPasswordPanel(),
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
    return Image.asset(
      'assets/top_heades.png',
      width: double.infinity,
      height: 306.h,
      fit: BoxFit.cover,
      alignment: Alignment.topRight,
    );
  }
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/app_icon.png',
      width: 220.w,
      fit: BoxFit.cover,
    );
  }
}

class _ForgotPasswordPanel extends StatelessWidget {
  const _ForgotPasswordPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Forgot Password?',
          style: GoogleFonts.inter(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            height: 1.33,
            color: const Color(0xFF002149),
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          "Don't worry! Enter your registered email\naddress and we'll send you a link to reset\nyour password.",
          style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.normal,
              height: 1.43,
              color: AppColors.mutedNavy
              // Color(0xFF43474F),
              ),
        ),
        SizedBox(height: 32.h),
        Text(
          'Email Address',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 1.33,
            letterSpacing: 0.6,
            color: Color(0xFF002149),
          ),
        ),
        SizedBox(height: 8.h),
        const _EmailField(),
        SizedBox(height: 24.h),
        const _InfoPanel(),
        SizedBox(height: 24.h),
        const _ResetButton(),
        SizedBox(height: 34.h),
        const _DividerLabel('or try another way'),
      ],
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58.h,
      child: TextField(
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(
          color: AppColors.navy,
          fontWeight: FontWeight.w600,
          fontSize: 16.sp,
        ),
        decoration: InputDecoration(
          hintText: 'Enter your registered email',
          hintStyle: TextStyle(
            color: AppColors.mutedNavy,
            fontWeight: FontWeight.w500,
            fontSize: 15.sp,
          ),
          prefixIcon: Container(
            width: 54.w,
            height: 58.h,
            margin: EdgeInsets.only(right: 16.w),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF3FF),
              border: Border(
                right: BorderSide(
                  color: Color(0xFFC3C6D1),
                  width: 1,
                ),
              ),
            ),
            child: Icon(
              Icons.mail_outline,
              color: AppColors.navy,
              size: 24.sp,
            ),
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 54.w,
            minHeight: 58.h,
          ),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 18.h),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: AppColors.navy, width: 1.2),
          ),
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFCFE0FF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.navy,
            size: 22.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: "We'll send a password reset link to your email ",
                children: [
                  TextSpan(
                    text: 'john.doe@truerootrealty.com',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w800,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
              style: TextStyle(
                color: AppColors.mutedNavy,
                fontSize: 14.sp,
                height: 1.55,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResetButton extends StatelessWidget {
  const _ResetButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54.h,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
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
              'Send Reset Link',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.arrow_forward, size: 20.sp),
          ],
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
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.mutedNavy,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}
