import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../services/auth_service.dart';

class ReceptionistHomeScreen extends StatelessWidget {
  const ReceptionistHomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Receptionist Home'), actions: [IconButton(tooltip: 'Log out', onPressed: () async { await AuthService().signOut(); if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false); }, icon: const Icon(Icons.logout))]), body: const Center(child: Text('Receptionist Home')));
}