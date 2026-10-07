import '../models/app_notification.dart';
import '../models/appointment.dart';
import '../models/doctor.dart';
import '../models/queue_entry.dart';

abstract final class DummyData {
  static const doctors = [
    Doctor(id: 'doc-001', name: 'Dr. N. Perera', specialization: 'General Medicine', location: 'OPD - Clinic 01', experience: '12 years experience', rating: 4.9),
    Doctor(id: 'doc-002', name: 'Dr. Michael Chen', specialization: 'Pediatrician', location: 'MediQueue Central Hospital', experience: '9 years experience', rating: 4.8),
    Doctor(id: 'doc-003', name: 'Dr. Emily Rodriguez', specialization: 'Dermatologist', location: 'MediQueue Central Hospital', experience: '10 years experience', rating: 4.7),
    Doctor(id: 'doc-004', name: 'Dr. James Anderson', specialization: 'Cardiology', location: 'MediQueue Central Hospital', experience: '15 years experience', rating: 4.9),
  ];

  static final appointment = Appointment(
    number: 'OPD20260812-001',
    doctor: doctors.first,
    date: DateTime(2026, 8, 12),
    dateLabel: '12 Aug 2026 (Tuesday)',
    time: '10:30 AM',
    location: 'Main OPD Building',
  );

  static const queue = QueueEntry(currentServing: 12, yourPosition: 5, totalInQueue: 17, estimatedMinutes: 20, peopleAhead: 4);

  static const notifications = [
    AppNotification(title: 'Appointment Confirmed', message: 'Your appointment with Dr. N. Perera is confirmed.', time: '10 min ago', type: NotificationType.confirmed),
    AppNotification(title: 'Queue Update', message: 'You are now number 5 in the queue.', time: '30 min ago', type: NotificationType.queueUpdate),
    AppNotification(title: 'Appointment Reminder', message: 'Your appointment is tomorrow at 10:30 AM.', time: '2 hours ago', type: NotificationType.reminder),
    AppNotification(title: 'Queue Update', message: 'The doctor is currently serving queue number 12.', time: '3 hours ago', type: NotificationType.queueUpdate, isRead: true),
    AppNotification(title: 'Appointment Rescheduled', message: 'Your appointment time was updated successfully.', time: 'Yesterday', type: NotificationType.rescheduled, isRead: true),
    AppNotification(title: 'General Notice', message: 'Please arrive 15 minutes before your appointment.', time: 'Yesterday', type: NotificationType.general, isRead: true),
  ];
}