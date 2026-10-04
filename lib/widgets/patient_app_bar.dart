import 'package:flutter/material.dart';

import '../core/routes.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';

class PatientAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PatientAppBar({
    required this.title,
    this.subtitle,
    this.subtitleIcon,
    this.showBackButton = false,
    this.onGradient = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? subtitleIcon;
  final bool showBackButton;
  final bool onGradient;

  Future<void> _logout(BuildContext context) async {
    await AuthService().signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: showBackButton
          ? IconButton(
              color: onGradient ? AppColors.onPrimary : AppColors.text,
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.maybePop(context),
            )
          : PopupMenuButton<String>(
              icon: Icon(
                Icons.menu,
                color: onGradient ? AppColors.onPrimary : AppColors.text,
              ),
              onSelected: (value) {
                if (value == 'logout') _logout(context);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'logout', child: Text('Log out')),
              ],
            ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: onGradient ? AppColors.onPrimary : AppColors.primaryDark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (subtitleIcon != null)
                  Icon(
                    subtitleIcon,
                    color: onGradient
                        ? AppColors.onPrimary
                        : AppColors.mutedText,
                    size: 13,
                  ),
                if (subtitleIcon != null) const SizedBox(width: 3),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: onGradient
                        ? AppColors.onPrimary
                        : AppColors.mutedText,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
      ),
      centerTitle: true,
      actions: [
        Stack(
          children: [
            IconButton(
              color: onGradient ? AppColors.onPrimary : AppColors.text,
              tooltip: 'Notifications',
              onPressed: () => Navigator.pushReplacementNamed(
                context,
                AppRoutes.notifications,
              ),
              icon: const Icon(Icons.notifications_none),
            ),
            const Positioned(
              right: 10,
              top: 8,
              child: CircleAvatar(radius: 4, backgroundColor: AppColors.danger),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            radius: 17,
            backgroundColor: onGradient
                ? AppColors.onPrimary
                : AppColors.avatarTint,
            child: Icon(
              Icons.person_outline,
              color: onGradient ? AppColors.primary : AppColors.primaryDark,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(76);
}
