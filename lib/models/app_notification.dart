enum NotificationType { confirmed, queueUpdate, reminder, rescheduled, general }

class AppNotification {
  const AppNotification({
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });

  final String title;
  final String message;
  final String time;
  final NotificationType type;
  final bool isRead;

  AppNotification copyWith({bool? isRead}) => AppNotification(
        title: title,
        message: message,
        time: time,
        type: type,
        isRead: isRead ?? this.isRead,
      );
}