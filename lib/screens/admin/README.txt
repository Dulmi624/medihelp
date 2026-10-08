Admin Firebase update

Copy all four Dart files to C:\Projects\medihelp\lib\screens\admin.
Replace the existing files together. Keep admin_reports_screen.dart unchanged.
The admin_demo_store.dart filename is retained for import compatibility, but
the file now contains AdminDataStore and reads Firestore instead of sample data.

Stop the running app, run flutter analyze, then flutter run -d emulator-5554.

Dashboard totals cover ALL appointment dates. Queue has its own date filter.
Queue dates come from the linked appointments document (appointmentId).
Department values come from saved data; current bookings use doctor specialization.
Recent Activity shows only actions made in the current Admin session.
Older incomplete records are excluded from Queue and counted in a dashboard notice.

Test:
1. Create a new patient booking for today, then sign in as Admin.
2. Check its actual patient/date/doctor in Appointments.
3. Queue: select that appointment date and department.
4. Call Next -> Called; use the consultation icon -> In Consultation;
   use the completion icon -> Completed. Appointment becomes Completed too.
5. Restart/sign in again and check statuses remain saved.
6. Cancel a different appointment from Admin; its Queue entry is deleted.

Call Next uses booking creation order, not a hospital-issued numeric queue order.
Only today's queue can be served. Confirmed waiting-time estimates are required
before displaying averages; placeholders are not treated as real estimates.
Patient screen queue-position calculations still need a shared queue algorithm.

No Firestore rules are published by these files. Client Admin checks are not
a substitute for Firestore rules. The project's existing temporary broad access
for appointments/queues must be replaced with agreed role rules before deployment.
