import 'package:flutter/material.dart';

import '../core/routes.dart';
import '../core/theme.dart';

class PatientBottomNav extends StatelessWidget {
  const PatientBottomNav({required this.currentIndex, super.key});

  final int currentIndex;

  void _select(BuildContext context, int index) {
    final routes = [AppRoutes.patientHome, AppRoutes.myAppointment, AppRoutes.queueStatus, AppRoutes.notifications];
    if (index != currentIndex) Navigator.of(context).pushReplacementNamed(routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => _select(context, index),
      indicatorColor: AppColors.primary.withAlpha(24),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'My Appt'),
        NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Queue'),
        NavigationDestination(icon: Icon(Icons.notifications_none), selectedIcon: Icon(Icons.notifications), label: 'Notifications'),
      ],
    );
  }
}