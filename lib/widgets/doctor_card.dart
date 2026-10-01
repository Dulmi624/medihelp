import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/doctor.dart';

class DoctorCard extends StatelessWidget {
  const DoctorCard({required this.doctor, required this.selected, required this.onTap, super.key});

  final Doctor doctor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: selected ? AppColors.primary.withAlpha(14) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: selected ? AppColors.primary : AppColors.border, width: selected ? 1.5 : 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(radius: 28, backgroundColor: AppColors.lightBlue, child: Icon(Icons.person, color: AppColors.primary, size: 30)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(doctor.name, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(doctor.specialization, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text('${doctor.experience}  •  ${doctor.location}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.mutedText, fontSize: 12))])),
              Column(children: [const Icon(Icons.star, color: AppColors.warning, size: 18), Text(doctor.rating.toString(), style: const TextStyle(fontWeight: FontWeight.w700))]),
              if (selected) const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.check_circle, color: AppColors.primary)),
            ],
          ),
        ),
      ),
    );
  }
}