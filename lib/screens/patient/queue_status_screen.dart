import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../services/dummy_data.dart';
import '../../widgets/action_row.dart';
import '../../widgets/doctor_summary_card.dart';
import '../../widgets/patient_app_bar.dart';
import '../../widgets/patient_bottom_nav.dart';
import '../../widgets/queue_progress_card.dart';

class QueueStatusScreen extends StatelessWidget {
  const QueueStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointment = DummyData.appointment;
    final queue = DummyData.queue;
    return Scaffold(appBar: const PatientAppBar(title: 'Queue Status'), body: ListView(padding: const EdgeInsets.all(20), children: [DoctorSummaryCard(appointment: appointment), Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Your Queue Position', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), const SizedBox(height: 14), Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)), child: Text('${queue.yourPosition}', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.onPrimary, fontSize: 46, fontWeight: FontWeight.w800))), const SizedBox(height: 12), Text('People ahead of you: ${queue.peopleAhead}', style: const TextStyle(color: AppColors.mutedText)), const SizedBox(height: 20), Row(children: [_QueueStat(label: 'Current Serving', value: '${queue.currentServing}'), _QueueStat(label: 'Total in Queue', value: '${queue.totalInQueue}')])]))), const SizedBox(height: 16), QueueProgressCard(queue: queue), const SizedBox(height: 8), ActionRow(icon: Icons.hourglass_bottom, title: 'View Estimated Waiting Time', subtitle: '${queue.estimatedMinutes} mins estimated', onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.queueDetails))]), bottomNavigationBar: const PatientBottomNav(currentIndex: 2));
  }
}

class _QueueStat extends StatelessWidget {
  const _QueueStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(label, style: const TextStyle(color: AppColors.mutedText, fontSize: 12))]));
}
