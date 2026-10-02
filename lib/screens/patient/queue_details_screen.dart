import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../services/dummy_data.dart';
import '../../widgets/action_row.dart';
import '../../widgets/doctor_summary_card.dart';
import '../../widgets/patient_app_bar.dart';
import '../../widgets/patient_bottom_nav.dart';
import '../../widgets/queue_progress_card.dart';

class QueueDetailsScreen extends StatelessWidget {
  const QueueDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointment = DummyData.appointment;
    final queue = DummyData.queue;
    return Scaffold(appBar: const PatientAppBar(title: 'Queue Details'), body: ListView(padding: const EdgeInsets.all(20), children: [DoctorSummaryCard(appointment: appointment), Card(color: AppColors.primary, elevation: 0, child: Padding(padding: const EdgeInsets.all(22), child: Row(children: [const Icon(Icons.hourglass_bottom, color: AppColors.logoBlue, size: 42), const SizedBox(width: 16), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Estimated Waiting Time', style: TextStyle(color: AppColors.onPrimary)), const SizedBox(height: 4), Text('${queue.estimatedMinutes} mins', style: const TextStyle(color: AppColors.onPrimary, fontSize: 28, fontWeight: FontWeight.w800))])]))), const SizedBox(height: 16), Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [_Stat(label: 'Current Serving', value: '${queue.currentServing}'), _Stat(label: 'Your Position', value: '${queue.yourPosition}', detail: '${queue.peopleAhead} ahead of you'), _Stat(label: 'Total in Queue', value: '${queue.totalInQueue}')]))), const SizedBox(height: 16), QueueProgressCard(queue: queue), const SizedBox(height: 8), ActionRow(icon: Icons.notifications_none, title: 'View Queue Updates', subtitle: 'See the latest queue notifications', onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.notifications, arguments: 2))]), bottomNavigationBar: const PatientBottomNav(currentIndex: 2));
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.detail});
  final String label;
  final String value;
  final String? detail;

  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(label, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.mutedText, fontSize: 11)), if (detail != null) Text(detail!, style: const TextStyle(color: AppColors.primary, fontSize: 10))]));
}
