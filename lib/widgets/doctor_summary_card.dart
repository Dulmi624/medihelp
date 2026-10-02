import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/appointment.dart';

class DoctorSummaryCard extends StatelessWidget {
  const DoctorSummaryCard({required this.appointment, super.key});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    return Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
      const CircleAvatar(radius: 28, backgroundColor: AppColors.lightBlue, child: Icon(Icons.person, color: AppColors.primary, size: 30)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(appointment.doctor.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(appointment.doctor.specialization, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text(appointment.doctor.location, style: const TextStyle(color: AppColors.mutedText, fontSize: 12))])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('${appointment.date.day} Aug ${appointment.date.year}', style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(appointment.time, style: const TextStyle(color: AppColors.mutedText))]),
    ])));
  }
}