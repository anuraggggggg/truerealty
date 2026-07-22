import 'package:flutter/material.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/router/app_router.dart';

class LogoutConfirmationScreen extends StatelessWidget {
  const LogoutConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Stack(
          children: [
            const _BackgroundArt(),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 28, 18, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _BrandBlock(),
                  SizedBox(height: 32),
                  Text(
                    'Trueroot Realty CRM',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Manage your leads, follow-ups, site visits and sales - all in one place.',
                    style: TextStyle(
                      color: AppColors.mutedNavy,
                      fontSize: 13,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 28),
                  _LogoutCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundArt extends StatelessWidget {
  const _BackgroundArt();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: -170,
          bottom: -110,
          child: Container(
            width: 390,
            height: 390,
            decoration: const BoxDecoration(
              color: AppColors.navy,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: -40,
          bottom: 80,
          child: Opacity(
            opacity: .12,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                _BuildingTower(height: 170, floors: 6),
                SizedBox(width: 9),
                _BuildingTower(height: 230, floors: 8),
                SizedBox(width: 9),
                _BuildingTower(height: 190, floors: 7),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/app_icon.png',
      width: 210,
      fit: BoxFit.contain,
    );
  }
}

class _LogoutCard extends StatelessWidget {
  const _LogoutCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 26),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowBlue18,
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: AppColors.orangeBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.logout,
              color: AppColors.orange,
              size: 42,
            ),
          ),
          const SizedBox(height: 26),
          const Text(
            'Are you sure you want to logout?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 19,
              height: 1.2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'You will be logged out from Trueroot Realty CRM and need to login again to continue.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.mutedNavy,
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 26),
          const _UserPanel(),
          const SizedBox(height: 26),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.navy),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRouter.login,
                        (_) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            'Logout',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const _SecurityPanel(),
        ],
      ),
    );
  }
}

class _UserPanel extends StatelessWidget {
  const _UserPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          CircleAvatar(
            radius: 34,
            backgroundColor: AppColors.avatarBg,
            child: Icon(Icons.person, color: AppColors.navy, size: 34),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amit Kumar',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Field Executive',
                  style: TextStyle(
                    color: AppColors.mutedNavy,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

class _SecurityPanel extends StatelessWidget {
  const _SecurityPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.supportCircleBg,
            child: Icon(
              Icons.verified_user_outlined,
              color: AppColors.navy,
              size: 26,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your session will be closed securely.',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'All data is protected and no changes will be saved after you logout.',
                  style: TextStyle(
                    color: AppColors.mutedNavy,
                    fontSize: 11,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
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

class _BuildingTower extends StatelessWidget {
  const _BuildingTower({required this.height, required this.floors});

  final double height;
  final int floors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: height,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: AppColors.building,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          floors,
          (_) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _Window(),
              _Window(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Window extends StatelessWidget {
  const _Window();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 14,
      decoration: BoxDecoration(
        color: AppColors.windowBlue,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
