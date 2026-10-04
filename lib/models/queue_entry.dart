class QueueEntry {
  const QueueEntry({
    required this.currentServing,
    required this.yourPosition,
    required this.totalInQueue,
    required this.estimatedMinutes,
    required this.peopleAhead,
  });

  final int currentServing;
  final int yourPosition;
  final int totalInQueue;
  final int estimatedMinutes;
  final int peopleAhead;

  int get served => currentServing;
  int get waiting => totalInQueue - currentServing;

  factory QueueEntry.fromMap(Map<String, dynamic> data) => QueueEntry(
    currentServing: (data['currentServing'] as num?)?.toInt() ?? 0,
    yourPosition: (data['yourPosition'] as num?)?.toInt() ?? 1,
    totalInQueue: (data['totalInQueue'] as num?)?.toInt() ?? 1,
    estimatedMinutes: (data['estimatedMinutes'] as num?)?.toInt() ?? 0,
    peopleAhead: (data['peopleAhead'] as num?)?.toInt() ?? 0,
  );

  Map<String, int> toMap() => {
    'currentServing': currentServing,
    'yourPosition': yourPosition,
    'totalInQueue': totalInQueue,
    'estimatedMinutes': estimatedMinutes,
    'peopleAhead': peopleAhead,
  };
}