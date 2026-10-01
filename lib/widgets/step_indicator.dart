import 'package:flutter/material.dart';

import '../core/theme.dart';

class StepIndicator extends StatelessWidget {
  const StepIndicator({required this.currentStep, super.key});

  final int currentStep;
  static const labels = ['Select OPD', 'Select Doctor', 'Choose Date & Time', 'Confirm'];

  @override
  Widget build(BuildContext context) {
    return Row(children: List.generate(labels.length, (index) {
      final active = index <= currentStep;
      return Expanded(child: Column(children: [Row(children: [if (index > 0) Expanded(child: Container(height: 2, color: index <= currentStep ? AppColors.primary : AppColors.border)), Container(width: 28, height: 28, alignment: Alignment.center, decoration: BoxDecoration(color: active ? AppColors.primary : Colors.white, shape: BoxShape.circle, border: Border.all(color: active ? AppColors.primary : AppColors.border)), child: Text('${index + 1}', style: TextStyle(color: active ? Colors.white : AppColors.mutedText, fontSize: 12, fontWeight: FontWeight.w700))), if (index < labels.length - 1) Expanded(child: Container(height: 2, color: index < currentStep ? AppColors.primary : AppColors.border))]), const SizedBox(height: 6), Text(labels[index], textAlign: TextAlign.center, style: TextStyle(color: active ? AppColors.primary : AppColors.mutedText, fontSize: 10, fontWeight: active ? FontWeight.w700 : FontWeight.w400))]));
    }));
  }
}