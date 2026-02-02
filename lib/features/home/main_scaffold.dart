import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/bottom_nav_bar.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  final String location;

  const MainScaffold({super.key, required this.child, required this.location});

  int get _currentIndex {
    // Determine current index based on location
    if (location.startsWith('/lessons')) return 1;
    if (location.startsWith('/free-piano')) return 2;
    if (location.startsWith('/progress')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0; // Home
  }

  void _onBottomNavTapped(BuildContext context, int index) {
    // Prevent navigation if already on the same screen
    if (index == _currentIndex) return;

    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/lessons');
        break;
      case 2:
        context.go('/free-piano');
        break;
      case 3:
        context.go('/progress');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => _onBottomNavTapped(context, index),
      ),
    );
  }
}
