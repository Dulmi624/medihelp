import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../services/dummy_data.dart';
import '../../widgets/patient_bottom_nav.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_badge.dart';

class MyAppointmentScreen extends StatelessWidget {
  const MyAppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointment = DummyData.appointment;
    return Scaffold(appBar: AppBar(title: const Text('My Appointment')), body: ListView(padding: const EdgeInsets.all(20), children: [
      Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 32)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(appointment.doctor.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), Text(appointment.doctor.specialization, style: const TextStyle(color: AppColors.primary))])), const StatusBadge(status: QueueStatus.completed)]), const Divider(height: 28), _Info(icon: Icons.calendar_today_outlined, text: '${appointment.date.day}/${appointment.date.month}/${appointment.date.year}'), _Info(icon: Icons.access_time, text: appointment.time), _Info(icon: Icons.location_on_outlined, text: appointment.location)]))),
      const SizedBox(height: 20), PrimaryButton(label: 'View Queue Status', onPressed: () => Navigator.pushNamed(context, AppRoutes.queueStatus)), const SizedBox(height: 12), OutlinedButton(onPressed: () => showDialog<void>(context: context, builder: (context) => AlertDialog(title: const Text('Cancel appointment?'), content: const Text('Are you sure you want to reschedule or cancel this appointment?'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Keep')), FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Confirm'))])), child: const Text('Reschedule / Cancel')),
    ]), bottomNavigationBar: const PatientBottomNav(currentIndex: 1));
  }
}

class _Info extends StatelessWidget { const _Info({required this.icon, required this.text}); final IconData icon; final String text; @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [Icon(icon, size: 18, color: AppColors.primary), const SizedBox(width: 10), Text(text)])); }