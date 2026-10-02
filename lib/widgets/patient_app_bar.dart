import 'package:flutter/material.dart';

import '../core/routes.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';

class PatientAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PatientAppBar({required this.title, super.key});

  final String title;

  Future<void> _logout(BuildContext context) async {
    await AuthService().signOut();
    if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: PopupMenuButton<String>(
        icon: const Icon(Icons.menu),
        onSelected: (value) {
          if (value == 'logout') _logout(context);
        },
        itemBuilder: (_) => const [PopupMenuItem(value: 'logout', child: Text('Log out'))],
      ),
      title: Text(title, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
      centerTitle: true,
      actions: [
        IconButton(tooltip: 'Notifications', onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.notifications), icon: const Icon(Icons.notifications_none)),
        const Padding(padding: EdgeInsets.only(right: 16), child: CircleAvatar(radius: 16, backgroundColor: AppColors.lightBlue, child: Icon(Icons.person_outline, color: AppColors.primary, size: 19))),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}