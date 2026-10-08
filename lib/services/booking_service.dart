import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/appointment.dart';

class BookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Appointment> createBooking({
    required Appointment draft,
    required String department,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Please sign in before booking.');
    }

    if (draft.doctor.id.trim().isEmpty) {
      throw StateError('Please select a doctor.');
    }

    final userRef = _db.collection('users').doc(user.uid);

    final selectedDate = DateTime(
      draft.date.year,
      draft.date.month,
      draft.date.day,
    );
    final selectedTime = draft.time.trim().toUpperCase();

    // Include older bookings that were saved with random IDs.
    // Read from the server so cached data cannot hide a booking.
    final previousBookings = await _db
        .collection('appointments')
        .where('patientId', isEqualTo: user.uid)
        .get(const GetOptions(source: Source.server));

    final sameSlotBookings = previousBookings.docs.where((document) {
      final data = document.data();
      final storedDate = data['date'];
      final storedTime = data['time'];

      if (storedDate is! Timestamp || storedTime is! String) {
        return false;
      }

      final date = storedDate.toDate();

      return data['doctorId'] == draft.doctor.id &&
          date.year == selectedDate.year &&
          date.month == selectedDate.month &&
          date.day == selectedDate.day &&
          storedTime.trim().toUpperCase() == selectedTime;
    }).toList();

    final hasExistingBooking = sameSlotBookings.any((document) {
      final value = document.data()['status'];
      final status = value is String ? value.trim().toLowerCase() : '';

      return status != 'cancelled' && status != 'canceled';
    });

    if (hasExistingBooking) {
      throw StateError(
        'You already have a booking with this doctor at this date and time. '
        'Please check My Appointments.',
      );
    }

    // The same patient and slot produce the same document ID.
    // Cancelled bookings remain in history.
    final slotKey = base64Url
        .encode(
          utf8.encode(
            jsonEncode([
              user.uid,
              draft.doctor.id,
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime,
            ]),
          ),
        )
        .replaceAll('=', '');

    final appointmentNumber = 'OPD-$slotKey-${sameSlotBookings.length}';

    if (utf8.encode(appointmentNumber).length > 1500) {
      throw StateError(
        'Booking details are too long. Please contact reception.',
      );
    }

    final appointmentRef = _db
        .collection('appointments')
        .doc(appointmentNumber);
    final queueRef = _db.collection('queues').doc(appointmentNumber);

    final appointment = Appointment(
      number: appointmentNumber,
      doctor: draft.doctor,
      date: selectedDate,
      dateLabel: draft.dateLabel,
      time: selectedTime,
      location: draft.location,
      patientName: draft.patientName.trim(),
      nic: draft.nic.trim(),
      contactNumber: draft.contactNumber.trim(),
      email: draft.email.trim(),
    );

    await _db.runTransaction((transaction) async {
      // Complete all reads before writing.
      final userSnapshot = await transaction.get(userRef);
      final existingBooking = await transaction.get(appointmentRef);
      final existingQueue = await transaction.get(queueRef);

      if (userSnapshot.data()?['role'] != 'patient') {
        throw StateError('A patient account is required.');
      }

      // Concurrent submissions from the same account use the same ID.
      if (existingBooking.exists) {
        throw StateError(
          'This booking has already been submitted. '
          'Please check My Appointments.',
        );
      }

      if (existingQueue.exists) {
        throw StateError(
          'A queue record already exists for this booking. '
          'Please contact reception.',
        );
      }

      transaction.set(appointmentRef, {
        'appointmentId': appointmentNumber,
        'appointmentNumber': appointmentNumber,
        'patientId': user.uid,
        'patientName': appointment.patientName,
        'doctorId': appointment.doctor.id,
        'doctorName': appointment.doctor.name,
        'department': department.trim(),
        'clinic': appointment.location,
        'date': Timestamp.fromDate(appointment.date),
        'time': appointment.time,
        'nic': appointment.nic,
        'contactNumber': appointment.contactNumber,
        'email': appointment.email,
        'status': 'Scheduled',
        'type': 'Patient Booking',
        'notes': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.set(queueRef, {
        'appointmentId': appointmentNumber,
        'patientId': user.uid,
        'patientName': appointment.patientName,
        'doctorId': appointment.doctor.id,
        'doctorName': appointment.doctor.name,
        'department': department.trim(),
        'clinic': appointment.location,
        'queueNumber': appointmentNumber,
        'appointmentTime': appointment.time,
        'status': 'Waiting',
        'currentServing': 0,
        'yourPosition': 1,
        'totalInQueue': 1,
        'peopleAhead': 0,
        'estimatedMinutes': 0,
        'positionConfirmed': false,
        'estimateConfirmed': false,
        'notes': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    return appointment;
  }

  Future<void> updatePatientDetails(Appointment appointment) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Please sign in before editing.');
    }

    final userRef = _db.collection('users').doc(user.uid);
    final appointmentRef = _db
        .collection('appointments')
        .doc(appointment.number);
    final queueRef = _db.collection('queues').doc(appointment.number);

    await _db.runTransaction((transaction) async {
      // Complete all reads before writing.
      final userSnapshot = await transaction.get(userRef);
      final appointmentSnapshot = await transaction.get(appointmentRef);
      final queueSnapshot = await transaction.get(queueRef);

      final saved = appointmentSnapshot.data();
      final queue = queueSnapshot.data();

      if (userSnapshot.data()?['role'] != 'patient') {
        throw StateError('A patient account is required.');
      }

      if (saved == null || saved['patientId'] != user.uid) {
        throw StateError('This appointment was not found in your account.');
      }

      if (saved['status'] != 'Scheduled' ||
          saved['type'] != 'Patient Booking') {
        throw StateError('Only scheduled patient bookings can be edited here.');
      }

      if (queue == null || queue['patientId'] != user.uid) {
        throw StateError('The booking queue record was not found.');
      }

      final canEditQueue =
          queue['status'] == 'Waiting' &&
          queue['currentServing'] == 0 &&
          queue['yourPosition'] == 1 &&
          queue['totalInQueue'] == 1 &&
          queue['peopleAhead'] == 0 &&
          queue['estimatedMinutes'] == 0 &&
          queue['positionConfirmed'] == false &&
          queue['estimateConfirmed'] == false;

      if (!canEditQueue) {
        throw StateError(
          'Your live queue has already been updated. '
          'Please contact reception to edit this booking.',
        );
      }

      final patientName = appointment.patientName.trim();

      transaction.update(appointmentRef, {
        'patientName': patientName,
        'nic': appointment.nic.trim(),
        'contactNumber': appointment.contactNumber.trim(),
        'email': appointment.email.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.update(queueRef, {
        'patientName': patientName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
