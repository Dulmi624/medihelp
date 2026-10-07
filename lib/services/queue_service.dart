import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/queue_entry.dart';

class QueueService {
  QueueService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<QueueEntry?> watch(String appointmentNumber) {
    return _firestore.collection('queues').doc(appointmentNumber).snapshots().map(
      (snapshot) {
        final data = snapshot.data();
        return data == null ? null : QueueEntry.fromMap(data);
      },
    );
  }

  Future<void> createInitial(String appointmentNumber) {
    return _firestore.collection('queues').doc(appointmentNumber).set({
      'currentServing': 0,
      'yourPosition': 1,
      'totalInQueue': 1,
      'estimatedMinutes': 5,
      'peopleAhead': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> remove(String appointmentNumber) {
    return _firestore.collection('queues').doc(appointmentNumber).delete();
  }
}
