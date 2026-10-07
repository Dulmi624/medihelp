import '../models/appointment.dart';

abstract final class AppointmentStore {
  static Appointment? current;

  static void cancel() {
    current = current?.copyWith(isCancelled: true);
  }
}
