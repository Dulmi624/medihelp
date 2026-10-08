import 'package:flutter/material.dart';

import '../../models/app_notification.dart';
import '../../services/dummy_data.dart';
import '../../widgets/notification_tile.dart';
import '../../widgets/patient_app_bar.dart';
import '../../widgets/patient_bottom_nav.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({this.initialTab = 0, super.key});
  final int initialTab;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late List<AppNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = DummyData.notifications.toList();
    _tabController = TabController(length: 3, initialIndex: widget.initialTab.clamp(0, 2), vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AppNotification> _filtered(NotificationType? type) => type == null ? _notifications : _notifications.where((item) => type == NotificationType.queueUpdate ? item.type == NotificationType.queueUpdate : item.type == NotificationType.confirmed || item.type == NotificationType.reminder || item.type == NotificationType.rescheduled).toList();

  void _markRead(AppNotification notification) {
    final index = _notifications.indexOf(notification);
    if (index >= 0 && !notification.isRead) setState(() => _notifications[index] = notification.copyWith(isRead: true));
  }

  Widget _list(List<AppNotification> items) => ListView.separated(padding: const EdgeInsets.all(16), itemCount: items.length, separatorBuilder: (_, _) => const SizedBox(height: 8), itemBuilder: (_, index) => NotificationTile(notification: items[index], onTap: () => _markRead(items[index])));

  @override
  Widget build(BuildContext context) => Scaffold(appBar: PreferredSize(preferredSize: const Size.fromHeight(104), child: Column(children: [const PatientAppBar(title: 'Notifications'), TabBar(controller: _tabController, tabs: const [Tab(text: 'All'), Tab(text: 'Appointments'), Tab(text: 'Queue')])])), body: TabBarView(controller: _tabController, children: [_list(_filtered(null)), _list(_filtered(NotificationType.confirmed)), _list(_filtered(NotificationType.queueUpdate))]), bottomNavigationBar: const PatientBottomNav(currentIndex: 3));
}
