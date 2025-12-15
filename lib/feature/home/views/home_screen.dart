import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tawassal/core/routing/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Center(
                child: const Text(
                  'Hello!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'What would you like to do today?',
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SizedBox(height: 20),

                    buildFeatureCard(
                      context: context,
                      title: 'Speech To Text',
                      subtitle:
                          'Let me hear your voice!\nI\'ll write it down for you',
                      buttonText: 'Start',
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFF7043), Color(0xFFFFAB91)],
                      ),
                      illustration: buildGlobeIllustration(),
                      onTap: () => context.push(AppRoutes.speechToText),
                    ),

                    const SizedBox(height: 20),

                    buildFeatureCard(
                      context: context,
                      title: 'Text To Speech',
                      subtitle: 'Type any word\nI\'ll say it for you!',
                      buttonText: 'Start',
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF66BB6A), Color(0xFF81C784)],
                      ),
                      illustration: buildSpeakerIllustration(),
                      onTap: () => context.push(AppRoutes.textToSpeech),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(),
    );
  }

  Widget buildFeatureCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String buttonText,
    required Gradient gradient,
    required Widget illustration,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.95),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        color: gradient.colors.first,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(right: -20, top: 20, bottom: 20, child: illustration),
          ],
        ),
      ),
    );
  }

  Widget buildRobotIllustration() {
    return Container(
      width: 120,
      alignment: Alignment.center,
      child: Icon(
        Icons.smart_toy_rounded,
        size: 90,
        color: Colors.white.withOpacity(0.25),
      ),
    );
  }

  Widget buildGlobeIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.15),
          ),
        ),
        Icon(
          Icons.language_rounded,
          size: 80,
          color: Colors.white.withOpacity(0.35),
        ),
      ],
    );
  }

  Widget buildSpeakerIllustration() {
    return Container(
      width: 120,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.volume_up_rounded,
            size: 90,
            color: Colors.white.withOpacity(0.25),
          ),
          Positioned(
            right: 10,
            child: Icon(
              Icons.graphic_eq_rounded,
              size: 40,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomNavBar() {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
    );
  }

  Widget buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF4CAF50) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.white : Colors.grey[400],
            size: 26,
          ),
        ),
        if (isActive) ...[
          const SizedBox(height: 4),
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ],
    );
  }
}
