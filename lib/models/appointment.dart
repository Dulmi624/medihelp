import 'doctor.dart';

class Appointment {
  const Appointment({
    required this.number,
    required this.doctor,
    required this.date,
    required this.time,
    required this.location,
    this.patientName = '',
    this.nic = '',
    this.contactNumber = '',
    this.email = '',
  });

  final String number;
  final Doctor doctor;
  final DateTime date;
  final String time;
  final String location;
  final String patientName;
  final String nic;
  final String contactNumber;
  final String email;

  Appointment copyWith({
    String? patientName,
    String? nic,
    String? contactNumber,
    String? email,
  }) {
    return Appointment(
      number: number,
      doctor: doctor,
      date: date,
      time: time,
      location: location,
      patientName: patientName ?? this.patientName,
      nic: nic ?? this.nic,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
    );
  }
}