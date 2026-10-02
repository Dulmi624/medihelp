import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/queue_entry.dart';

class QueueProgressCard extends StatelessWidget {
  const QueueProgressCard({required this.queue, super.key});

  final QueueEntry queue;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Queue Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            LinearProgressIndicator(value: queue.served / queue.totalInQueue, minHeight: 10, borderRadius: BorderRadius.circular(8)),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${queue.served} of ${queue.totalInQueue} served'), Text('${queue.waiting} waiting', style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w700))]),
          ],
        ),
      ),
    );
  }
}