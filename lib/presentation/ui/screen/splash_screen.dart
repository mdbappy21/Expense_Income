import 'package:expense_income/presentation/ui/screen/main_bottom_nav_bar.dart';
import 'package:expense_income/presentation/ui/screen/introduction_onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String appVersion='';

  @override
  void initState() {
    super.initState();
    getAppVersion();
    _moveToNextScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.isDarkMode?Colors.black:Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 96),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                    maxHeight: 220
                ),
                child: Image.asset(
                  'assets/images/app_icon.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const Spacer(),
            Text('Version $appVersion',style: TextStyle(color: Get.isDarkMode?Colors.white:Colors.black),),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    appVersion = info.version;
    setState(() {});
  }


  Future<void> _moveToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final preferences = await SharedPreferences.getInstance();
    final hasSeenIntroduction =
        preferences.getBool('has_seen_introduction') ?? false;

    if (!mounted) return;

    if (hasSeenIntroduction) {
      Get.offAll(() => MainBottomNavBar());
    } else {
      Get.offAll(() => const IntroductionOnboardingScreen());
    }
  }
}
