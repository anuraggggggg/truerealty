import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';

class AppStyles {
  const AppStyles._();

  static TextStyle get brandPrimary => GoogleFonts.inter(
    color: AppColors.orange,
    fontSize: 48.sp,
    fontWeight: FontWeight.w900,
    height: 0.9,
  );

  static TextStyle get brandSecondary => GoogleFonts.inter(
    color: AppColors.navy,
    fontSize: 48.sp,
    fontWeight: FontWeight.w900,
    height: 0.9,
  );

  static TextStyle get brandTagline => GoogleFonts.inter(
    color: AppColors.navy,
    fontSize: 22.sp,
    fontWeight: FontWeight.w800,
  );

  static TextStyle get brandMotto => GoogleFonts.inter(
    color: AppColors.orange,
    fontSize: 17.sp,
    fontWeight: FontWeight.w800,
  );

  static TextStyle get h1 => GoogleFonts.inter(
    color: AppColors.navy,
    fontSize: 36.sp,
    fontWeight: FontWeight.w800,
  );

  static TextStyle get h2 => GoogleFonts.inter(
    color: AppColors.navy,
    fontSize: 32.sp,
    fontWeight: FontWeight.w900,
  );

  static TextStyle get bodyLarge => GoogleFonts.inter(
    color: AppColors.mutedNavy,
    fontSize: 20.sp,
    height: 1.45,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    color: AppColors.mutedNavy,
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get labelLarge => GoogleFonts.inter(
    color: AppColors.navy,
    fontSize: 20.sp,
    fontWeight: FontWeight.w800,
  );
  static TextStyle get inputHint => const TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.0,
    color: Color(0xFF747781),
  );
  static TextStyle get inputText => GoogleFonts.inter(
    color: AppColors.navy,
    fontWeight: FontWeight.w600,
    fontSize: 18.sp,
  );
  static TextStyle customSize(double size, {Color? color, FontWeight? weight}) {
    return GoogleFonts.inter(
      fontSize: size.sp,
      color: color ?? AppColors.navy,
      fontWeight: weight ?? FontWeight.w600,
    );
  }

  static TextStyle dynamicSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    return GoogleFonts.inter(
      fontSize: (baseSize * (screenWidth / 428)).sp,
      color: AppColors.navy,
      fontWeight: FontWeight.w600,
    );
  }
}

class AppSpacing {
  const AppSpacing._();
  static double get screenWidth => 1.sw;
  static double get screenHeight => 1.sh;
  static double get statusBarHeight => ScreenUtil().statusBarHeight;
  static double get bottomBarHeight => ScreenUtil().bottomBarHeight;

  static double get screenPaddingHorizontal => 18.w;
  static double get screenPaddingVertical => 28.h;

  static EdgeInsets get screenPadding => EdgeInsets.symmetric(
    horizontal: screenPaddingHorizontal,
    vertical: screenPaddingVertical,
  );

  static double get cardPaddingHorizontal => 28.w;
  static double get cardPaddingVertical => 32.h;

  static EdgeInsets get cardPadding => EdgeInsets.symmetric(
    horizontal: cardPaddingHorizontal,
    vertical: cardPaddingVertical,
  );
}

class CommonWidgets {
  const CommonWidgets._();

  static Widget backButton(BuildContext context) {
    return SizedBox(
      height: 44,
      width: 44,
      child: OutlinedButton(
        onPressed: () => Navigator.of(context).maybePop(),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: AppColors.white,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Icon(
          Icons.arrow_back_ios_new,
          size: 15.sp,
          color: AppColors.navy,
        ),
      ),
    );
  }

  static Widget fieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.33,
        letterSpacing: 0.6,
        color: Color(0xFF002149),
      ),
    );
  }

  static Widget fieldLabelScaled(String text, {double fontSize = 14}) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: fontSize.sp,
        fontWeight: FontWeight.w600,
        height: 1.33,
        letterSpacing: 0.6,
        color: const Color(0xFF002149),
      ),
    );
  }

  static Widget inputField({
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return TextField(
      keyboardType: keyboardType,
      obscureText: obscureText,
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

  static Widget headerImage() {
    return Image.asset(
      'assets/top_heades.png',
      width: double.infinity,
      height: 60.h,
      fit: BoxFit.contain,
    );
  }

  static Widget screenHeader(
    BuildContext context, {
    bool showBackButton = true,
  }) {
    return Column(
      children: [
        headerImage(),
        if (showBackButton) ...[
          SizedBox(height: 16.h),
          Align(alignment: Alignment.centerLeft, child: backButton(context)),
        ],
        SizedBox(height: 24.h),
      ],
    );
  }
}

class BuildingDecoration extends StatelessWidget {
  const BuildingDecoration({
    super.key,
    required this.height,
    required this.floors,
    this.width,
    this.windowWidth,
    this.windowHeight,
  });

  final double height;
  final int floors;
  final double? width;
  final double? windowWidth;
  final double? windowHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 52.w,
      height: height,
      padding: EdgeInsets.all(7.r),
      decoration: BoxDecoration(
        color: AppColors.building,
        borderRadius: BorderRadius.circular(4.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlue22,
            blurRadius: 14.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          floors,
          (_) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Window(width: windowWidth, height: windowHeight),
              _Window(width: windowWidth, height: windowHeight),
            ],
          ),
        ),
      ),
    );
  }
}

class _Window extends StatelessWidget {
  const _Window({this.width, this.height});
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 16.w,
      height: height ?? 14.h,
      decoration: BoxDecoration(
        color: AppColors.windowBlue,
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }
}
