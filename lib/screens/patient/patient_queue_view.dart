import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../models/appointment.dart';
import '../../models/queue_entry.dart';
import '../../services/appointment_store.dart';
import '../../services/queue_service.dart';
import '../../widgets/action_row.dart';
import '../../widgets/doctor_summary_card.dart';
import '../../widgets/patient_app_bar.dart';
import '../../widgets/patient_bottom_nav.dart';
import '../../widgets/queue_progress_card.dart';

class PatientQueueView extends StatefulWidget {
  const PatientQueueView({required this.details, super.key});
  final bool details;
  @override
  State<PatientQueueView> createState() => _PatientQueueViewState();
}

class _PatientQueueViewState extends State<PatientQueueView> {
  late final Stream<Appointment?> _appointments =
      AppointmentStore.watchCurrent();
  @override
  Widget build(BuildContext context) => StreamBuilder<Appointment?>(
    stream: _appointments,
    builder: (context, snapshot) {
      final appointment = snapshot.data;
      Widget body;
      if (snapshot.hasError) {
        body = const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Could not load your appointment. Check your connection and account permissions.',
            ),
          ),
        );
      } else if (snapshot.connectionState == ConnectionState.waiting) {
        body = const Center(child: CircularProgressIndicator());
      } else if (appointment == null) {
        body = const Center(
          child: Text('No saved appointment. Book an appointment first.'),
        );
      } else if (appointment.isCancelled) {
        body = const Center(
          child: Text('Your appointment has been cancelled.'),
        );
      } else {
        body = _LiveQueue(
          key: ValueKey(appointment.number),
          appointment: appointment,
          details: widget.details,
        );
      }
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PatientAppBar(
          title: widget.details ? 'Queue Details' : 'Queue Status',
          subtitle: 'Your doctor’s queue for your appointment date',
          showBackButton: true,
        ),
        body: Container(
          decoration: const BoxDecoration(gradient: AppGradients.page),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 92),
              child: body,
            ),
          ),
        ),
        bottomNavigationBar: const PatientBottomNav(currentIndex: 2),
      );
    },
  );
}

class _LiveQueue extends StatefulWidget {
  const _LiveQueue({
    required this.appointment,
    required this.details,
    super.key,
  });
  final Appointment appointment;
  final bool details;
  @override
  State<_LiveQueue> createState() => _LiveQueueState();
}

class _LiveQueueState extends State<_LiveQueue> {
  late final Stream<QueueEntry?> _stream = QueueService().watch(
    widget.appointment.number,
  );
  String _statusMessage(String status) => switch (status) {
    'Called' =>
      'You have been called. Please go to reception/the consultation room.',
    'In Consultation' => 'Your consultation is in progress.',
    'Completed' => 'Your consultation is complete.',
    _ => 'You are waiting in the queue.',
  };

  @override
  Widget build(BuildContext context) => StreamBuilder<QueueEntry?>(
    stream: _stream,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Could not load the live queue. Check your connection and permissions.',
            ),
          ),
        );
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      final queue = snapshot.data;
      if (queue == null) {
        return const Center(
          child: Text('No active queue entry for this appointment.'),
        );
      }
      final now = DateTime.now();
      final date = widget.appointment.date;
      final today =
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
      final updated = queue.metricsUpdatedAt;
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          DoctorSummaryCard(appointment: widget.appointment),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _statusMessage(queue.status),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (queue.active && queue.positionConfirmed) ...[
                    Text(
                      'Your current position: ${queue.yourPosition}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('People ahead of you: ${queue.peopleAhead}'),
                    Text('Being served/called: ${queue.currentServing}'),
                    Text(
                      'Active patients in this queue: ${queue.totalInQueue}',
                    ),
                  ] else if (queue.active)
                    const Text(
                      'Position is being calculated. An online Admin session is needed to update the queue.',
                    ),
                  if (!today)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'This is not today’s appointment. Figures describe its appointment-date queue.',
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (queue.status == 'Waiting') ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estimated waiting time',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      queue.estimateConfirmed
                          ? 'About ${queue.estimatedMinutes} minutes'
                          : 'Not calculated yet',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      queue.estimateConfirmed
                          ? 'Based on ${queue.minutesPerConsultation} minutes per person ahead. This is a queue estimate, not a guaranteed start time; appointment-time delays are not included.'
                          : 'Waiting-time estimates update when an Admin is online.',
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (queue.positionConfirmed) ...[
            const SizedBox(height: 16),
            QueueProgressCard(queue: queue),
          ],
          if (updated != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Last calculated: ${updated.day}/${updated.month}/${updated.year} ${updated.hour.toString().padLeft(2, '0')}:${updated.minute.toString().padLeft(2, '0')}. Updates require an online Admin session.',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.mutedText,
                ),
              ),
            ),
          if (queue.fromCache)
            const Text(
              'Showing cached data. Connect to the internet for updates.',
              style: TextStyle(color: AppColors.warning),
            ),
          const SizedBox(height: 12),
          ActionRow(
            icon: Icons.access_time,
            title: widget.details
                ? 'Back to Queue Status'
                : 'View Queue Details',
            subtitle: 'Doctor and appointment-date queue',
            onTap: () => Navigator.pushReplacementNamed(
              context,
              widget.details ? AppRoutes.queueStatus : AppRoutes.queueDetails,
            ),
          ),
        ],
      );
    },
  );
}
