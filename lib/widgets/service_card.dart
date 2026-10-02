import 'package:flutter/material.dart';

import '../core/theme.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({required this.icon, required this.title, required this.subtitle, required this.onTap, super.key});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(elevation: 0, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: AppColors.primary, size: 30), const Spacer(), Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: AppColors.mutedText, fontSize: 12)), const SizedBox(height: 10), const Align(alignment: Alignment.centerRight, child: Icon(Icons.arrow_forward, color: AppColors.primary, size: 18))]))));
}