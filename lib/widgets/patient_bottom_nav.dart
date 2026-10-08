import 'package:flutter/material.dart';

import '../core/routes.dart';
import '../core/theme.dart';

class PatientBottomNav extends StatelessWidget {
  const PatientBottomNav({required this.currentIndex, super.key});

  final int currentIndex;

  void _select(BuildContext context, int index) {
    final routes = [
      AppRoutes.patientHome,
      AppRoutes.myAppointment,
      AppRoutes.queueStatus,
      AppRoutes.notifications,
    ];
    if (index != currentIndex) {
      Navigator.of(context).pushReplacementNamed(routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    const destinations = [
      (Icons.home_outlined, Icons.home, 'Home'),
      (Icons.calendar_month_outlined, Icons.calendar_month, 'My Appt'),
      (Icons.people_outline, Icons.people, 'Queue'),
      (Icons.notifications_none, Icons.notifications, 'Notifications'),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var index = 0; index < destinations.length; index++)
            Expanded(
              child: _NavItem(
                icon: destinations[index].$1,
                activeIcon: destinations[index].$2,
                label: destinations[index].$3,
                selected: index == currentIndex,
                showDot: index == 3,
                onTap: () => _select(context, index),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.showDot,
    required this.onTap,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final bool showDot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.primarySoft : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Icon(
                selected ? activeIcon : icon,
                color: selected ? AppColors.primary : AppColors.mutedText,
                size: 22,
              ),
              if (showDot)
                const Positioned(
                  right: -1,
                  top: 0,
                  child: CircleAvatar(
                    radius: 3,
                    backgroundColor: AppColors.danger,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? AppColors.primary : AppColors.mutedText,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
