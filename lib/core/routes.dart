import 'package:flutter/material.dart';

import '../models/appointment.dart';
import '../models/doctor.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/patient_signup_screen.dart';
import '../screens/auth/splash_screen.dart';

import '../screens/admin/admin_home_screen.dart';

import '../screens/patient/patient_home_screen.dart';
import '../screens/patient/booking_success_screen.dart';
import '../screens/patient/confirm_booking_screen.dart';
import '../screens/patient/my_appointment_screen.dart';
import '../screens/patient/notifications_screen.dart';
import '../screens/patient/queue_details_screen.dart';
import '../screens/patient/queue_status_screen.dart';
import '../screens/patient/select_date_time_screen.dart';
import '../screens/patient/select_doctor_screen.dart';

import '../screens/receptionist/receptionist_home_screen.dart';
import '../screens/receptionist/appointment_management_screen.dart';
import '../screens/receptionist/receptionist_queue_screen.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const patientSignUp = '/patient-sign-up';

  static const patientHome = '/patient';
  static const comingSoon = '/patient/coming-soon';
  static const selectDoctor = '/patient/select-doctor';
  static const findDoctor = '/patient/find-doctor';
  static const hospitalInfo = '/patient/hospital-info';
  static const contactUs = '/patient/contact-us';
  static const selectDateTime = '/patient/select-date-time';
  static const confirmBooking = '/patient/confirm-booking';
  static const bookingSuccess = '/patient/booking-success';
  static const myAppointment = '/patient/appointment';
  static const queueStatus = '/patient/queue-status';
  static const queueDetails = '/patient/queue-details';
  static const notifications = '/patient/notifications';

  static const receptionistHome = '/receptionist';
  static const appointmentManagement = '/receptionist/appointments';
  static const receptionistQueue = '/receptionist/queue';

  static const adminHome = '/admin';

  static SelectDateTimeScreen _dateTimeScreen(Object? arguments) {
    if (arguments is Doctor) {
      return SelectDateTimeScreen(doctor: arguments);
    }

    if (arguments is Map) {
      final doctor = arguments['doctor'];
      final existing = arguments['existingAppointment'];

      if (doctor is Doctor && (existing == null || existing is Appointment)) {
        return SelectDateTimeScreen(
          doctor: doctor,
          existingAppointment: existing as Appointment?,
        );
      }
    }

    throw ArgumentError('Valid doctor details are required.');
  }

  static ConfirmBookingScreen _confirmScreen(Object? arguments) {
    if (arguments is! Map) {
      throw ArgumentError('Booking details are required.');
    }

    final doctor = arguments['doctor'];
    final date = arguments['date'];
    final time = arguments['time'];
    final existing = arguments['existingAppointment'];

    if (doctor is! Doctor ||
        date is! DateTime ||
        time is! String ||
        (existing != null && existing is! Appointment)) {
      throw ArgumentError('Valid booking details are required.');
    }

    return ConfirmBookingScreen(
      doctor: doctor,
      date: date,
      time: time,
      existingAppointment: existing as Appointment?,
    );
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final arguments = settings.arguments;

    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (_) => switch (settings.name) {
        splash => const SplashScreen(),
        login => const LoginScreen(),
        patientSignUp => const PatientSignUpScreen(),
        patientHome => const PatientHomeScreen(),
        selectDoctor => const SelectDoctorScreen(),
        selectDateTime => _dateTimeScreen(arguments),
        confirmBooking => _confirmScreen(arguments),
        bookingSuccess => BookingSuccessScreen(
          appointment: arguments is Appointment
              ? arguments
              : throw ArgumentError('Appointment is required.'),
        ),
        myAppointment => const MyAppointmentScreen(),
        queueStatus => const QueueStatusScreen(),
        queueDetails => const QueueDetailsScreen(),
        notifications => const NotificationsScreen(),
        receptionistHome => const ReceptionistHomeScreen(),
        appointmentManagement => const AppointmentManagementScreen(),
        receptionistQueue => const ReceptionistQueueScreen(),
        adminHome => const AdminHomeScreen(),
        _ => const SplashScreen(),
      },
    );
  }
}
