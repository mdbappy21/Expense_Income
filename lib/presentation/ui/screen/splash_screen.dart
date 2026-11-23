import 'package:expense_income/presentation/ui/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
      backgroundColor: Colors.black,
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
            Text('Version $appVersion',style: const TextStyle(color: Colors.white),),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    appVersion=info.version;
    setState(() {});
  }


  Future<void> _moveToNextScreen() async {
    await Future.delayed(const Duration(seconds: 1));
    Get.offAll(()=>HomeScreen());
  }
}
