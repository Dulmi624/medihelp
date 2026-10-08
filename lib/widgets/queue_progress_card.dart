import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/queue_entry.dart';

class QueueProgressCard extends StatelessWidget {
  const QueueProgressCard({required this.queue, super.key});
  final QueueEntry queue;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Queue Progress',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: queue.progress,
            color: AppColors.primary,
            backgroundColor: AppColors.primarySoft,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            children: [
              Text(
                '${queue.served} of ${queue.totalToday} consultations completed',
              ),
              Text(
                '${queue.waiting} waiting',
                style: const TextStyle(color: AppColors.warning),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
