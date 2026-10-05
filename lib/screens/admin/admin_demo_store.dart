import 'package:flutter/foundation.dart';

// In-memory demo only. Changes reset when the application restarts.
class AdminDemoStore extends ChangeNotifier {
  static final instance = AdminDemoStore._();
  late final List<DemoQueuePatient> patients;
  final List<String> activity = ['Demo session started'];
  AdminDemoStore._() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    patients = [
      DemoQueuePatient('Q001', 'Sample Patient A', 'OPD', today, 20, 'Waiting'),
      DemoQueuePatient(
        'Q002',
        'Sample Patient B',
        'Dental',
        today,
        25,
        'Waiting',
      ),
      DemoQueuePatient('Q003', 'Sample Patient C', 'OPD', today, 10, 'Waiting'),
      DemoQueuePatient(
        'Q004',
        'Sample Patient D',
        'Paediatrics',
        today,
        12,
        'In Consultation',
      ),
      DemoQueuePatient(
        'Q005',
        'Sample Patient E',
        'OPD',
        today,
        18,
        'Completed',
      ),
    ];
  }
  final List<DemoAppointment> appointments = [
    DemoAppointment(
      id: 'DEMO-001',
      patient: 'Sample Patient A',
      doctor: 'Dr. Perera',
      department: 'OPD',
      time: '08:30 AM',
      status: 'Scheduled',
    ),
    DemoAppointment(
      id: 'DEMO-002',
      patient: 'Sample Patient B',
      doctor: 'Dr. Silva',
      department: 'Dental',
      time: '09:00 AM',
      status: 'Checked In',
    ),
    DemoAppointment(
      id: 'DEMO-003',
      patient: 'Sample Patient C',
      doctor: 'Dr. Fernando',
      department: 'Paediatrics',
      time: '09:30 AM',
      status: 'Completed',
    ),
    DemoAppointment(
      id: 'DEMO-004',
      patient: 'Sample Patient D',
      doctor: 'Dr. Perera',
      department: 'OPD',
      time: '10:00 AM',
      status: 'Cancelled',
    ),
  ];
  void updateAppointment(DemoAppointment appointment, String status) {
    if (appointment.status == status) return;
    appointment.status = status;
    record('${appointment.id}: appointment status changed to $status');
  }

  void callPatient(DemoQueuePatient patient) {
    if (patient.status != 'Waiting') return;
    patient.status = 'Called';
    record('${patient.number}: patient called in ${patient.department}');
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
}

class DemoAppointment {
  DemoAppointment({
    required this.id,
    required this.patient,
    required this.doctor,
    required this.department,
    required this.time,
    required this.status,
  });

  final String id;
  final String patient;
  final String doctor;
  final String department;
  final String time;
  String status;
}

class DemoQueuePatient {
  DemoQueuePatient(
    this.number,
    this.name,
    this.department,
    this.date,
    this.waitMinutes,
    this.status,
  );

  final String number;
  final String name;
  final String department;
  final DateTime date;
  final int waitMinutes;
  String status;
}
