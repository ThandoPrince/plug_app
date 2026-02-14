import 'package:flutter/material.dart';

import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:flutter_application_1/global_util/services/controler/submit_ratings_controller.dart';
import 'package:flutter_application_1/screens/entryPoint/controller/bottom_tab_notifier.dart';
import 'package:flutter_application_1/screens/entryPoint/views/entry_point.dart';
import 'package:flutter_application_1/screens/schedule/widgets/go_to_schedule_helper.dart';
import 'package:provider/provider.dart';

class RatingScreen extends StatefulWidget {
  final int sessionId;
  final String clientEmail;

  const RatingScreen({
    super.key,
    required this.sessionId,
    required this.clientEmail,
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
          return WillPopScope(
             onWillPop: () async {
    goToSchedule(context);
    return false;
  },
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => goToSchedule(context),
      ),
                backgroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                title: Text(
                  "Session # ${widget.sessionId}",
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                automaticallyImplyLeading: false,
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Kolors.kPrimary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star_rounded,
                          color: Kolors.kPrimary, size: 60),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "How was the service?",
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF263238)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Your feedback helps us improve the quality of service for everyone.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15, color: Colors.blueGrey.shade400, height: 1.5),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () => controller.setRating(index + 1),
                          icon: Icon(
                            index < controller.rating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: index < controller.rating ? Colors.orange : Colors.grey.shade300,
                            size: 45,
                          ),
                        );
                      }),
                    ),
                    if (controller.rating > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _getMoodText(controller.rating),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Kolors.kPrimary,
                          ),
                        ),
                      ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _commentController,
                      maxLines: 4,
                      onChanged: controller.setComment,
                      decoration: InputDecoration(
                        hintText: "Anything else you'd like to share?",
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        filled: true,
                        fillColor: const Color(0xFFF5F7F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: (controller.rating == 0 || controller.isSubmitting)
                            ? null
                            : () async {
                                final success = await controller.submitRating(
                                    sessionId: widget.sessionId,
                                    clientEmail: widget.clientEmail);
            
                                if (success && mounted) {
                                  _showSuccessDialog();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Kolors.kPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
                        ),
                        child: controller.isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text("SUBMIT RATING",
                                style:
                                    TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Skip for now", style: TextStyle(color: Colors.grey.shade500)),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded,
                      color: Colors.green, size: 50),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Thank You!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Your feedback helps us provide a better experience for everyone.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, height: 1.4),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // close dialog
                      Provider.of<TabIndexNotifier>(context, listen: false).setIndex(0);
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const EntryPoint()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Kolors.kPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("DONE",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
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
