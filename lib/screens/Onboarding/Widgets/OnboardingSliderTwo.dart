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

class Onboardingslidertwo extends StatelessWidget {
  const Onboardingslidertwo({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          SizedBox(
            height: ScreenUtil().screenHeight * 0.4,
            width: ScreenUtil().screenWidth,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 3.0),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ImageSlideshow(
                width: ScreenUtil().screenWidth,
                height: ScreenUtil().screenHeight,
                indicatorColor: Kolors.kGray,
                indicatorBackgroundColor: Colors.grey,
                onPageChanged: (p) {
                  if (kDebugMode) {
                    print("Page changed: $p");
                  }
                },
                autoPlayInterval: 5000,
                isLoop: true,
                children: images.map((path) {
                  return Image.asset(
                    path,
                    fit: BoxFit.fill,
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
