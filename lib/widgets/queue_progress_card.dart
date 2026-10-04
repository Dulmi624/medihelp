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
            const Text(
              'Queue Progress',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  Container(height: 11, color: AppColors.primarySoft),
                  FractionallySizedBox(
                    widthFactor: queue.served / queue.totalInQueue,
                    child: Container(
                      height: 11,
                      decoration: const BoxDecoration(
                        gradient: AppGradients.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${queue.served} of ${queue.totalInQueue} served'),
                Text(
                  '${queue.waiting} waiting',
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
