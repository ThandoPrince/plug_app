import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/utils/kcolors.dart';


// Standardizing colors for a clean look
const Color primaryColor = Kolors.kPrimary;
const Color backgroundColor1 = Kolors.kPrimary;
const Color backgroundColor2 = Kolors.kWhite;

class OnboardingScreenOne extends StatefulWidget {
  const OnboardingScreenOne({super.key});

  @override
  State<OnboardingScreenOne> createState() => _OnboardingScreenOneState();
}

class _OnboardingScreenOneState extends State<OnboardingScreenOne> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [ Kolors.kPrimary,
                  Kolors.kPrimary,
                  Kolors.kSecondaryLight], // Deep brand gradient
                  ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              children: [
                const SizedBox(height: 50),

                // --- Catchy Headline ---
                const Text(
                  'Your Daily Needs,\nSimplified.',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -1,
                    color: Colors.white, // White text looks better against the primary top
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // --- Hero Section (GIF) ---
                Expanded(
                  flex: 3,
                  child: _buildHeroImage(),
                ),

                const SizedBox(height: 40),

             
                const Text(
                  'The Ultimate Plug',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: Kolors.kDark
                  ),
                ),
                
                const SizedBox(height: 12),

                const Text(
                  'Connect with trusted local providers for home, beauty, and urgent repairs—instantly.',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                
                const Spacer(),
                const SizedBox(height: 120), 
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
  return LayoutBuilder(
    builder: (context, constraints) {
      const double imageWidth = 570;
      const double imageHeight = 1198;
      final double aspectRatio = imageWidth / imageHeight;

      // Make the image take up ~55-60% of the screen height
      final double targetHeight = MediaQuery.of(context).size.height * 0.58;

      return Center(
        child: Container(
          height: targetHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: imageWidth,
                height: imageHeight,
                child: Image.asset(
                  'assets/images/welcome_1_image.gif',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

}