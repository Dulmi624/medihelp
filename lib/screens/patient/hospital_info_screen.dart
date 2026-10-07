import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../widgets/patient_app_bar.dart';
import '../../widgets/patient_bottom_nav.dart';

class HospitalInfoScreen extends StatelessWidget {
  const HospitalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PatientAppBar(
        title: 'Hospital Info',
        subtitle: 'MediQueue Central Hospital',
        showBackButton: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.page),
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 96, 20, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.local_hospital_outlined, color: Colors.white, size: 42),
                    SizedBox(height: 14),
                    Text('MediQueue Central Hospital', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                    SizedBox(height: 6),
                    Text('Trusted care, close to you.', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const _InfoCard(
                title: 'Opening hours',
                icon: Icons.schedule_outlined,
                children: [
                  _InfoLine('Monday - Friday', '8:00 AM - 6:00 PM'),
                  _InfoLine('Saturday', '8:00 AM - 1:00 PM'),
                  _InfoLine('Emergency care', 'Open 24 hours'),
                ],
              ),
              const SizedBox(height: 14),
              const _InfoCard(
                title: 'Our facilities',
                icon: Icons.medical_services_outlined,
                children: [
                  _Bullet('Outpatient Department (OPD)'),
                  _Bullet('Pharmacy and laboratory'),
                  _Bullet('Emergency and urgent care'),
                  _Bullet('Accessible parking and wheelchair access'),
                ],
              ),
              const SizedBox(height: 14),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                  title: const Text('Visit us', style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: const Text('No. 25 Hospital Road, Colombo'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showMessage(context, 'Address copied: No. 25 Hospital Road, Colombo'),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const PatientBottomNav(currentIndex: 0),
    );
  }

  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.icon, required this.children});
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(icon, color: AppColors.primary), const SizedBox(width: 10), Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))]),
            const SizedBox(height: 14),
            ...children,
          ]),
        ),
      );
}

class _InfoLine extends StatelessWidget {
  const _InfoLine(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [Expanded(child: Text(label)), Text(value, style: const TextStyle(fontWeight: FontWeight.w700))]),
      );
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [const Icon(Icons.check_circle_outline, color: AppColors.success, size: 19), const SizedBox(width: 10), Expanded(child: Text(text))]),
      );
}
