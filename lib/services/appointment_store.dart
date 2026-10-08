import '../models/appointment.dart';
import '../models/doctor.dart';
import 'data_compatibility.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract final class AppointmentStore {
  static Appointment? current;

  static void cancel() {
    current = current?.copyWith(isCancelled: true);
  }

  static Stream<Appointment?> watchCurrent() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      current = null;
      return Stream.value(null);
    }
    return FirebaseFirestore.instance
        .collection('appointments')
        .where('patientId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs
              .where(
                (doc) => DataCompatibility.date(doc.data()['date']) != null,
              )
              .toList();
          if (docs.isEmpty) {
            current = null;
            return null;
          }
          docs.sort((a, b) {
            DateTime created(Map<String, dynamic> d) =>
                (d['createdAt'] is Timestamp
                        ? d['createdAt'] as Timestamp
                        : Timestamp.fromDate(
                            DataCompatibility.date(d['date'])!,
                          ))
                    .toDate();
            final order = created(b.data()).compareTo(created(a.data()));
            return order == 0 ? a.id.compareTo(b.id) : order;
          });
          final selected =
              docs.where((doc) => doc.id == current?.number).firstOrNull ??
              docs.first;
          final d = selected.data();
          String text(String key) => d[key] is String ? d[key] as String : '';
          final date = (Timestamp.fromDate(DataCompatibility.date(d['date'])!))
              .toDate();
          current = Appointment(
            number: selected.id,
            doctor: Doctor(
              id: text('doctorId'),
              name: text('doctorName'),
              specialization: text('department'),
              location: text('clinic'),
              experience: '',
              rating: 0,
            ),
            date: date,
            time: text('time'),
            location: text('clinic'),
            dateLabel: '${date.day}/${date.month}/${date.year}',
            patientName: text('patientName'),
            nic: text('nic'),
            contactNumber: text('contactNumber'),
            email: text('email'),
            isCancelled:
                DataCompatibility.appointmentStatus(d['status']) == 'Cancelled',
          );
          return current;
        });
  }
}
