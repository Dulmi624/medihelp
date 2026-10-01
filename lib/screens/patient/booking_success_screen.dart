import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../models/appointment.dart';
import '../../widgets/primary_button.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({required this.appointment, super.key});
  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(width: 82, height: 82, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle), child: const Icon(Icons.check, color: Colors.white, size: 52)),
                const SizedBox(height: 22),
                const Text('Appointment Booked Successfully!', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text('Your appointment has been scheduled.', textAlign: TextAlign.center),
                const SizedBox(height: 28),
                Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
                  _SuccessRow(label: 'Appointment No.', value: appointment.number),
                  _SuccessRow(label: 'Doctor', value: appointment.doctor.name),
                  _SuccessRow(label: 'Date & Time', value: '${appointment.date.day}/${appointment.date.month}/${appointment.date.year}  •  ${appointment.time}'),
                  _SuccessRow(label: 'Location', value: appointment.location),
                ]))),
                const SizedBox(height: 18),
                const Text('Please arrive 15 minutes before your appointment.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.mutedText)),
                const SizedBox(height: 28),
                PrimaryButton(label: 'Back to Home', onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.patientHome, (route) => false)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessRow extends StatelessWidget { const _SuccessRow({required this.label, required this.value}); final String label; final String value; @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 14), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Text(label, style: const TextStyle(color: AppColors.mutedText))), Expanded(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w700)))])); }