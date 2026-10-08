import 'package:cloud_firestore/cloud_firestore.dart';

// Read older snake_case values without rewriting database records silently.
class DataCompatibility {
  static String _key(Object? value) => value is String
      ? value.trim().toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '')
      : '';
  static String appointmentStatus(Object? value) => switch (_key(value)) {
    'scheduled' || 'upcoming' => 'Scheduled',
    'checkedin' => 'Checked In',
    'completed' => 'Completed',
    'cancelled' || 'canceled' => 'Cancelled',
    _ => value is String ? value.trim() : 'Unknown',
  };
  static String queueStatus(Object? value) => switch (_key(value)) {
    'waiting' => 'Waiting',
    'called' => 'Called',
    'inconsultation' => 'In Consultation',
    'completed' => 'Completed',
    'cancelled' || 'canceled' => 'Cancelled',
    _ => value is String ? value.trim() : 'Unknown',
  };
  static DateTime? date(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is! String) return null;
    final text = value.trim();
    if (RegExp(r'^\d{4}-\d{2}-\d{2}(?:$|[T ])').hasMatch(text)) {
      final parts = text.substring(0, 10).split('-').map(int.parse).toList();
      if (_valid(parts[0], parts[1], parts[2]) == null) return null;
      return DateTime.tryParse(text)?.toLocal();
    }
    final slash = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(text);
    if (slash != null) {
      return _valid(
        int.parse(slash[3]!),
        int.parse(slash[2]!),
        int.parse(slash[1]!),
      );
    }
    final long = RegExp(r'^(\d{1,2})\s+([A-Za-z]+)\s+(\d{4})$')
        .firstMatch(text);
    if (long == null) return null;
    const months = [
      'january',
      'february',
      'march',
      'april',
      'may',
      'june',
      'july',
      'august',
      'september',
      'october',
      'november',
      'december',
    ];
    final month = months.indexOf(long[2]!.toLowerCase()) + 1;
    if (month == 0) return null;
    return _valid(int.parse(long[3]!), month, int.parse(long[1]!));
  }

  static DateTime? _valid(int year, int month, int day) {
    final result = DateTime(year, month, day);
    return result.year == year && result.month == month && result.day == day
        ? result
        : null;
  }
}
