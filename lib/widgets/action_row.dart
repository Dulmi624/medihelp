import 'package:flutter/material.dart';

import '../core/theme.dart';

class ActionRow extends StatelessWidget {
  const ActionRow({required this.icon, required this.title, required this.onTap, this.subtitle, super.key});

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(elevation: 0, child: ListTile(onTap: onTap, leading: CircleAvatar(backgroundColor: AppColors.lightBlue, child: Icon(icon, color: AppColors.primary)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: subtitle == null ? null : Text(subtitle!), trailing: const Icon(Icons.chevron_right, color: AppColors.mutedText)));
}