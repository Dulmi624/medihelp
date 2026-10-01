import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/patient_bottom_nav.dart';
import '../../widgets/primary_button.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MediQueue'), actions: [IconButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications), icon: const Icon(Icons.notifications_none)), IconButton(tooltip: 'Log out', onPressed: () async { await AuthService().signOut(); if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false); }, icon: const Icon(Icons.logout))]),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Book Your Appointment Easily', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w800)), SizedBox(height: 8), Text('Skip the queue and get the care you need.', style: TextStyle(color: Colors.white70)), SizedBox(height: 18), Icon(Icons.calendar_month, color: AppColors.logoBlue, size: 42)]),
        ),
        const SizedBox(height: 28),
        const Text('Select Service', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _ServiceCard(icon: Icons.add_circle_outline, title: 'OPD Appointment', onTap: () => Navigator.pushNamed(context, AppRoutes.selectDoctor))),
          const SizedBox(width: 12),
          Expanded(child: _ServiceCard(icon: Icons.event_note_outlined, title: 'My Appointments', onTap: () => Navigator.pushNamed(context, AppRoutes.myAppointment))),
        ]),
        const SizedBox(height: 28),
        const Text('Other Services', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Card(elevation: 0, child: Column(children: const [_OtherService(icon: Icons.search, title: 'Find a Doctor'), _OtherService(icon: Icons.local_hospital_outlined, title: 'Hospital Info'), _OtherService(icon: Icons.phone_outlined, title: 'Contact Us')])),
        const SizedBox(height: 20),
        PrimaryButton(label: 'View Queue Updates', onPressed: () => Navigator.pushNamed(context, AppRoutes.queueDetails)),
      ]),
      bottomNavigationBar: const PatientBottomNav(currentIndex: 0),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.icon, required this.title, required this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(elevation: 0, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: AppColors.primary, size: 32), const SizedBox(height: 18), Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 8), const Icon(Icons.arrow_forward, color: AppColors.mutedText, size: 18)]))));
}

class _OtherService extends StatelessWidget {
  const _OtherService({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) => ListTile(leading: Icon(icon, color: AppColors.primary), title: Text(title), trailing: const Icon(Icons.chevron_right));
}