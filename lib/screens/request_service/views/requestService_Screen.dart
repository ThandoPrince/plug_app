import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/common/widgets/app_style.dart';
import 'package:flutter_application_1/common/widgets/custom_button.dart';
import 'package:flutter_application_1/common/widgets/logout_bottom_sheet.dart';
import 'package:flutter_application_1/common/widgets/reusable_text.dart';
import 'package:flutter_application_1/const/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class Requestservice extends StatelessWidget {
  const Requestservice({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        
        children: [
          GestureDetector(
            onTap: () {
              
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50.h,
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.5, color: Kolors.kPrimary),
                        borderRadius: BorderRadius.circular(12),
                        color: Kolors.kGrayLight,
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(
                              Icons.search_rounded,
                              color: Kolors.kPrimary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Search a service  ..eg. (I want my laundry done. Urgently!)',
                              overflow: TextOverflow.visible,
                              style: appStyle(16, Kolors.kOffWhite, FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
            ),
          ),
          SizedBox(height: 60,),
          Container(

            width: double.infinity,
                              height: 70.h,
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.5, color: Kolors.kPrimary),
                        borderRadius: BorderRadius.circular(12),
                        color: Kolors.kGrayLight,),

                       child:        TextButton(
                    onPressed: () {
                  
                    },
                    child: ReusableText(
                      text: "Service related to the search query will be displayed here",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                        color: Kolors.kOffWhite,
                      ),
                    ),
                  ),
          ),
          Expanded(child: SizedBox(height: ScreenUtil().screenHeight)),
           Expanded(child: SizedBox(height: ScreenUtil().screenHeight)),
            Expanded(child: SizedBox(height: ScreenUtil().screenHeight)),

         Expanded(
           child: Container(
            
                   height: 150.h,
                   decoration: BoxDecoration(borderRadius: kRadiusTop),
                   child: ListView(
            children: [
             
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                 
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  
                  children: [
                    GradientBtn(
                      text: "Cancel",
                      borderColor: Kolors.kDark,
                      btnColor: Kolors.kWhite,
                      onTap: () => Navigator.pop(context),
                      btnHieght: 35.h,
                      radius: 16,
                      btnWidth: ScreenUtil().screenWidth / 2.2,
                    ),
                    GradientBtn(
                      text: "Next",
                      onTap: () {
                       
                      },
                      btnHieght: 35.h,
                      radius: 16,
                      btnWidth: ScreenUtil().screenWidth / 2.2,
                    ),
                  ],
                ),
              )
            ],
                   ),
                 ),
         )
        ],
        
      ),
    );
  }
}
