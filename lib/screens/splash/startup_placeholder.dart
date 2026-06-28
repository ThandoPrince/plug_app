import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StartupPlaceholder extends StatelessWidget {
  const StartupPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: ScreenUtil().screenWidth,
        height: ScreenUtil().screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Kolors.kPrimary,
              Kolors.kPrimary,
              Kolors.kWhite,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SizedBox(
            height: 100.h,
            child: Image.asset(
              'assets/icons/plug_icon.png',
            ),
          ),
        ),
      ),
    );
  }
}