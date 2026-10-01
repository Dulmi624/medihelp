import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../models/appointment.dart';
import '../../models/doctor.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/step_indicator.dart';

class ConfirmBookingScreen extends StatefulWidget {
  const ConfirmBookingScreen({required this.doctor, required this.date, required this.time, super.key});
  final Doctor doctor;
  final DateTime date;
  final String time;

  @override
  State<ConfirmBookingScreen> createState() => _ConfirmBookingScreenState();
}

class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nicController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() { _nameController.dispose(); _nicController.dispose(); _contactController.dispose(); _emailController.dispose(); super.dispose(); }

  void _confirm() {
    if (!_formKey.currentState!.validate()) return;
    final appointment = Appointment(number: 'OPD${widget.date.year}${widget.date.month.toString().padLeft(2, '0')}${widget.date.day.toString().padLeft(2, '0')}-001', doctor: widget.doctor, date: widget.date, time: widget.time, location: widget.doctor.location, patientName: _nameController.text, nic: _nicController.text, contactNumber: _contactController.text, email: _emailController.text);
    Navigator.pushReplacementNamed(context, AppRoutes.bookingSuccess, arguments: appointment);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Confirm Booking')), body: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(20), children: [
      const StepIndicator(currentStep: 3), const SizedBox(height: 24),
      Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Appointment Details', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), const SizedBox(height: 14), _DetailRow(icon: Icons.person_outline, label: widget.doctor.name), _DetailRow(icon: Icons.calendar_today_outlined, label: '${widget.date.day}/${widget.date.month}/${widget.date.year}  •  ${widget.time}'), _DetailRow(icon: Icons.location_on_outlined, label: widget.doctor.location)]))),
      const SizedBox(height: 24), const Text('Patient Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 12),
      _FormField(controller: _nameController, label: 'Full name', icon: Icons.person_outline), const SizedBox(height: 12), _FormField(controller: _nicController, label: 'NIC number', icon: Icons.badge_outlined), const SizedBox(height: 12), _FormField(controller: _contactController, label: 'Contact number', icon: Icons.phone_outlined), const SizedBox(height: 12), _FormField(controller: _emailController, label: 'Email address (optional)', icon: Icons.email_outlined, requiredField: false),
      const SizedBox(height: 24), Row(children: [Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Edit'))), const SizedBox(width: 12), Expanded(child: PrimaryButton(label: 'Confirm Booking', onPressed: _confirm))]),
    ])));
  }
}

class _DetailRow extends StatelessWidget { const _DetailRow({required this.icon, required this.label}); final IconData icon; final String label; @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [Icon(icon, size: 19, color: AppColors.primary), const SizedBox(width: 10), Expanded(child: Text(label))])); }
class _FormField extends StatelessWidget { const _FormField({required this.controller, required this.label, required this.icon, this.requiredField = true}); final TextEditingController controller; final String label; final IconData icon; final bool requiredField; @override Widget build(BuildContext context) => TextFormField(controller: controller, decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)), validator: requiredField ? (value) => value == null || value.trim().isEmpty ? 'Required' : null : null); }