import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import 'contact_us_screen.dart';
import 'hospital_info_screen.dart';
import 'select_doctor_screen.dart';

import 'dart:async';

import '../../widgets/patient_bottom_nav.dart';
import '../../widgets/service_card.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  String _patientName = 'Patient';
  late Timer _clock;

  @override
  void initState() {
    super.initState();
    _loadPatientName();
    _clock = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadPatientName() async {
    final name = await AuthService().getCurrentPatientName();
    if (mounted) setState(() => _patientName = name);
  }

  @override
  void dispose() {
    _clock.cancel();
    super.dispose();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.page),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primary,
                    child: Icon(
                      Icons.local_hospital_outlined,
                      color: AppColors.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MediQueue',
                          style: TextStyle(
                            fontSize: 20,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Hospital Management System',
                          style: TextStyle(
                            color: AppColors.mutedText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      IconButton(
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
                        child: CircleAvatar(
                          radius: 4,
                          backgroundColor: AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'logout') _logout(context);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'logout', child: Text('Log out')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                '$_greeting, $_patientName',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 10, 14),
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 22,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Book Your Appointment Easily',
                            style: TextStyle(
                              color: AppColors.onPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Quality Care, Brighter Tomorrows',
                            style: TextStyle(color: AppColors.onPrimary),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppColors.onPrimary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: AppColors.logoBlue.withAlpha(150),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: AppColors.logoBlue.withAlpha(150),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.medical_services_outlined,
                      color: AppColors.logoBlue,
                      size: 86,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Select Service',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 168,
                      child: ServiceCard(
                        icon: Icons.add_circle_outline,
                        title: 'OPD Appointment',
                        subtitle: 'Book a doctor visit',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.selectDoctor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 168,
                      child: ServiceCard(
                        icon: Icons.event_note_outlined,
                        title: 'My Appointments',
                        subtitle: 'View or manage your appointments',
                        onTap: () => Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.myAppointment,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Text(
                'Other Services',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                child: Column(
                  children: [
                    _OtherService(
                      icon: Icons.search,
                      title: 'Find a Doctor',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SelectDoctorScreen(
                            title: 'Find a Doctor',
                            showBookingSteps: false,
                          ),
                        ),
                      ),
                    ),
                    _OtherService(
                      icon: Icons.local_hospital_outlined,
                      title: 'Hospital Info',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const HospitalInfoScreen(),
                        ),
                      ),
                    ),
                    _OtherService(
                      icon: Icons.phone_outlined,
                      title: 'Contact Us',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ContactUsScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const PatientBottomNav(currentIndex: 0),
    );
  }
}

class _OtherService extends StatelessWidget {
  const _OtherService({
    required this.icon,
    required this.title,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    minVerticalPadding: 10,
    leading: Icon(icon, color: AppColors.primary, size: 27),
    title: Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
    trailing: const Icon(Icons.chevron_right, color: AppColors.text),
  );
}
