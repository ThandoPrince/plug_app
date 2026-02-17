// ignore_for_file: file_names, prefer_const_constructors

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/common/services/storage.dart';

class SpashScreen extends StatefulWidget {
  const SpashScreen({super.key});

  @override
  State<SpashScreen> createState() => _SpashScreenState();
}

class _SpashScreenState extends State<SpashScreen> {
  final envFile = kReleaseMode ? ".env.production" : ".env.development";

  // 4️⃣ Load environment variables
  
  late Timer _timer;



  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Run async logic AFTER initState
    _initAsync();
  }

  Future<void> _initAsync() async {
    try {
      await dotenv.load(fileName: envFile);
      debugPrint("✅ Loaded $envFile");
    } catch (e) {
      debugPrint("⚠️ Could not load $envFile: $e");
    }

    // Ensure first frame is rendered before navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _timer = Timer(const Duration(seconds: 3), () {
        if (!mounted) return;

        final firstOpen = Storage().getBool('firstOpen') ?? false;

        if (firstOpen == false) {
          context.go('/welcome');
        } else {
          context.go('/onboarding');
        }
      });
    });
  }

  

  @override
    void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {  
    return Scaffold(
      body: Container(
        width: ScreenUtil().screenWidth,
        height: ScreenUtil().screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Kolors.kPrimary,Kolors.kPrimary, Kolors.kWhite],
                begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             SizedBox(
              height: 100,
              child: Image.asset(
                'assets/icons/plug_icon.png',
              ),
            ),

            const SizedBox(height: 20),
            const SizedBox(
              height: 20,
              width: 30,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.black),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Be the game changer!',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
