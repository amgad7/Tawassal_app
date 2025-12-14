import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tawassal/core/routing/app_routes.dart';
import 'package:tawassal/core/styling/app_assets.dart';

import '../model/onBoarding_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController pageController = PageController();
  int currentPage = 0;

  final List<OnboardingData> pages = [
    OnboardingData(
      image: AppAssets.onBoarding1,
      title: 'Your words, mastered.',
      titleAr: 'كلماتك، متقنة.',
      description: 'Master new words. Hear them spoken correctly.',
      descriptionAr: 'أتقن كلمات جديدة. استمع إليها بالنطق الصحيح.',
    ),
    OnboardingData(
      image: AppAssets.onBoarding2,
      title: 'Speak with confidence.',
      titleAr: 'تحدث بثقة.',
      description: 'Start with clearly spoken, essential vocabulary.',
      descriptionAr: 'ابدأ بمفردات أساسية منطوقة بوضوح.',
    ),
    OnboardingData(
      image: AppAssets.onBoarding3,
      title: 'Track your child\'s success.',
      titleAr: 'تابع نجاح طفلك.',
      description: 'Watch detailed reports on your child\'s progress.',
      descriptionAr: 'شاهد تقارير مفصلة عن تقدم طفلك.',
    ),
  ];

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (currentPage > 0)
                    GestureDetector(
                      onTap: () {
                        pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18.sp,
                        ),
                      ),
                    )
                  else
                    SizedBox(width: 40.w),

                  TextButton(
                    onPressed: () =>
                        context.pushReplacementNamed(AppRoutes.mainScreen),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: pageController,
                onPageChanged: (index) {
                  setState(() => currentPage = index);
                },
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return buildPageContent(pages[index]);
                },
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (currentPage > 0)
                    GestureDetector(
                      onTap: () {
                        pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 48.w,
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: const Color(0xFF4CAF50),
                          size: 20.sp,
                        ),
                      ),
                    )
                  else
                    SizedBox(width: 48.w),

                  Row(
                    children: List.generate(
                      pages.length,
                      (index) => buildIndicatorDot(index),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      if (currentPage == pages.length - 1) {
                        context.pushReplacementNamed(AppRoutes.mainScreen);
                      } else {
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        currentPage == pages.length - 1
                            ? Icons.check_rounded
                            : Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget buildPageContent(OnboardingData data) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Column(
          children: [
            SizedBox(height: 10.h),

            Container(
              height: 300.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30.r),
                child: Image.asset(data.image, fit: BoxFit.cover),
              ),
            ),

            SizedBox(height: 30.h),

            Text(
              data.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF212121),
              ),
            ),

            SizedBox(height: 12.h),

            Text(
              data.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.grey[600],
                height: 1.6,
              ),
            ),

            SizedBox(height: 12.h),

            Text(
              data.titleAr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),

            SizedBox(height: 12.h),

            Text(
              data.descriptionAr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                height: 1.6,
              ),
            ),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget buildIndicatorDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      height: 8.h,
      width: currentPage == index ? 24.w : 8.w,
      decoration: BoxDecoration(
        color: currentPage == index
            ? const Color(0xFF4CAF50)
            : Colors.grey[300],
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}
