import 'package:cloud_firestore/cloud_firestore.dart';

import 'queue_calculator.dart';
import 'data_compatibility.dart';

// Admin-side recalculation, requiring an online Admin session. Patient clients
// only read their own queue document; they do not read other patients' details.
class QueueMetricsService {
  QueueMetricsService(this.db);
  final FirebaseFirestore db;

  Future<void> refresh(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> queues,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> appointments, {
    required int minutesPerConsultation,
  }) async {
    final byId = {for (final doc in appointments) doc.id: doc.data()};
    final groups = <String, List<String>>{};
    for (final queue in queues) {
      final q = queue.data();
      final appId = q['appointmentId'] is String
          ? q['appointmentId'] as String
          : queue.id;
      final a = byId[appId];
      final date = DataCompatibility.date(a?['date']);
      final doctor = a?['doctorId'];
      if (date == null || doctor is! String || doctor.isEmpty) continue;
      final member = QueueMember(
        id: queue.id,
        doctorId: doctor,
        date: date,
        createdAt: date,
        status: DataCompatibility.queueStatus(q['status']),
      );
      groups.putIfAbsent(member.group, () => []).add(queue.id);
    }
    for (final group in groups.entries) {
      // Transactions below are bounded to avoid exceeding Firestore limits.
      if (group.value.length > 150) {
        throw StateError(
          'This doctor/date queue exceeds 150 records. A server-side calculator is required.',
        );
      }
      await db.runTransaction((tx) async {
        final currentQueues = <String, Map<String, dynamic>>{};
        final currentAppointments = <String, Map<String, dynamic>>{};
        for (final id in group.value) {
          final snapshot = await tx.get(db.collection('queues').doc(id));
          if (snapshot.exists) currentQueues[id] = snapshot.data()!;
        }
        for (final data in currentQueues.entries) {
          final appId = data.value['appointmentId'] is String
              ? data.value['appointmentId'] as String
              : data.key;
          if (!currentAppointments.containsKey(appId)) {
            final snapshot = await tx.get(
              db.collection('appointments').doc(appId),
            );
            if (snapshot.exists) currentAppointments[appId] = snapshot.data()!;
          }
        }
        final members = <QueueMember>[];
        for (final entry in currentQueues.entries) {
          final q = entry.value;
          final appId = q['appointmentId'] is String
              ? q['appointmentId'] as String
              : entry.key;
          final a = currentAppointments[appId];
          final date = DataCompatibility.date(a?['date']);
          final doctor = a?['doctorId'];
          final created = q['createdAt'] ?? a?['createdAt'];
          if (date == null ||
              doctor is! String ||
              doctor.isEmpty ||
              created is! Timestamp ||
              DataCompatibility.appointmentStatus(a?['status']) ==
                  'Cancelled') {
            continue;
          }
          final member = QueueMember(
            id: entry.key,
            doctorId: doctor,
            date: date,
            createdAt: created.toDate(),
            status: DataCompatibility.queueStatus(q['status']),
          );
          // A concurrent reschedule will be recalculated by the next snapshot.
          if (member.group == group.key) members.add(member);
        }
        final metrics = QueueCalculator.calculate(
          members,
          minutesPerConsultation: minutesPerConsultation,
        );
        for (final entry in metrics.entries) {
          final old = currentQueues[entry.key]!;
          final changed = entry.value.entries.any(
            (field) => old[field.key] != field.value,
          );
          if (changed) {
            tx.update(db.collection('queues').doc(entry.key), {
              ...entry.value,
              'metricsUpdatedAt': FieldValue.serverTimestamp(),
            });
          }
        }
      });
    }
  }
}
