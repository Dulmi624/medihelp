import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../services/dummy_data.dart';
import '../../services/appointment_store.dart';
import '../../services/queue_service.dart';
import '../../widgets/action_row.dart';
import '../../widgets/doctor_summary_card.dart';
import '../../widgets/patient_app_bar.dart';
import '../../widgets/patient_bottom_nav.dart';
import '../../widgets/queue_progress_card.dart';

class QueueDetailsScreen extends StatelessWidget {
  const QueueDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointment = AppointmentStore.current ?? DummyData.appointment;
    return StreamBuilder(
      stream: QueueService().watch(appointment.number),
      builder: (context, snapshot) {
        final queue = snapshot.data ?? DummyData.queue;
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: const PatientAppBar(
            title: 'Queue Details',
            subtitle: 'Detailed view of your queue',
            showBackButton: true,
          ),
          body: Container(
            decoration: const BoxDecoration(gradient: AppGradients.page),
            child: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 92, 20, 24),
                children: [
                  DoctorSummaryCard(appointment: appointment),
                  const SizedBox(height: 16),
                  Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.hourglass_bottom,
                                color: AppColors.primary,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Estimated Waiting Time',
                                    style: TextStyle(
                                      color: AppColors.mutedText,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${queue.estimatedMinutes} mins',
                                    style: const TextStyle(
                                      color: AppColors.primaryDark,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: AppColors.mutedText,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Row(
                        children: [
                          _Stat(
                            icon: Icons.medical_services_outlined,
                            label: 'Current Serving',
                            value: '${queue.currentServing}',
                          ),
                          const _StatDivider(),
                          _Stat(
                            icon: Icons.person_pin_circle_outlined,
                            label: 'Your Position',
                            value: '${queue.yourPosition}',
                            detail: 'in front of you',
                          ),
                          const _StatDivider(),
                          _Stat(
                            icon: Icons.people_outline,
                            label: 'Total in Queue',
                            value: '${queue.totalInQueue}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  QueueProgressCard(queue: queue),
                  const SizedBox(height: 12),
                  ActionRow(
                    icon: Icons.notifications_none,
                    title: 'View Queue Updates',
                    subtitle: 'Get real-time notifications',
                    onTap: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.notifications,
                      arguments: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const PatientBottomNav(currentIndex: 2),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    this.detail,
  });
  final IconData icon;
  final String label;
  final String value;
  final String? detail;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 19),
        const SizedBox(height: 7),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.mutedText, fontSize: 11),
        ),
        if (detail != null)
          Text(
            detail!,
            style: const TextStyle(color: AppColors.primary, fontSize: 10),
          ),
      ],
    ),
  );
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 66, color: AppColors.blueBorder);
}
