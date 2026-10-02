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
}