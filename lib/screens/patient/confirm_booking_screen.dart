import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../models/appointment.dart';
import '../../models/doctor.dart';
import '../../services/appointment_store.dart';
import '../../services/booking_service.dart';
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

  bool _isSaving = false;

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

  String? _validateName(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) return 'Enter your full name.';
    if (text.length < 2) return 'Enter at least 2 characters.';
    if (text.length > 200) return 'Use no more than 200 characters.';

    return null;
  }

  String? _validateNic(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) return 'Enter your NIC number.';

    final valid = RegExp(r'^(?:[0-9]{12}|[0-9]{9}[VvXx])$').hasMatch(text);

    if (!valid) {
      return 'Use 12 digits or 9 digits followed by V/X.';
    }

    return null;
  }

  String _normalizePhone(String value) {
    return value.trim().replaceAll(RegExp(r'[\s()-]'), '');
  }

  String? _validatePhone(String? value) {
    final text = _normalizePhone(value ?? '');

    if (text.isEmpty) return 'Enter your contact number.';

    final valid = RegExp(r'^(?:0[1-9][0-9]{8}|\+94[1-9][0-9]{8})$')
        .hasMatch(text);

    if (!valid) {
      return 'Use 10 digits starting with 0, or +94 format.';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';

    // Email is optional.
    if (text.isEmpty) return null;

    if (text.length > 254 ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  DateTime? _bookingDateTime() {
    final match = RegExp(r'^(0[1-9]|1[0-2]):([0-5][0-9]) (AM|PM)$')
        .firstMatch(widget.time);

    if (match == null) return null;

    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);

    if (hour == 12) hour = 0;
    if (match.group(3) == 'PM') hour += 12;

    return DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      hour,
      minute,
    );
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _logError(Object error, StackTrace stackTrace) {
    debugPrint('Booking error (${error.runtimeType}): $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  Future<void> _confirm() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    final oldAppointment = widget.existingAppointment;

    // This check applies to new bookings.
    if (oldAppointment == null) {
      final bookingTime = _bookingDateTime();

      if (bookingTime == null) {
        _showError('Invalid time. Please select another slot.');
        return;
      }

      if (!bookingTime.isAfter(DateTime.now())) {
        _showError(
          'This appointment time has passed. '
          'Go back and select a future slot.',
        );
        return;
      }
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    try {
      final service = BookingService();
      final Appointment saved;

      final patientName = _nameController.text.trim();
      final nic = _nicController.text.trim().toUpperCase();
      final contact = _normalizePhone(_contactController.text);
      final email = _emailController.text.trim();

      if (oldAppointment == null) {
        final draft = Appointment(
          number: '',
          doctor: widget.doctor,
          date: widget.date,
          dateLabel:
              '${widget.date.day}/${widget.date.month}/${widget.date.year}',
          time: widget.time,
          location: widget.doctor.location,
          patientName: patientName,
          nic: nic,
          contactNumber: contact,
          email: email,
        );

        saved = await service.createBooking(
          draft: draft,
          department: widget.doctor.specialization,
        );
      } else {
        saved = oldAppointment.copyWith(
          patientName: patientName,
          nic: nic,
          contactNumber: contact,
          email: email,
        );

        await service.updatePatientDetails(saved);
      }

      AppointmentStore.current = saved;

      if (!mounted) return;

      if (oldAppointment != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient details updated successfully.'),
          ),
        );

        Navigator.pop(context, saved);
      } else {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.bookingSuccess,
          arguments: saved,
        );
      }
    } on FirebaseException catch (error, stackTrace) {
      _logError(error, stackTrace);
      _showError('Could not save booking. Please try again.');
    } on StateError catch (error, stackTrace) {
      _logError(error, stackTrace);
      _showError(error.message);
    } catch (error, stackTrace) {
      _logError(error, stackTrace);
      _showError('Could not save booking. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final existing = widget.existingAppointment;
    final doctor = existing?.doctor ?? widget.doctor;
    final date = existing?.date ?? widget.date;
    final time = existing?.time ?? widget.time;
    final location = existing?.location ?? widget.doctor.location;
    final editing = existing != null;

    return PopScope(
      canPop: !_isSaving,
      child: Scaffold(
        appBar: AppBar(
          title: Text(editing ? 'Edit Patient Details' : 'Confirm Booking'),
          automaticallyImplyLeading: !_isSaving,
        ),
        body: AbsorbPointer(
          absorbing: _isSaving,
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (!editing) ...[
                  const StepIndicator(currentStep: 3),
                  const SizedBox(height: 24),
                ],
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
                          label: doctor.name,
                        ),
                        _DetailRow(
                          icon: Icons.calendar_today_outlined,
                          label:
                              '${date.day}/${date.month}/${date.year}'
                              ' | $time',
                        ),
                        _DetailRow(
                          icon: Icons.location_on_outlined,
                          label: location,
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
                  validator: _validateName,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                _FormField(
                  controller: _nicController,
                  label: 'NIC number',
                  icon: Icons.badge_outlined,
                  validator: _validateNic,
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 12),
                _FormField(
                  controller: _contactController,
                  label: 'Contact number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                ),
                const SizedBox(height: 12),
                _FormField(
                  controller: _emailController,
                  label: 'Email address (optional)',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(editing ? 'Back' : 'Edit'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        label: _isSaving
                            ? 'Saving...'
                            : editing
                            ? 'Save Changes'
                            : 'Confirm Booking',
                        onPressed: _confirm,
                      ),
                    ),
                  ],
                ),
                if (_isSaving) ...[
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          ),
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
  Widget build(BuildContext context) {
    return Padding(
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
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: validator,
    );
  }
}
