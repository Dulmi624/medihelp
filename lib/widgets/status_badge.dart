import 'package:flutter/material.dart';

import '../core/theme.dart';

enum QueueStatus { waiting, scheduled, confirmed, completed, cancelled }

class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.status, super.key});

  final QueueStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      QueueStatus.waiting => ('Waiting', AppColors.warning),
      QueueStatus.scheduled => ('Scheduled', AppColors.primary),
      QueueStatus.confirmed => ('Confirmed', AppColors.success),
      QueueStatus.completed => ('Completed', AppColors.success),
      QueueStatus.cancelled => ('Cancelled', AppColors.danger),
    };
    return DecoratedBox(
      decoration: BoxDecoration(color: color.withAlpha(24), borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
      ),
    );
  }
}