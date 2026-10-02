import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/patient_signup_screen.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/admin/admin_home_screen.dart';
import '../screens/patient/patient_home_screen.dart';
import '../screens/patient/booking_success_screen.dart';
import '../screens/patient/coming_soon_screen.dart';
import '../screens/patient/confirm_booking_screen.dart';
import '../screens/patient/my_appointment_screen.dart';
import '../screens/patient/notifications_screen.dart';
import '../screens/patient/queue_details_screen.dart';
import '../screens/patient/queue_status_screen.dart';
import '../screens/receptionist/receptionist_home_screen.dart';
import '../screens/patient/select_date_time_screen.dart';
import '../screens/patient/select_doctor_screen.dart';
import '../models/appointment.dart';
import '../models/doctor.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const patientSignUp = '/patient-sign-up';
  static const patientHome = '/patient';
  static const comingSoon = '/patient/coming-soon';
  static const selectDoctor = '/patient/select-doctor';
  static const selectDateTime = '/patient/select-date-time';
  static const confirmBooking = '/patient/confirm-booking';
  static const bookingSuccess = '/patient/booking-success';
  static const myAppointment = '/patient/appointment';
  static const queueStatus = '/patient/queue-status';
  static const queueDetails = '/patient/queue-details';
  static const notifications = '/patient/notifications';
  static const receptionistHome = '/receptionist';
  static const adminHome = '/admin';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final arguments = settings.arguments;
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => switch (settings.name) {
        splash => const SplashScreen(),
        login => const LoginScreen(),
        patientSignUp => const PatientSignUpScreen(),
        patientHome => const PatientHomeScreen(),
        comingSoon => const ComingSoonScreen(),
        selectDoctor => const SelectDoctorScreen(),
        selectDateTime => SelectDateTimeScreen(doctor: arguments is Doctor ? arguments : throw ArgumentError('Doctor is required')),
        confirmBooking => ConfirmBookingScreen(doctor: (arguments as Map)['doctor'] as Doctor, date: arguments['date'] as DateTime, time: arguments['time'] as String),
        bookingSuccess => BookingSuccessScreen(appointment: arguments is Appointment ? arguments : throw ArgumentError('Appointment is required')),
        myAppointment => const MyAppointmentScreen(),
        queueStatus => const QueueStatusScreen(),
        queueDetails => const QueueDetailsScreen(),
        notifications => NotificationsScreen(initialTab: arguments is int ? arguments : 0),
        receptionistHome => const ReceptionistHomeScreen(),
        adminHome => const AdminHomeScreen(),
        _ => const SplashScreen(),
      },
    );
  }
}