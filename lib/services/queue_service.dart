import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/appointment.dart';
import '../models/queue_entry.dart';

class QueueService {
  QueueService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String newAppointmentNumber() =>
      _firestore.collection('appointments').doc().id;

  Stream<QueueEntry?> watch(String appointmentNumber) {
    return _firestore
        .collection('queues')
        .doc(appointmentNumber)
        .snapshots()
        .map((snapshot) {
          final data = snapshot.data();
          return data == null ? null : QueueEntry.fromMap(data);
        });
  }

  /// Saves an appointment and its queue entry together. Existing active queues
  /// cannot be rescheduled through the patient booking form.
  Future<void> saveBooking(Appointment appointment) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Please sign in before booking.');
    final ref = _firestore.collection('appointments').doc(appointment.number);
    final queueRef = _firestore.collection('queues').doc(appointment.number);
    await _firestore.runTransaction((transaction) async {
      final existing = await transaction.get(ref);
      final queue = await transaction.get(queueRef);
      final old = existing.data();
      final oldQueue = queue.data();
      if (old != null && old['patientId'] != uid) {
        throw StateError('This appointment belongs to another patient.');
      }
      // Do not upgrade legacy shared -001 documents to a new user's booking.
      if (!existing.exists && queue.exists) {
        throw StateError(
          'This is an older booking. Please make a new appointment.',
        );
      }
      if (old != null && old['status'] != 'Scheduled') {
        throw StateError('Only scheduled appointments can be rescheduled.');
      }
      if (oldQueue != null && oldQueue['status'] != 'Waiting') {
        throw StateError(
          'This queue is already being served. Contact reception.',
        );
      }
      final day = DateTime(
        appointment.date.year,
        appointment.date.month,
        appointment.date.day,
      );
      // The current Doctor model has no department field. Preserve its actual
      // specialization as the grouping label until the team adds department IDs.
      final common = <String, dynamic>{
        'appointmentId': appointment.number,
        'patientId': uid,
        'patientName': appointment.patientName.trim(),
        'doctorId': appointment.doctor.id,
        'doctorName': appointment.doctor.name,
        'department': appointment.doctor.specialization,
        'clinic': appointment.location,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      transaction.set(ref, {
        ...common,
        'appointmentNumber': appointment.number,
        'date': Timestamp.fromDate(day),
        'time': appointment.time,
        'nic': appointment.nic.trim(),
        'contactNumber': appointment.contactNumber.trim(),
        'email': appointment.email.trim(),
        'status': 'Scheduled',
        'type': 'Patient Booking',
        'notes': old?['notes'] ?? '',
        'createdAt': old?['createdAt'] ?? FieldValue.serverTimestamp(),
      });
      transaction.set(queueRef, {
        ...common,
        'queueNumber': appointment.number,
        'appointmentTime': appointment.time,
        'status': 'Waiting',
        // Retain legacy patient-screen fields for compatibility. These are
        // initial placeholders, not shared live queue positions or estimates.
        'currentServing': 0,
        'yourPosition': 1,
        'totalInQueue': 1,
        'peopleAhead': 0,
        'estimatedMinutes': 0,
        'positionConfirmed': false,
        'estimateConfirmed': false,
        'notes': oldQueue?['notes'] ?? '',
        'createdAt': oldQueue?['createdAt'] ?? FieldValue.serverTimestamp(),
      });
    });
  }

  /// Existing patient cancel screens call remove. Keep the appointment for
  /// reporting, mark it Cancelled, and delete its queue in one transaction.
  Future<void> remove(String appointmentNumber) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Please sign in again.');
    final ref = _firestore.collection('appointments').doc(appointmentNumber);
    final queueRef = _firestore.collection('queues').doc(appointmentNumber);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      final queue = await transaction.get(queueRef);
      final data = snapshot.data();
      if (data == null) {
        throw StateError('This older booking is not saved. Contact reception.');
      }
      if (data['patientId'] != uid) {
        throw StateError('This appointment belongs to another patient.');
      }
      if (data['status'] == 'Cancelled') return;
      if (data['status'] != 'Scheduled' ||
          (queue.exists && queue.data()?['status'] != 'Waiting')) {
        throw StateError(
          'This appointment cannot be cancelled here. Contact reception.',
        );
      }
      transaction.update(ref, {
        'status': 'Cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.delete(queueRef);
    });
  }
}
