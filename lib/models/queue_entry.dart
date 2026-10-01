class QueueEntry {
  const QueueEntry({
    required this.currentServing,
    required this.yourPosition,
    required this.totalInQueue,
    required this.estimatedMinutes,
  });

  final int currentServing;
  final int yourPosition;
  final int totalInQueue;
  final int estimatedMinutes;

  int get peopleAhead => yourPosition - currentServing;
  int get served => currentServing;
  int get waiting => totalInQueue - currentServing;
}