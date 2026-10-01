import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../services/dummy_data.dart';
import '../../widgets/patient_bottom_nav.dart';
import '../../widgets/primary_button.dart';

class QueueStatusScreen extends StatelessWidget {
  const QueueStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final queue = DummyData.queue;
    return Scaffold(appBar: AppBar(title: const Text('Queue Status')), body: ListView(padding: const EdgeInsets.all(20), children: [
      Card(elevation: 0, child: ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: Text(DummyData.appointment.doctor.name, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text('${DummyData.appointment.date.day}/${DummyData.appointment.date.month}/${DummyData.appointment.date.year}  •  ${DummyData.appointment.time}'))),
      const SizedBox(height: 18), Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [const Text('Your Queue Position', style: TextStyle(color: AppColors.mutedText)), const SizedBox(height: 8), Text('${queue.yourPosition}', style: const TextStyle(color: AppColors.primary, fontSize: 56, fontWeight: FontWeight.w800)), const Text('People ahead of you', style: TextStyle(color: AppColors.mutedText)), const SizedBox(height: 24), Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [ _Stat(label: 'Current serving', value: '${queue.currentServing}'), _Stat(label: 'Total in queue', value: '${queue.totalInQueue}')])]))),
      const SizedBox(height: 20), const Text('Queue progress', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), const SizedBox(height: 10), LinearProgressIndicator(value: queue.currentServing / queue.totalInQueue, minHeight: 10, borderRadius: BorderRadius.circular(8)), const SizedBox(height: 8), Text('${queue.served} of ${queue.totalInQueue} served  •  ${queue.waiting} waiting', style: const TextStyle(color: AppColors.mutedText)), const SizedBox(height: 28), PrimaryButton(label: 'View Estimated Waiting Time', onPressed: () => Navigator.pushNamed(context, AppRoutes.queueDetails)),
    ]), bottomNavigationBar: const PatientBottomNav(currentIndex: 2));
  }
}

class _Stat extends StatelessWidget { const _Stat({required this.label, required this.value}); final String label; final String value; @override Widget build(BuildContext context) => Column(children: [Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(label, style: const TextStyle(color: AppColors.mutedText, fontSize: 12))]); }