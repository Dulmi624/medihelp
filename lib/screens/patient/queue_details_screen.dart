import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../services/dummy_data.dart';
import '../../widgets/patient_bottom_nav.dart';

class QueueDetailsScreen extends StatelessWidget {
  const QueueDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final queue = DummyData.queue;
    return Scaffold(
      appBar: AppBar(title: const Text('Queue Details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(color: AppColors.primary, elevation: 0, child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [const Icon(Icons.schedule, color: AppColors.logoBlue, size: 38), const SizedBox(height: 12), const Text('Estimated Waiting Time', style: TextStyle(color: Colors.white70)), const SizedBox(height: 4), Text('${queue.estimatedMinutes} mins', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800))]))),
          const SizedBox(height: 20),
          Row(children: [_Metric(label: 'Current serving', value: '${queue.currentServing}'), _Metric(label: 'Your position', value: '${queue.yourPosition}'), _Metric(label: 'Total in queue', value: '${queue.totalInQueue}')]),
          const SizedBox(height: 24),
          const Text('Queue progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: queue.currentServing / queue.totalInQueue, minHeight: 11, borderRadius: BorderRadius.circular(8)),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${queue.served} of ${queue.totalInQueue} served'), Text('${queue.waiting} waiting', style: const TextStyle(color: AppColors.mutedText))]),
          const SizedBox(height: 28),
          OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.notifications_outlined), label: const Text('View Queue Updates')),
        ],
      ),
      bottomNavigationBar: const PatientBottomNav(currentIndex: 2),
    );
  }
}

class _Metric extends StatelessWidget { const _Metric({required this.label, required this.value}); final String label; final String value; @override Widget build(BuildContext context) => Expanded(child: Column(children: [Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(label, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.mutedText, fontSize: 11))])); }