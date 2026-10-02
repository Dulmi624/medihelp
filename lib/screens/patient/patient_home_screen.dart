import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/patient_bottom_nav.dart';
import '../../widgets/service_card.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  void _comingSoon(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon')));

  Future<void> _logout(BuildContext context) async {
    await AuthService().signOut();
    if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            Row(children: [
              const CircleAvatar(radius: 22, backgroundColor: AppColors.primary, child: Icon(Icons.local_hospital_outlined, color: AppColors.onPrimary)),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('MediQueue', style: TextStyle(fontSize: 20, color: AppColors.primary, fontWeight: FontWeight.w800)), SizedBox(height: 2), Text('Hospital Management System', style: TextStyle(color: AppColors.mutedText, fontSize: 12))])),
              Stack(children: [IconButton(tooltip: 'Notifications', onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.notifications), icon: const Icon(Icons.notifications_none)), const Positioned(right: 10, top: 8, child: CircleAvatar(radius: 4, backgroundColor: AppColors.danger))]),
              PopupMenuButton<String>(icon: const Icon(Icons.more_vert), onSelected: (value) { if (value == 'logout') _logout(context); }, itemBuilder: (_) => const [PopupMenuItem(value: 'logout', child: Text('Log out'))]),
            ]),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 10, 14),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Book Your Appointment Easily', style: TextStyle(color: AppColors.onPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        const Text('Quality Care, Brighter Tomorrows', style: TextStyle(color: AppColors.onPrimary)),
                        const SizedBox(height: 16),
                        Row(children: [
                          Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.onPrimary, shape: BoxShape.circle)),
                          const SizedBox(width: 5),
                          Container(width: 7, height: 7, decoration: BoxDecoration(color: AppColors.logoBlue.withAlpha(150), shape: BoxShape.circle)),
                          const SizedBox(width: 5),
                          Container(width: 7, height: 7, decoration: BoxDecoration(color: AppColors.logoBlue.withAlpha(150), shape: BoxShape.circle)),
                        ]),
                      ],
                    ),
                  ),
                  const Icon(Icons.medical_services_outlined, color: AppColors.logoBlue, size: 86),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text('Select Service', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: SizedBox(height: 168, child: ServiceCard(icon: Icons.add_circle_outline, title: 'OPD Appointment', subtitle: 'Book a doctor visit', onTap: () => Navigator.pushNamed(context, AppRoutes.comingSoon)))),
              const SizedBox(width: 12),
              Expanded(child: SizedBox(height: 168, child: ServiceCard(icon: Icons.event_note_outlined, title: 'My Appointments', subtitle: 'View or manage your appointments', onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.myAppointment)))),
            ]),
            const SizedBox(height: 28),
            const Text('Other Services', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Row(children: [_OtherService(icon: Icons.search, title: 'Find a Doctor', onTap: () => _comingSoon(context)), _OtherService(icon: Icons.local_hospital_outlined, title: 'Hospital Info', onTap: () => _comingSoon(context)), _OtherService(icon: Icons.phone_outlined, title: 'Contact Us', onTap: () => _comingSoon(context))]),
          ],
        ),
      ),
      bottomNavigationBar: const PatientBottomNav(currentIndex: 0),
    );
  }
}

class _OtherService extends StatelessWidget {
  const _OtherService({required this.icon, required this.title, required this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(child: Card(elevation: 0, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Padding(padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 6), child: Column(children: [Icon(icon, color: AppColors.primary, size: 28), const SizedBox(height: 10), Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))])))));
}
