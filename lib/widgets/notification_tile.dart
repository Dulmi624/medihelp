import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/app_notification.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({required this.notification, required this.onTap, super.key});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (notification.type) {
      NotificationType.confirmed => (Icons.calendar_month, AppColors.success),
      NotificationType.queueUpdate => (Icons.people_alt_outlined, AppColors.primary),
      NotificationType.reminder => (Icons.notifications_none, AppColors.warning),
      NotificationType.rescheduled => (Icons.calendar_month, AppColors.warning),
      NotificationType.general => (Icons.info_outline, AppColors.primary),
    };
    return Card(elevation: 0, child: ListTile(onTap: onTap, leading: CircleAvatar(backgroundColor: color.withAlpha(24), child: Icon(icon, color: color)), title: Text(notification.title, style: TextStyle(fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w800)), subtitle: Text('${notification.message}\n${notification.time}'), isThreeLine: true, trailing: notification.isRead ? null : const CircleAvatar(radius: 5, backgroundColor: AppColors.primary)));
  }
}