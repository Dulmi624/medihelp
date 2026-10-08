import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/queue_metrics_service.dart';
import '../../services/data_compatibility.dart';

// Filename retained so existing imports continue to work. No demo data.
class AdminDataStore extends ChangeNotifier {
  AdminDataStore._();
  static final instance = AdminDataStore._();
  final _db = FirebaseFirestore.instance;
  List<AdminAppointment> appointments = [];
  List<AdminQueuePatient> patients = [];
  final List<String> activity = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _queues = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _appointmentDocs = [];
  bool _appointmentsServer = false;
  bool _queuesServer = false;
  bool _metricsRunning = false;
  bool _metricsRequested = false;
  String? metricsError;
  static const consultationMinutes = 10;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _appointmentsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _queuesSub;
  int _session = 0;
  bool _appointmentsReady = false;
  bool _queuesReady = false;
  String? _appointmentsError;
  String? _queuesError;
  bool get loading => !_appointmentsReady || !_queuesReady;
  String? get error => _appointmentsError ?? _queuesError;
  int skippedAppointments = 0;
  int skippedQueues = 0;
  List<String> get departments => ({
    ...appointments.map((a) => a.department),
    ...patients.map((p) => p.department),
  }.toList()..sort());

  Future<void> start() async {
    stop();
    final session = _session;
    try {
      await _requireAdmin();
      if (session != _session) return;
      _appointmentsSub = _db
          .collection('appointments')
          .snapshots(includeMetadataChanges: true)
          .listen(
            (snapshot) {
              if (session != _session) return;
              skippedAppointments = 0;
              _appointmentDocs = snapshot.docs;
              _appointmentsServer =
                  !snapshot.metadata.isFromCache &&
                  !snapshot.metadata.hasPendingWrites;
              final parsed = <AdminAppointment>[];
              for (final doc in snapshot.docs) {
                final value = AdminAppointment.fromDocument(doc);
                if (value == null) {
                  skippedAppointments++;
                } else {
                  parsed.add(value);
                }
              }
              appointments = parsed..sort((a, b) => b.date.compareTo(a.date));
              _appointmentsReady = true;
              _appointmentsError = null;
              _joinQueues();
              _scheduleMetrics();
              notifyListeners();
            },
            onError: (Object e) {
              if (session != _session) return;
              _appointmentsReady = true;
              _appointmentsError = messageFor(e);
              notifyListeners();
            },
          );
      _queuesSub = _db
          .collection('queues')
          .snapshots(includeMetadataChanges: true)
          .listen(
            (snapshot) {
              if (session != _session) return;
              _queues = snapshot.docs;
              _queuesServer =
                  !snapshot.metadata.isFromCache &&
                  !snapshot.metadata.hasPendingWrites;
              _queuesReady = true;
              _queuesError = null;
              _joinQueues();
              _scheduleMetrics();
              notifyListeners();
            },
            onError: (Object e) {
              if (session != _session) return;
              _queuesReady = true;
              _queuesError = messageFor(e);
              notifyListeners();
            },
          );
    } catch (e) {
      if (session != _session) return;
      _appointmentsReady = true;
      _queuesReady = true;
      _appointmentsError = messageFor(e);
      notifyListeners();
    }
  }

  void stop() {
    _session++;
    _appointmentsSub?.cancel();
    _queuesSub?.cancel();
    _appointmentsSub = null;
    _queuesSub = null;
    appointments = [];
    patients = [];
    _queues = [];
    _appointmentDocs = [];
    _appointmentsServer = false;
    _queuesServer = false;
    _metricsRequested = false;
    metricsError = null;
    activity.clear();
    _appointmentsReady = false;
    _queuesReady = false;
    _appointmentsError = null;
    _queuesError = null;
    skippedAppointments = 0;
    skippedQueues = 0;
  }

