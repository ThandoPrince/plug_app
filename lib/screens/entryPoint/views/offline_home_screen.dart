import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';

/// Shown in place of EntryPoint when the initial data prefetch fails —
/// almost always because the device has no internet connection. Gives
/// the user a clear explanation, a retry action, and a way to exit the
/// app outright rather than being stuck on a broken/half-loaded screen.
class OfflineHomeScreen extends StatelessWidget {
  final VoidCallback onRetry;
  final bool isRetrying;

  const OfflineHomeScreen({
    super.key,
    required this.onRetry,
    this.isRetrying = false,
  });

  void _exitApp() {
    // On Android this cleanly backs out to the home screen / closes the
    // app's task. On iOS, Apple's guidelines discourage apps quitting
    // themselves, so exit() is used as a harder fallback there.
    if (Platform.isIOS) {
      exit(0);
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Kolors.kPrimary, Kolors.kPrimary, Kolors.kSecondaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 28.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(30.r),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 92.w,
                          height: 92.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.22),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.28),
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 72.w,
                                height: 72.w,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFEF4444),
                                ),
                              ),
                              Icon(
                                Icons.wifi_off_rounded,
                                size: 40.sp,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 22.h),
                        Text(
                          "No Internet Connection",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          "We couldn't load your account. Please check "
                          "your connection and try again.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            height: 1.5,
                            color: Colors.black.withOpacity(0.92),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: 14.h,
                            horizontal: 16.w,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(18.r),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.14),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.signal_wifi_statusbar_connected_no_internet_4_rounded,
                                color: Colors.black.withOpacity(0.6),
                                size: 22.sp,
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  "Your data is safe. We'll pick up right where you left off once you're back online.",
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.85),
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Kolors.kPrimary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  Kolors.kPrimary.withOpacity(0.6),
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.r),
                              ),
                            ),
                            onPressed: isRetrying ? null : onRetry,
                            child: isRetrying
                                ? SizedBox(
                                    width: 22.w,
                                    height: 22.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    "Try Again",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: _exitApp,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black.withOpacity(0.7),
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.r),
                              ),
                            ),
                            child: Text(
                              "Exit App",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}