import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tawassal/feature/main_screen/main_screen.dart';
import 'package:tawassal/feature/onBoarding/views/onBoarding_screen.dart';
import 'package:tawassal/feature/splash_screen/splash_screen.dart';
import 'package:tawassal/feature/text_to_speach/views/text_to_speach_screen.dart';

import '../../feature/speach_to_text/views/speach_to_text.dart';
import 'app_routes.dart';

class RouterGenerationConfig {
  static GoRouter goRouter = GoRouter(
    initialLocation: AppRoutes.splashScreen,
    routes: [
      GoRoute(
        name: AppRoutes.onBoardingScreen,
        path: AppRoutes.onBoardingScreen,
        builder: (context, state) => OnboardingScreen(),
      ),

      GoRoute(
        name: AppRoutes.mainScreen,
        path: AppRoutes.mainScreen,
        builder: (context, state) => MainScreen(),
      ),
      GoRoute(
        name: AppRoutes.splashScreen,
        path: AppRoutes.splashScreen,
        builder: (context, state) => SplashScreen(),
      ),
      GoRoute(
        name: AppRoutes.speechToText,
        path: AppRoutes.speechToText,
        builder: (context, state) => SpeechToTextScreen(),
      ),
      GoRoute(
        name: AppRoutes.textToSpeech,
        path: AppRoutes.textToSpeech,
        builder: (context, state) => TextToSpeechScreen(),
      ),
    ],
  );
}