  void _joinQueues() {
    final byId = {for (final a in appointments) a.id: a};
    skippedQueues = 0;
    final parsed = <AdminQueuePatient>[];
    for (final doc in _queues) {
      final data = doc.data();
      final appointmentId = _string(data, 'appointmentId', doc.id);
      final appointment = byId[appointmentId];
      if (appointment == null || appointment.status == 'Cancelled') {
        skippedQueues++;
        continue;
      }
      final status = DataCompatibility.queueStatus(data['status']);
      if (![
        'Waiting',
        'Called',
        'In Consultation',
        'Completed',
      ].contains(status)) {
        skippedQueues++;
        continue;
      }
      final minutes = data['estimatedMinutes'];
      parsed.add(
        AdminQueuePatient(
          id: doc.id,
          appointmentId: appointmentId,
          number: _string(data, 'queueNumber', doc.id),
          name: _string(data, 'patientName', appointment.patient),
          department: _string(data, 'department', appointment.department),
          doctorId: appointment.doctorId,
          date: appointment.date,
          status: status,
          createdAt: _date(data['createdAt']) ?? appointment.createdAt,
          waitMinutes: minutes is num && minutes.isFinite && minutes >= 0
              ? minutes.toInt()
              : 0,
          estimateConfirmed:
              data['estimateConfirmed'] == true &&
              minutes is num &&
              minutes.isFinite &&
              minutes >= 0,
        ),
      );
    }
    patients = parsed..sort(compareQueue);
  }

  static int compareQueue(AdminQueuePatient a, AdminQueuePatient b) {
    final order = a.createdAt.compareTo(b.createdAt);
    return order != 0 ? order : a.id.compareTo(b.id);
  }

  void _scheduleMetrics() {
    _metricsRequested = true;
    if (_metricsRunning ||
        !_appointmentsServer ||
        !_queuesServer ||
        loading ||
        error != null) {
      return;
    }
    _syncMetrics();
  }

  Future<void> _syncMetrics() async {
    _metricsRunning = true;
    final session = _session;
    try {
      while (_metricsRequested &&
          session == _session &&
          _appointmentsServer &&
          _queuesServer) {
        _metricsRequested = false;
        await QueueMetricsService(_db).refresh(
          List.of(_queues),
          List.of(_appointmentDocs),
          minutesPerConsultation: consultationMinutes,
        );
        if (session != _session) return;
        metricsError = null;
      }
    } catch (e) {
      if (session == _session) metricsError = messageFor(e);
    } finally {
      _metricsRunning = false;
      if (session == _session) notifyListeners();
      // A new Admin session may have arrived while an old job finished.
      if (session != _session && _metricsRequested) _scheduleMetrics();
    }
  }

