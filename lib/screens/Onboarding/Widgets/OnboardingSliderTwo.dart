
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

List<String> images = [
  "assets/images/Welcome_slider_1.jpeg",
  "assets/images/welcome_slider_2.jpeg",
  "assets/images/welcome_slider_3.jpeg",
];

class Onboardingslidertwo extends StatefulWidget {
  const Onboardingslidertwo({super.key});

  @override
  State<Onboardingslidertwo> createState() => _OnboardingslidertwoState();
}

class _OnboardingslidertwoState extends State<Onboardingslidertwo> {
  bool _autoPlay = true;
  Timer? _inactivityTimer;

  void _onUserInteraction() {
    // User has touched/swiped the slider.
    if (_autoPlay) {
      setState(() {
        _autoPlay = false;
      });
    }

    // Reset the inactivity timer every time the user interacts.
    _inactivityTimer?.cancel();

    // Resume autoplay after 30 seconds of no interaction.
    _inactivityTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          _autoPlay = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          SizedBox(
            height: ScreenUtil().screenHeight * 0.4,
            width: ScreenUtil().screenWidth * 0.5,
            child: GestureDetector(
              onTapDown: (_) => _onUserInteraction(),
              onPanDown: (_) => _onUserInteraction(),
              onHorizontalDragStart: (_) => _onUserInteraction(),
              onVerticalDragStart: (_) => _onUserInteraction(),
              child: ImageSlideshow(
                width: ScreenUtil().screenWidth,
                height: ScreenUtil().screenHeight,
                indicatorColor: Kolors.kGray,
                indicatorBackgroundColor: Colors.grey,
                autoPlayInterval: _autoPlay ? 5000 : 0,
                isLoop: true,
                onPageChanged: (p) {
                  if (kDebugMode) {
                    print("Page changed: $p");
                  }
                },
                children: images.map((path) {
                  return Image.asset(
                    path,
                    fit: BoxFit.fitHeight,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

