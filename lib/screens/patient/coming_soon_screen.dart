import 'package:flutter/material.dart';

import '../../widgets/patient_app_bar.dart';
import '../../widgets/patient_bottom_nav.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(appBar: const PatientAppBar(title: 'MediQueue'), body: const Center(child: Text('Coming soon', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800))), bottomNavigationBar: const PatientBottomNav(currentIndex: 0));
}