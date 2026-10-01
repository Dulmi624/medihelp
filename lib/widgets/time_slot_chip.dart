import 'package:flutter/material.dart';

import '../core/theme.dart';

class TimeSlotChip extends StatelessWidget {
  const TimeSlotChip({required this.time, required this.selected, required this.unavailable, required this.onTap, super.key});

  final String time;
  final bool selected;
  final bool unavailable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: unavailable ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: selected ? AppColors.primary : unavailable ? AppColors.border.withAlpha(80) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: selected ? AppColors.primary : AppColors.border)),
        child: Text(time, style: TextStyle(color: unavailable ? AppColors.mutedText : selected ? Colors.white : AppColors.text, fontWeight: FontWeight.w700, decoration: unavailable ? TextDecoration.lineThrough : null)),
      ),
    );
  }
}