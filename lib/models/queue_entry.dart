import 'package:cloud_firestore/cloud_firestore.dart';

class QueueEntry {
  const QueueEntry({
    required this.currentServing,
    required this.yourPosition,
    required this.totalInQueue,
    required this.estimatedMinutes,
    required this.peopleAhead,
    this.status = 'Waiting',
    this.positionConfirmed = false,
    this.estimateConfirmed = false,
    this.completedCount = 0,
    this.waitingCount = 0,
    this.totalToday = 0,
    this.minutesPerConsultation = 10,
    this.metricsUpdatedAt,
    this.fromCache = false,
  });
  final int currentServing,
      yourPosition,
      totalInQueue,
      estimatedMinutes,
      peopleAhead;
  final String status;
  final bool positionConfirmed, estimateConfirmed;
  final int completedCount, waitingCount, totalToday, minutesPerConsultation;
  final DateTime? metricsUpdatedAt;
  final bool fromCache;
  int get served => completedCount;
  int get waiting => waitingCount;
  double get progress =>
      totalToday > 0 ? (completedCount / totalToday).clamp(0.0, 1.0) : 0;
  bool get active => ['Waiting', 'Called', 'In Consultation'].contains(status);
  static int _number(Map<String, dynamic> data, String key) {
    final value = data[key];
    return value is num && value.isFinite && value >= 0 ? value.toInt() : 0;
  }

  factory QueueEntry.fromMap(Map<String, dynamic> data) => QueueEntry(
    currentServing: _number(data, 'currentServing'),
    yourPosition: _number(data, 'yourPosition'),
    totalInQueue: _number(data, 'totalInQueue'),
    estimatedMinutes: _number(data, 'estimatedMinutes'),
    peopleAhead: _number(data, 'peopleAhead'),
    status: data['status'] as String? ?? 'Unknown',
    positionConfirmed: data['positionConfirmed'] == true,
    estimateConfirmed: data['estimateConfirmed'] == true,
    completedCount: _number(data, 'completedCount'),
    waitingCount: _number(data, 'waitingCount'),
    totalToday: _number(data, 'totalToday'),
    minutesPerConsultation: _number(data, 'minutesPerConsultation'),
    metricsUpdatedAt: data['metricsUpdatedAt'] is Timestamp
        ? (data['metricsUpdatedAt'] as Timestamp).toDate()
        : null,
    fromCache: data['_fromCache'] == true,
  );
  Map<String, dynamic> toMap() => {
    'currentServing': currentServing,
    'yourPosition': yourPosition,
    'totalInQueue': totalInQueue,
    'estimatedMinutes': estimatedMinutes,
    'peopleAhead': peopleAhead,
    'status': status,
    'positionConfirmed': positionConfirmed,
    'estimateConfirmed': estimateConfirmed,
    'completedCount': completedCount,
    'waitingCount': waitingCount,
    'totalToday': totalToday,
    'minutesPerConsultation': minutesPerConsultation,
  };
}
