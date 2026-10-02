import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../services/dummy_data.dart';
import '../../widgets/action_row.dart';
import '../../widgets/doctor_summary_card.dart';
import '../../widgets/patient_app_bar.dart';
import '../../widgets/patient_bottom_nav.dart';
import '../../widgets/status_badge.dart';

class MyAppointmentScreen extends StatelessWidget {
  const MyAppointmentScreen({super.key});

  void _showActions(BuildContext context) {
    showModalBottomSheet<void>(context: context, builder: (context) => SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [ListTile(leading: const Icon(Icons.edit_calendar_outlined, color: AppColors.primary), title: const Text('Reschedule'), onTap: () => Navigator.pop(context)), ListTile(leading: const Icon(Icons.cancel_outlined, color: AppColors.danger), title: const Text('Cancel Appointment'), onTap: () { Navigator.pop(context); _confirmCancel(context); })]))));
  }

  void _confirmCancel(BuildContext context) {
    showDialog<void>(context: context, builder: (context) => AlertDialog(title: const Text('Cancel appointment?'), content: const Text('Are you sure you want to cancel this appointment?'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Keep appointment')), FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel appointment'))]));
  }

  @override
  Widget build(BuildContext context) {
    final appointment = DummyData.appointment;
    return Scaffold(appBar: const PatientAppBar(title: 'My Appointment'), body: ListView(padding: const EdgeInsets.all(20), children: [DoctorSummaryCard(appointment: appointment), Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [_Detail(icon: Icons.medical_services_outlined, text: appointment.doctor.location), _Detail(icon: Icons.calendar_today_outlined, text: appointment.dateLabel), _Detail(icon: Icons.access_time, text: appointment.time), _Detail(icon: Icons.location_on_outlined, text: appointment.location), const Align(alignment: Alignment.centerRight, child: StatusBadge(status: QueueStatus.confirmed))]))), const SizedBox(height: 18), ActionRow(icon: Icons.people_outline, title: 'View Queue Status', subtitle: 'Track your position in the queue', onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.queueStatus)), ActionRow(icon: Icons.edit_calendar_outlined, title: 'Reschedule / Cancel', subtitle: 'Manage this appointment', onTap: () => _showActions(context))]), bottomNavigationBar: const PatientBottomNav(currentIndex: 1));
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [Icon(icon, color: AppColors.primary, size: 19), const SizedBox(width: 10), Text(text)]));
}
