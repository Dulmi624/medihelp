import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../services/auth_service.dart';
import 'admin_appointments_screen.dart';
import 'admin_queue_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_demo_store.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;
  final _store = AdminDataStore.instance;

  @override
  void initState() {
    super.initState();
    _store.addListener(_refresh);
    _store.start();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _store.removeListener(_refresh);
    _store.stop();
    super.dispose();
  }

  void _openTab(int index) => setState(() => _selectedIndex = index);

  static const _titles = [
    'Admin Dashboard',
    'Appointment Overview',
    'Queue Monitoring',
    'Reports',
  ];

  Future<void> _logout() async {
    await AuthService().signOut();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  Widget _buildDashboard() {
    if (_store.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_store.error!),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  _store.start();
                });
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_store.loading) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Welcome, Admin',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Live appointments and queues • Totals across all dates'),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _StatCard(
              title: 'Appointments',
              value: (_store.appointments.length).toString(),
              onTap: () => _openTab(1),
              icon: Icons.calendar_month,
            ),
            _StatCard(
              title: 'In Queue',
              value:
                  (_store.patients
                          .where(
                            (p) =>
                                p.status == 'Waiting' || p.status == 'Called',
                          )
                          .length)
                      .toString(),
              onTap: () => _openTab(2),
              icon: Icons.people_outline,
            ),
            _StatCard(
              title: 'Waiting',
              value:
                  (_store.patients.where((p) => p.status == 'Waiting').length)
                      .toString(),
              onTap: () => _openTab(2),
              icon: Icons.schedule,
            ),
            _StatCard(
              title: 'Completed',
              value:
                  (_store.appointments
                          .where((a) => a.status == 'Completed')
                          .length)
                      .toString(),
              onTap: () => _openTab(1),
              icon: Icons.check_circle_outline,
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Department Queue Status',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Text('In queue includes Waiting and Called patients.'),
        if (_store.departments.isEmpty) const Text('No departments yet.'),
        for (final department in _store.departments)
          Card(
            child: ListTile(
              title: Text(department),
              subtitle: Text(
                '${_store.patients.where((p) => p.department == department && (p.status == 'Waiting' || p.status == 'Called')).length} in queue',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openTab(2),
            ),
          ),
        const SizedBox(height: 20),
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Text('Actions performed in this Admin session only.'),
        if (_store.activity.isEmpty)
          const Text('No actions in this session yet.'),
        for (final message in _store.activity.take(5))
          ListTile(leading: const Icon(Icons.history), title: Text(message)),
        const SizedBox(height: 24),
        if (_store.skippedAppointments + _store.skippedQueues > 0)
          Text(
            '${_store.skippedAppointments} appointments and ${_store.skippedQueues} queue entries could not be linked or have missing fields. Ask the team to review older records.',
          ),
        const Text(
          'Quick Access',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _quickLink('View Appointments', Icons.calendar_month, 1),
        _quickLink('Monitor Queue', Icons.people_outline, 2),
        _quickLink('View Reports', Icons.bar_chart, 3),
      ],
    );
  }

  Widget _quickLink(String title, IconData icon, int index) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(),
          const AdminAppointmentsScreen(),
          const AdminQueueScreen(),
          const AdminReportsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Appointments',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Queue',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.icon,
    required this.value,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
