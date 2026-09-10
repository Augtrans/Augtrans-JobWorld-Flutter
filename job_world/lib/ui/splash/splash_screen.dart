import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../routes/AppRoute.dart';
import '../../util/app_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Small delay to show splash logo if needed
    await Future.delayed(const Duration(seconds: 2));
    
    final token = await AppPreferences.getAccessToken();
    final role = await AppPreferences.getUserRole();
    
    if (mounted) {
      if (token != null && token.isNotEmpty) {
        final roleUpper = (role ?? "").trim().toUpperCase();
        if (roleUpper == "TL" || roleUpper == "TEAM LEAD" || roleUpper == "TEAMLEAD") {
          context.go(AppRoutes.tlMainNavigation);
        } else {
          context.go(AppRoutes.home);
        }
      } else {
        context.go(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/png/main_logo.png",
              height: 100,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
