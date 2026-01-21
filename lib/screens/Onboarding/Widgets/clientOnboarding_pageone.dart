import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

// Assuming Kolors.kPrimary and Kolors.kSecondaryLight are available
// You might want to define a specific secondary/accent color for contrast here.
// I'll use Kolors.kPrimary for main elements and Kolors.kWhite for contrast.
const Color primaryColor = Kolors.kPrimary;
const Color backgroundColor1 = Kolors.kPrimary;
const Color backgroundColor2 = Kolors.kWhite; // To create the gradient effect

class OnboardingScreenOne extends StatefulWidget {
  const OnboardingScreenOne({super.key});

  @override
  State<OnboardingScreenOne> createState() => _OnboardingScreenOneState();
}

class _OnboardingScreenOneState extends State<OnboardingScreenOne> {
  // You can safely remove the loading logic if you are not using it right now.
  // bool _loading = true; 

  @override
  void initState() {
    super.initState();
    // Re-enable this line when you want to use the first-time logic:
    // _checkFirstTime(); 
  }

  Future<void> _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstTime = prefs.getBool('isFirstTime');

    if (isFirstTime == null || isFirstTime == true) {
      // setState(() {
      //   _loading = false;
      // });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Navigating away if not the first time
          context.go('/login'); // Change '/login' to your actual login route
        }
      });
    }
  }

  Future<void> _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    if (!mounted) return;
    context.go('/login'); // Navigate with GoRouter
  }

  @override
  Widget build(BuildContext context) {
    // If you enable the loading state, the logic below can be re-enabled:
    // if (_loading) {
    //   return const Scaffold(
    //     body: Center(child: CircularProgressIndicator()),
    //   );
    // }

    return Scaffold(
      body: Container(
        width: double.infinity,
        // The padding is now inside the column for better control over the text
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            // Use your defined colors for a smooth transition
            colors: [backgroundColor1, backgroundColor2],
            begin: Alignment.topCenter, // Start from the top
            end: Alignment.bottomCenter, // End at the bottom
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const SizedBox(height: 80),
              // --- Welcome Text ---
              Text(
                'Welcome to Plug 🔌!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900, // Make it very bold
                  fontStyle: FontStyle.italic,
                  // Use your primary color for the main title
                  color: primaryColor, 
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // --- GIF/Image Placeholder ---
              _buildAnimatedPlaceholder(),

              const SizedBox(height: 40),
              
              // --- Main Hook Text ---
              Text(
                'Need help around the house or a beauty boost?\n\nWe make it easy to find trusted pros near you.',
                style: TextStyle(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  // Contrast with the background
                  color: Colors.black87, 
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 25),
              
              // --- Second Hook Text (Bolded for Urgency) ---
              Text(
                'Urgently in need of services? We got you!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor, // Highlight the urgent message
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              const Text(
                'Instantly connect with local service providers for all your needs.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),
              
              // --- Call to Action Button ---
             
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for the animated image
  Widget _buildAnimatedPlaceholder() {
    // ⚠️ Replace this with your actual GIF or Lottie asset!
    // Example for a network GIF:
    // return Image.network(
    //   'https://yourdomain.com/path/to/animation.gif',
    //   height: 200,
    // );
    
    return Container(
      width: 250,
      height: 200,
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1), // Light version of primary color
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor, width: 2),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.thumb_up_alt_outlined, // Placeholder icon
              size: 80,
              color: primaryColor,
            ),
            const SizedBox(height: 8),
            const Text(
              "Placeholder for GIF/Animation",
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for the main action button

}