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

class QueueStatusScreen extends StatelessWidget {
  const QueueStatusScreen({super.key});

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
        title: 'Queue Status',
        subtitle: 'Your place in line, in real time',
        subtitleIcon: Icons.monitor_heart_outlined,
        showBackButton: true,
        onGradient: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.page),
        child: Stack(
          children: [
            Container(
              height: 220,
              decoration: const BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(44),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 128, 20, 24),
                children: [
                  DoctorSummaryCard(appointment: appointment),
                  const SizedBox(height: 16),
                  Card(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 13,
                          ),
                          decoration: const BoxDecoration(
                            gradient: AppGradients.primary,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(22),
                            ),
                          ),
                          child: const Text(
                            'Your Queue Position',
                            style: TextStyle(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppGradients.primary,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: AppColors.cardShadow,
                                      blurRadius: 16,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${queue.yourPosition}',
                                      style: const TextStyle(
                                        color: AppColors.onPrimary,
                                        fontSize: 48,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.people_alt_outlined,
                                      color: AppColors.onPrimary,
                                      size: 22,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'People ahead of you: ${queue.peopleAhead}',
                                style: const TextStyle(
                                  color: AppColors.mutedText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  _QueueStat(
                                    label: 'Current Serving',
                                    value: '${queue.currentServing}',
                                  ),
                                  const _StatDivider(),
                                  _QueueStat(
                                    label: 'Total in Queue',
                                    value: '${queue.totalInQueue}',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  QueueProgressCard(queue: queue),
                  const SizedBox(height: 12),
                  ActionRow(
                    icon: Icons.access_time,
                    title: 'View Estimated Waiting Time',
                    subtitle: '${queue.estimatedMinutes} mins estimated',
                    onTap: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.queueDetails,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
          bottomNavigationBar: const PatientBottomNav(currentIndex: 2),
        );
      },
    );
  }
}

class _QueueStat extends StatelessWidget {
  const _QueueStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
        ),
      ],
    ),
  );
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 42, color: AppColors.blueBorder);
}
