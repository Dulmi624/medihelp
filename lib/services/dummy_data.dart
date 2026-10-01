import '../models/app_notification.dart';
import '../models/appointment.dart';
import '../models/doctor.dart';
import '../models/queue_entry.dart';

abstract final class DummyData {
  static const doctors = [
    Doctor(id: 'doc-001', name: 'Dr. Sarah Williams', specialization: 'General Physician', location: 'MediQueue Central Hospital', experience: '12 years experience', rating: 4.9),
    Doctor(id: 'doc-002', name: 'Dr. Michael Chen', specialization: 'Pediatrician', location: 'MediQueue Central Hospital', experience: '9 years experience', rating: 4.8),
    Doctor(id: 'doc-003', name: 'Dr. Emily Rodriguez', specialization: 'Dermatologist', location: 'MediQueue Central Hospital', experience: '10 years experience', rating: 4.7),
    Doctor(id: 'doc-004', name: 'Dr. James Anderson', specialization: 'Cardiology', location: 'MediQueue Central Hospital', experience: '15 years experience', rating: 4.9),
  ];

  static final appointment = Appointment(
    number: 'OPD20260921-001',
    doctor: doctors.first,
    date: DateTime(2026, 9, 21),
    time: '09:30 AM',
    location: 'MediQueue Central Hospital',
  );

  static const queue = QueueEntry(currentServing: 18, yourPosition: 24, totalInQueue: 32, estimatedMinutes: 20);

  static const notifications = [
    AppNotification(title: 'Appointment Confirmed', message: 'Your appointment with Dr. Sarah Williams is confirmed.', time: '10 min ago', type: NotificationType.confirmed),
    AppNotification(title: 'Queue Update', message: 'You are now number 24 in the queue.', time: '30 min ago', type: NotificationType.queueUpdate),
    AppNotification(title: 'Appointment Reminder', message: 'Your appointment is tomorrow at 09:30 AM.', time: '2 hours ago', type: NotificationType.reminder, isRead: true),
    AppNotification(title: 'Clinic Rescheduled', message: 'Your clinic has moved to Central Hospital, Floor 2.', time: 'Yesterday', type: NotificationType.rescheduled, isRead: true),
    AppNotification(title: 'MediQueue Notice', message: 'Please arrive 15 minutes before your appointment.', time: 'Yesterday', type: NotificationType.general, isRead: true),
  ];
}