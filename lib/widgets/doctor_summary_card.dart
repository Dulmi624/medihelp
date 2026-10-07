import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/appointment.dart';

class DoctorSummaryCard extends StatelessWidget {
  const DoctorSummaryCard({required this.appointment, super.key});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 27,
              backgroundColor: AppColors.avatarTint,
              child: Icon(Icons.person, color: AppColors.primaryDark, size: 30),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.doctor.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appointment.doctor.specialization,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appointment.doctor.location,
                    style: const TextStyle(
                      color: AppColors.mutedText,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    appointment.dateLabel,
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  appointment.time,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
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
