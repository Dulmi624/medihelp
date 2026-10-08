// Pure queue calculation. Queues are independent for each doctor and date.
class QueueMember {
  const QueueMember({
    required this.id,
    required this.doctorId,
    required this.date,
    required this.createdAt,
    required this.status,
  });
  final String id, doctorId, status;
  final DateTime date, createdAt;
  String get group =>
      '${Uri.encodeComponent(doctorId)}_${date.year}-${date.month}-${date.day}';
  bool get active => ['Waiting', 'Called', 'In Consultation'].contains(status);
}

class QueueCalculator {
  static int compare(QueueMember a, QueueMember b) {
    final order = a.createdAt.compareTo(b.createdAt);
    return order != 0 ? order : a.id.compareTo(b.id);
  }

  static Map<String, Map<String, dynamic>> calculate(
    List<QueueMember> members, {
    required int minutesPerConsultation,
  }) {
    if (minutesPerConsultation <= 0) {
      throw ArgumentError('Consultation duration must be positive.');
    }
    final groups = <String, List<QueueMember>>{};
    for (final member in members) {
      if (member.active || member.status == 'Completed') {
        groups.putIfAbsent(member.group, () => []).add(member);
      }
    }
    final results = <String, Map<String, dynamic>>{};
    for (final group in groups.values) {
      group.sort(compare);
      final beingServed = group
          .where((m) => m.status == 'Called' || m.status == 'In Consultation')
          .toList();
      final waiting = group.where((m) => m.status == 'Waiting').toList();
      final active = [...beingServed, ...waiting];
      final completed = group.where((m) => m.status == 'Completed').length;
      for (final member in group) {
        final index = active.indexOf(member);
        final ahead = index < 0 ? 0 : index;
        results[member.id] = {
          'currentServing': beingServed.length,
          'yourPosition': index < 0 ? 0 : index + 1,
          'totalInQueue': active.length,
          'peopleAhead': ahead,
          'estimatedMinutes': member.status == 'Waiting'
              ? ahead * minutesPerConsultation
              : 0,
          'completedCount': completed,
          'waitingCount': waiting.length,
          'totalToday': group.length,
          'positionConfirmed': true,
          'estimateConfirmed': true,
          'minutesPerConsultation': minutesPerConsultation,
        };
      }
    }
    return results;
  }
}
