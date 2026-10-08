import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../models/appointment.dart';
import '../../models/doctor.dart';
import '../../services/appointment_store.dart';
import '../../services/queue_service.dart';
import '../../widgets/action_row.dart';
import '../../widgets/patient_app_bar.dart';
import '../../widgets/patient_bottom_nav.dart';

class MyAppointmentScreen extends StatefulWidget {
  const MyAppointmentScreen({super.key});

  @override
  State<MyAppointmentScreen> createState() => _MyAppointmentScreenState();
}

class _MyAppointmentScreenState extends State<MyAppointmentScreen> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  bool _cancelBusy = false;
  String? _cancellingNumber;

  String _text(Map<String, dynamic> data, String key) {
    final value = data[key];
    return value is String ? value : '';
  }

  Appointment _toAppointment(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final storedDate = data['date'];

    if (storedDate is! Timestamp) {
      throw const FormatException('This appointment has an invalid date.');
    }

    final date = storedDate.toDate();
    final location = _text(data, 'clinic');
    final status = _text(data, 'status').toLowerCase();

    return Appointment(
      number: _text(data, 'appointmentNumber').isEmpty
          ? document.id
          : _text(data, 'appointmentNumber'),
      doctor: Doctor(
        id: _text(data, 'doctorId'),
        name: _text(data, 'doctorName'),
        specialization: _text(data, 'department'),
        location: location,
        experience: '',
        rating: 0,
      ),
      date: date,
      dateLabel: '${date.day}/${date.month}/${date.year}',
      time: _text(data, 'time'),
      location: location,
      patientName: _text(data, 'patientName'),
      nic: _text(data, 'nic'),
      contactNumber: _text(data, 'contactNumber'),
      email: _text(data, 'email'),
      isCancelled: status == 'cancelled' || status == 'canceled',
    );
  }

  void _edit(Appointment appointment) {
    if (_cancelBusy) return;

    Navigator.pushNamed(
      context,
      AppRoutes.confirmBooking,
      arguments: {
        'doctor': appointment.doctor,
        'date': appointment.date,
        'time': appointment.time,
        'existingAppointment': appointment,
      },
    );
  }

  void _reschedule(Appointment appointment) {
    if (_cancelBusy) return;

    Navigator.pushNamed(
      context,
      AppRoutes.selectDateTime,
      arguments: {
        'doctor': appointment.doctor,
        'existingAppointment': appointment,
      },
    );
  }

  void _viewQueue(Appointment appointment) {
    if (_cancelBusy) return;

    AppointmentStore.current = appointment;

    Navigator.pushReplacementNamed(context, AppRoutes.queueStatus);
  }

  Future<void> _cancelAppointment(Appointment appointment) async {
    if (_cancelBusy) return;

    setState(() => _cancelBusy = true);

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Cancel appointment?'),
          content: const Text(
            'Are you sure you want to cancel this appointment?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Keep appointment'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Cancel appointment'),
            ),
          ],
        ),
      );

      if (!mounted || confirmed != true) return;

      setState(() => _cancellingNumber = appointment.number);

      await QueueService().remove(appointment.number);

      if (AppointmentStore.current?.number == appointment.number) {
        AppointmentStore.cancel();
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment cancelled successfully.')),
      );
    } on StateError catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message.toString())));
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not cancel. Check your connection and try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _cancelBusy = false;
          _cancellingNumber = null;
        });
      }
    }
  }

  Widget _message(String message, {bool loading = false}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (loading) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
            ],
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _appointmentCard(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final Appointment appointment;

    try {
      appointment = _toAppointment(document);
    } on FormatException {
      return _message(
        'Appointment ${document.id} has an invalid date. '
        'Please contact reception.',
      );
    }

    final status = _text(data, 'status');
    final normalizedStatus = status.toLowerCase();

    final canEdit =
        status == 'Scheduled' &&
        data['type'] == 'Patient Booking' &&
        document.id == appointment.number;

    final canViewQueue = [
      'scheduled',
      'upcoming',
      'checked_in',
      'checked-in',
      'checked in',
    ].contains(normalizedStatus);

    final cancelling = _cancellingNumber == appointment.number;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppGradients.doctorBanner,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.surface,
                    child: Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.doctor.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appointment.doctor.specialization,
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _Detail(
              icon: Icons.confirmation_number_outlined,
              text: appointment.number,
            ),
            _Detail(icon: Icons.person_outline, text: appointment.patientName),
            _Detail(
              icon: Icons.calendar_today_outlined,
              text: appointment.dateLabel,
            ),
            _Detail(icon: Icons.access_time, text: appointment.time),
            _Detail(
              icon: Icons.location_on_outlined,
              text: appointment.location,
            ),
            _Detail(
              icon: appointment.isCancelled
                  ? Icons.cancel_outlined
                  : Icons.event_available_outlined,
              text: 'Status: ${status.isEmpty ? 'Unknown' : status}',
            ),
            if (canEdit) ...[
              const SizedBox(height: 8),
              ActionRow(
                icon: Icons.edit_outlined,
                title: 'Edit Patient Details',
                subtitle: 'Update name and contact details',
                onTap: () => _edit(appointment),
              ),
              const SizedBox(height: 12),
              ActionRow(
                icon: Icons.calendar_month_outlined,
                title: 'Reschedule Appointment',
                subtitle: 'Choose another date and time',
                onTap: () => _reschedule(appointment),
              ),
              const SizedBox(height: 12),
              ActionRow(
                icon: Icons.cancel_outlined,
                title: cancelling ? 'Cancelling...' : 'Cancel Appointment',
                subtitle: 'Cancel this booking',
                onTap: () => _cancelAppointment(appointment),
              ),
            ],
            if (canViewQueue) ...[
              const SizedBox(height: 12),
              ActionRow(
                icon: Icons.people_outline,
                title: 'View Queue Status',
                subtitle: 'Check the queue for this appointment',
                onTap: () => _viewQueue(appointment),
              ),
            ],
          ],
        ),
      ),
    );
  }

  int _createdAt(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final value = document.data()['createdAt'];
    return value is Timestamp ? value.millisecondsSinceEpoch : 0;
  }

  Widget _bookingList(User user) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _db
          .collection('appointments')
          .where('patientId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _message(
            'Could not load your appointments. '
            'Please check your connection and permissions.',
          );
        }

        if (!snapshot.hasData) {
          return _message('Loading your appointments...', loading: true);
        }

        final documents = snapshot.data!.docs.toList()
          ..sort((a, b) {
            final result = _createdAt(b).compareTo(_createdAt(a));
            return result == 0 ? a.id.compareTo(b.id) : result;
          });

        if (documents.isEmpty) {
          return _message('You have no saved appointments yet.');
        }

        return Column(
          children: [
            for (final document in documents) ...[
              _appointmentCard(document),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: const PatientAppBar(
        title: 'My Appointments',
        subtitle: 'Your health, our priority',
        subtitleIcon: Icons.favorite,
        onGradient: false,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.page),
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              StreamBuilder<User?>(
                stream: _auth.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _message('Loading...', loading: true);
                  }

                  final user = snapshot.data;

                  if (user == null) {
                    return _message(
                      'Please sign in to view your appointments.',
                    );
                  }

                  return _bookingList(user);
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const PatientBottomNav(currentIndex: 1),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
