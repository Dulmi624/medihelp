import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../models/app_notification.dart';
import '../../services/dummy_data.dart';
import '../../widgets/patient_bottom_nav.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 3, vsync: this);

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Notifications'), bottom: TabBar(controller: _tabController, tabs: const [Tab(text: 'All'), Tab(text: 'Appointments'), Tab(text: 'Queue')])), body: TabBarView(controller: _tabController, children: [_NotificationList(items: DummyData.notifications), _NotificationList(items: DummyData.notifications.where((item) => item.type == NotificationType.confirmed || item.type == NotificationType.reminder || item.type == NotificationType.rescheduled).toList()), _NotificationList(items: DummyData.notifications.where((item) => item.type == NotificationType.queueUpdate).toList())]), bottomNavigationBar: const PatientBottomNav(currentIndex: 3));
}

class _NotificationList extends StatelessWidget {
  const _NotificationList({required this.items});
  final List<AppNotification> items;

  @override
  Widget build(BuildContext context) => ListView.separated(padding: const EdgeInsets.all(16), itemCount: items.length, separatorBuilder: (_, _) => const SizedBox(height: 8), itemBuilder: (_, index) { final item = items[index]; final (icon, color) = switch (item.type) { NotificationType.confirmed => (Icons.check_circle_outline, AppColors.success), NotificationType.queueUpdate => (Icons.queue, AppColors.primary), NotificationType.reminder => (Icons.alarm, AppColors.warning), NotificationType.rescheduled => (Icons.update, AppColors.danger), NotificationType.general => (Icons.info_outline, AppColors.primary) }; return Card(elevation: 0, child: ListTile(leading: CircleAvatar(backgroundColor: color.withAlpha(24), child: Icon(icon, color: color)), title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text('${item.message}\n${item.time}'), isThreeLine: true, trailing: item.isRead ? null : Container(width: 9, height: 9, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)))); });
}