import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/submit_ratings_controller.dart';
import 'package:flutter_application_1/screens/entryPoint/controller/bottom_tab_notifier.dart';
import 'package:flutter_application_1/screens/entryPoint/views/entry_point.dart';
import 'package:flutter_application_1/screens/schedule/widgets/go_to_schedule_helper.dart';
import 'package:provider/provider.dart';

class RatingScreen extends StatefulWidget {
  final int sessionId;


  const RatingScreen({
    super.key,
    required this.sessionId,
   
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RatingController(),
      child: Consumer<RatingController>(
        builder: (context, controller, _) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              goToSchedule(context);
            },
            child: Scaffold(
              backgroundColor: Kolors.kPrimary,
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
          colors: [Kolors.kPrimary, Kolors.kPrimary, Kolors.kWhite],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      // --- Premium Header ---
                      _buildHeader(context),

                      // --- Floating Sheet ---
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(top: 10.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(35.r),
                              topRight: Radius.circular(35.r),
                            ),
                          ),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: 30.w),
                            child: Column(
                              children: [
                                SizedBox(height: 35.h),
                                // Hero Icon
                                _buildHeroIcon(controller.rating),
                                
                                SizedBox(height: 25.h),
                                Text(
                                  "How was the service?",
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w900,
                                    color: Kolors.kDark,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  "Your feedback helps us maintain the highest service standards.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade500,
                                    height: 1.4,
                                  ),
                                ),
                                
                                SizedBox(height: 35.h),
                                // Stars Row
                                _buildStarRating(controller),
                                
                                SizedBox(height: 15.h),
                                // Mood Label
                                AnimatedOpacity(
                                  opacity: controller.rating > 0 ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 300),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                                    decoration: BoxDecoration(
                                      color: Kolors.kPrimary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Text(
                                      controller.rating > 0 ? _getMoodText(controller.rating).toUpperCase() : "",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: Kolors.kPrimary,
                                        fontSize: 12.sp,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 35.h),
                                // Comment Box
                                _buildCommentField(controller),
                                
                                SizedBox(height: 40.h),
                                // Actions
                                _buildSubmitButton(controller),
                                
                                TextButton(
                                  onPressed: () => goToSchedule(context),
                                  child: Text(
                                    "Skip for now",
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.h),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Ionicons.chevron_back, color: Colors.white),
            onPressed: () => goToSchedule(context),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Rate Experience",
                style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              Text(
  "Session ID: #${widget.sessionId}",
  style: TextStyle(color: Colors.white70, fontSize: 12.sp),
),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroIcon(int rating) {
    return Container(
      height: 100.h,
      width: 100.h,
      decoration: BoxDecoration(
        color: Kolors.kPrimary.withOpacity(0.05),
        shape: BoxShape.circle,
        border: Border.all(color: Kolors.kPrimary.withOpacity(0.1), width: 2),
      ),
      child: Center(
        child: Icon(
          rating >= 4 ? Ionicons.happy_outline : (rating == 0 ? Ionicons.star : Ionicons.chatbubble_ellipses_outline),
          color: Kolors.kPrimary,
          size: 50.sp,
        ),
      ),
    );
  }

  Widget _buildStarRating(RatingController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        bool isSelected = index < controller.rating;
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            controller.setRating(index + 1);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()..scale(isSelected ? 1.1 : 1.0),
            child: Icon(
              isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
              color: isSelected ? Colors.orangeAccent : Colors.grey.shade300,
              size: 52.sp,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCommentField(RatingController controller) {
    return TextField(
      controller: _commentController,
      maxLines: 4,
      onChanged: controller.setComment,
      decoration: InputDecoration(
        hintText: "Tell us more about your experience...",
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
        filled: true,
        fillColor: Colors.grey.shade50,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: const BorderSide(color: Kolors.kPrimary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(RatingController controller) {
    bool canSubmit = controller.rating > 0 && !controller.isSubmitting;
    
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: !canSubmit
            ? null
            : () async {
                HapticFeedback.mediumImpact();
                final success = await controller.submitRating(
                    sessionId: widget.sessionId);

                if (success && mounted) {
                  _showSuccessDialog();
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Kolors.kPrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade200,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
          elevation: canSubmit ? 4 : 0,
        ),
        child: controller.isSubmitting
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Text(
                "SUBMIT REVIEW",
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
      ),
    );
  }

  String _getMoodText(int rating) {
    const moods = ["Disappointing", "Fair", "Good", "Great", "Amazing!"];
    return moods[rating - 1];
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
          child: Padding(
            padding: EdgeInsets.all(25.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Ionicons.checkmark_done, color: Colors.green, size: 50),
                ),
                SizedBox(height: 25.h),
                Text(
                  "Review Shared!",
                  style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: Kolors.kDark),
                ),
                SizedBox(height: 10.h),
                Text(
                  "Thank you for helping us grow. Your feedback is now live.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, height: 1.5, fontSize: 14.sp),
                ),
                SizedBox(height: 30.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Provider.of<TabIndexNotifier>(context, listen: false).setIndex(0);
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const EntryPoint()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Kolors.kDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                    ),
                    child: const Text("BACK TO HOME",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}