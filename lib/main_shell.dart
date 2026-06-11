import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'features/auth/data/auth_service.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/events/presentation/screens/events_screen.dart';
import 'features/my_events/presentation/screens/my_events_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/home/presentation/screens/admin_page.dart';

class MainShell extends StatefulWidget {
  final AuthService authService;
  const MainShell({super.key, required this.authService});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(authService: widget.authService),
      const EventsScreen(),
      const MyEventsScreen(),
      if (widget.authService.isAdmin) const AdminPage(),
      ProfileScreen(authService: widget.authService),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.authService.isAdmin;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() => _currentIndex = index);
        },
        indicatorColor: AppColors.accent,
        selectedIndex: _currentIndex,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        destinations: [
          const NavigationDestination(
            selectedIcon: Icon(Icons.home, color: AppColors.primary),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          const NavigationDestination(
            selectedIcon: Icon(Icons.calendar_month, color: AppColors.primary),
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Events',
          ),
          const NavigationDestination(
            selectedIcon: Icon(Icons.bookmark, color: AppColors.primary),
            icon: Icon(Icons.bookmark_outline),
            label: 'My Events',
          ),
          if (isAdmin)
            const NavigationDestination(
              selectedIcon: Icon(
                Icons.admin_panel_settings,
                color: AppColors.primary,
              ),
              icon: Icon(Icons.admin_panel_settings_outlined),
              label: 'Admin',
            ),
          const NavigationDestination(
            selectedIcon: Icon(Icons.person, color: AppColors.primary),
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
