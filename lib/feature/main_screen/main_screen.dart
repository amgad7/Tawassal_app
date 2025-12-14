import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tawassal/feature/history_screen/views/history_screen.dart';
import 'package:tawassal/feature/profile_screen/views/profile_screen.dart';
import '../../core/styling/app_colors.dart';
import '../home/views/home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final List<Widget> screens = const [
    HomeScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: Colors.grey[400],
          currentIndex: currentIndex,
          elevation: 0,
          selectedFontSize: 12.sp,
          unselectedFontSize: 11.sp,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          onTap: (value) {
            setState(() {
              currentIndex = value;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Icon(
                  currentIndex == 0 ? Icons.home : Icons.home_outlined,
                  size: 28.sp,
                ),
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Icon(
                  currentIndex == 1 ? Icons.history : Icons.history_outlined,
                  size: 28.sp,
                ),
              ),
              label: "History",
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Icon(
                  currentIndex == 2 ? Icons.person : Icons.person_outline,
                  size: 28.sp,
                ),
              ),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