  Future<void> _requireAdmin() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw StateError('Please sign in again.');
    final user = await _db
        .collection('users')
        .doc(uid)
        .get(const GetOptions(source: Source.server));
    if (user.data()?['role'] != 'admin') {
      throw StateError('Only Admin accounts can use this screen.');
    }
  }

  Future<void> updateAppointment(
    AdminAppointment appointment,
    String status,
  ) async {
    await _requireAdmin();
    final ref = _db.collection('appointments').doc(appointment.id);
    // All new bookings use the same document ID in both collections.
    final queueRef = _db.collection('queues').doc(appointment.id);
    await _db.runTransaction((tx) async {
      final snapshot = await tx.get(ref);
      final queue = await tx.get(queueRef);
      final current = DataCompatibility.appointmentStatus(
        snapshot.data()?['status'],
      );
      if (!snapshot.exists) throw StateError('This appointment was removed.');
      if (current != appointment.status) {
        throw StateError(
          'This appointment changed. Close the dialog and try again.',
        );
      }
      if (current == status) return;
      if (!['Scheduled', 'Checked In'].contains(current) ||
          !['Checked In', 'Completed', 'Cancelled'].contains(status)) {
        throw StateError(
          'Completed/cancelled appointments cannot be reopened.',
        );
      }
      tx.update(ref, {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (queue.exists && status == 'Cancelled') tx.delete(queueRef);
      if (queue.exists && status == 'Completed') {
        tx.update(queueRef, {
          'status': 'Completed',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
    record('${appointment.patient}: appointment changed to $status');
  }

  Future<void> callPatient(AdminQueuePatient patient) =>
      changeQueueStatus(patient, 'Called');

  Future<void> changeQueueStatus(
    AdminQueuePatient patient,
    String status,
  ) async {
    await _requireAdmin();
    final ref = _db.collection('queues').doc(patient.id);
    final appointmentRef = _db
        .collection('appointments')
        .doc(patient.appointmentId);
    final peers = patients
        .where(
          (p) =>
              p.id != patient.id &&
              p.doctorId == patient.doctorId &&
              p.date.year == patient.date.year &&
              p.date.month == patient.date.month &&
              p.date.day == patient.date.day,
        )
        .toList();
    await _db.runTransaction((tx) async {
      final queue = await tx.get(ref);
      final appointment = await tx.get(appointmentRef);
      final data = appointment.data();
      // Read peers before writing. Concurrent callers retry if the same
      // doctor/date queue changes; a doctor serves one patient at a time.
      if (status == 'Called') {
        for (final peer in peers) {
          final peerQueue = await tx.get(_db.collection('queues').doc(peer.id));
          final peerAppointment = await tx.get(
            _db.collection('appointments').doc(peer.appointmentId),
          );
          final a = peerAppointment.data();
          final d = _date(a?['date']);
          if (d == null ||
              a?['doctorId'] != data?['doctorId'] ||
              DataCompatibility.date(data?['date']) == null ||
              !_sameDay(d, DataCompatibility.date(data?['date'])!) ||
              [
                'Cancelled',
                'Completed',
              ].contains(DataCompatibility.appointmentStatus(a?['status']))) {
            continue;
          }
          final peerStatus = DataCompatibility.queueStatus(
            peerQueue.data()?['status'],
          );
          if (peerStatus == 'Called' || peerStatus == 'In Consultation') {
            throw StateError(
              'This doctor already has a patient called/in consultation. Complete that consultation first.',
            );
          }
          if (peerStatus == 'Waiting' && compareQueue(peer, patient) < 0) {
            throw StateError(
              'An earlier patient is waiting. Refresh and call the first patient.',
            );
          }
        }
      }
      if (!queue.exists ||
          data == null ||
          [
            'Cancelled',
            'Completed',
          ].contains(DataCompatibility.appointmentStatus(data['status']))) {
        throw StateError('This queue entry is no longer active.');
      }
      final current = DataCompatibility.queueStatus(queue.data()?['status']);
      final allowed =
          (current == 'Waiting' && status == 'Called') ||
          (current == 'Called' && status == 'In Consultation') ||
          (current == 'In Consultation' && status == 'Completed');
      if (!allowed) {
        throw StateError('This queue entry changed. Please try again.');
      }
      final date = _date(data['date']);
      final now = DateTime.now();
      if (date == null ||
          date.year != now.year ||
          date.month != now.month ||
          date.day != now.day) {
        throw StateError('Only today\'s queue can be served.');
      }
      tx.update(ref, {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (status == 'Completed') {
        tx.update(appointmentRef, {
          'status': 'Completed',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
    record('${patient.name}: queue changed to $status');
  }

  void record(String message) {
    final now = DateTime.now();
    activity.insert(
      0,
      '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} • $message',
    );
    if (activity.length > 10) activity.removeLast();
    notifyListeners();
  }

  static String messageFor(Object error) {
    if (error is StateError) return error.message.toString();
    if (error is FirebaseException && error.code == 'permission-denied') {
      return 'Access denied. Ask the project owner to check Admin permissions.';
    }
    return 'Could not load/save data. Check your connection and try again.';
  }
}

String _string(Map<String, dynamic> data, String key, [String fallback = '']) {
  final value = data[key];
  return value is String && value.trim().isNotEmpty ? value.trim() : fallback;
}

DateTime? _date(dynamic value) => DataCompatibility.date(value);
bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class AdminAppointment {
  const AdminAppointment({
    required this.id,
    required this.patient,
    required this.doctor,
    required this.department,
    required this.time,
    required this.status,
    required this.date,
    required this.createdAt,
    this.doctorId = '',
  });
  final String id, patient, doctor, department, time, status;
  final String doctorId;
  final DateTime date, createdAt;
  static AdminAppointment? fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final date = _date(data['date']);
    if (date == null) return null;
    return AdminAppointment(
      id: doc.id,
      patient: _string(data, 'patientName', 'Unnamed patient'),
      doctor: _string(data, 'doctorName', 'Unknown doctor'),
      doctorId: _string(data, 'doctorId'),
      department: _string(data, 'department', 'Unspecified'),
      time: _string(data, 'time'),
      status: DataCompatibility.appointmentStatus(data['status']),
      date: date,
      createdAt: _date(data['createdAt']) ?? date,
    );
  }
}

class AdminQueuePatient {
  const AdminQueuePatient({
    required this.id,
    required this.appointmentId,
    required this.number,
    required this.name,
    required this.department,
    required this.date,
    required this.createdAt,
    required this.waitMinutes,
    required this.estimateConfirmed,
    required this.status,
    this.doctorId = '',
  });
  final String id, appointmentId, number, name, department, status;
  final String doctorId;
  final DateTime date, createdAt;
  final int waitMinutes;
  final bool estimateConfirmed;
}
