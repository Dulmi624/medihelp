import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../models/appointment.dart';
import '../../services/appointment_store.dart';
import '../../services/queue_service.dart';
import '../../models/doctor.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/step_indicator.dart';

class ConfirmBookingScreen extends StatefulWidget {
  const ConfirmBookingScreen({
    required this.doctor,
    required this.date,
    required this.time,
    this.existingAppointment,
    super.key,
  });
  final Doctor doctor;
  final DateTime date;
  final String time;
  final Appointment? existingAppointment;

  @override
  State<ConfirmBookingScreen> createState() => _ConfirmBookingScreenState();
}

class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nicController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _queueService = QueueService();
  bool _saving = false;
  String? _newNumber;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingAppointment;
    if (existing != null) {
      _nameController.text = existing.patientName;
      _nicController.text = existing.nic;
      _contactController.text = existing.contactNumber;
      _emailController.text = existing.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final oldAppointment = widget.existingAppointment;
    final appointment = Appointment(
      number:
          oldAppointment?.number ??
          (_newNumber ??= _queueService.newAppointmentNumber()),
      doctor: widget.doctor,
      date: widget.date,
      dateLabel: '${widget.date.day}/${widget.date.month}/${widget.date.year}',
      time: widget.time,
      location: widget.doctor.location,
      patientName: _nameController.text,
      nic: _nicController.text,
      contactNumber: _contactController.text,
      email: _emailController.text,
    );
    try {
      await _queueService.saveBooking(appointment);
      AppointmentStore.current = appointment;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is StateError ? error.message.toString() : 'Could not save the appointment. Check your connection and permissions, then try again.',
            ),
          ),
        );
      }
      return;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.bookingSuccess,
      arguments: appointment,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Booking')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const StepIndicator(currentStep: 3),
            const SizedBox(height: 24),
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Appointment Details',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _DetailRow(
                      icon: Icons.person_outline,
                      label: widget.doctor.name,
                    ),
                    _DetailRow(
                      icon: Icons.calendar_today_outlined,
                      label:
                          '${widget.date.day}/${widget.date.month}/${widget.date.year}  •  ${widget.time}',
                    ),
                    _DetailRow(
                      icon: Icons.location_on_outlined,
                      label: widget.doctor.location,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Patient Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            _FormField(
              controller: _nameController,
              label: 'Full name',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 12),
            _FormField(
              controller: _nicController,
              label: 'NIC number',
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: 12),
            _FormField(
              controller: _contactController,
              label: 'Contact number',
              icon: Icons.phone_outlined,
            ),
            const SizedBox(height: 12),
            _FormField(
              controller: _emailController,
              label: 'Email address (optional)',
              icon: Icons.email_outlined,
              requiredField: false,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: _saving ? 'Saving...' : 'Confirm Booking',
                    onPressed: _saving ? null : _confirm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Icon(icon, size: 19, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(label)),
      ],
    ),
  );
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.requiredField = true,
  });
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool requiredField;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    validator: requiredField
        ? (value) => value == null || value.trim().isEmpty ? 'Required' : null
        : null,
  );
}
