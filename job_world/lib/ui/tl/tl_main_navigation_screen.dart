import 'package:flutter/material.dart';
import 'package:job_world/ui/tl/home/tl_home_screen.dart';
import 'package:job_world/ui/tl/jobs/tl_job_listings_screen.dart';
import 'package:job_world/util/colors.dart';
import 'package:job_world/util/dimensions.dart';

class TlMainNavigationScreen extends StatefulWidget {
  const TlMainNavigationScreen({super.key});

  @override
  State<TlMainNavigationScreen> createState() => _TlMainNavigationScreenState();
}

class _TlMainNavigationScreenState extends State<TlMainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TlHomeScreen(),
    const TlJobListingsScreen(),
    const Scaffold(body: Center(child: Text("TL Profile & Settings"))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(Dimensions.level3Margin(context)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primaryBlue,
            unselectedItemColor: Colors.grey.shade400,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                activeIcon: Icon(Icons.home_rounded, color: AppColors.primaryBlue),
                label: "HOME",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.business_center_outlined),
                activeIcon: Icon(Icons.business_center_rounded, color: AppColors.primaryBlue),
                label: "JOBS",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded, color: AppColors.primaryBlue),
                label: "PROFILE",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
