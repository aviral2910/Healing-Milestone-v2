import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/core/router/app_routes.dart';
import 'package:healing_milestones/logo/healing_milestone_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    // Wait for 1.2 seconds to show the logo
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: HealingMilestonesStaticLogoWidget(
          logoSize: 180,
          showText: false,
        ),
      ),
    );
  }
}
