import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../models/appointment.dart';
import '../../core/theme.dart';
import '../../services/appointment_store.dart';
import '../../services/queue_service.dart';
import '../../widgets/action_row.dart';
import '../../widgets/patient_app_bar.dart';
import '../../widgets/patient_bottom_nav.dart';

class MyAppointmentScreen extends StatefulWidget {
  const MyAppointmentScreen({super.key});

  @override
  State<MyAppointmentScreen> createState() => _MyAppointmentScreenState();
}

class _MyAppointmentScreenState extends State<MyAppointmentScreen> {
  late final Stream<Appointment?> _appointments =
      AppointmentStore.watchCurrent();
  bool _cancelling = false;
  void _showActions(BuildContext context) {
    final appointment = AppointmentStore.current;
    if (appointment == null || appointment.isCancelled) return;
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.edit_calendar_outlined,
                  color: AppColors.primary,
                ),
                title: const Text('Reschedule'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    AppRoutes.selectDateTime,
                    arguments: {
                      'doctor': appointment.doctor,
                      'existingAppointment': appointment,
                    },
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.cancel_outlined,
                  color: AppColors.danger,
                ),
                title: const Text('Cancel Appointment'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmCancel(context, appointment);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context, Appointment appointment) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel appointment?'),
        content: const Text(
          'Are you sure you want to cancel this appointment?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep appointment'),
          ),
          FilledButton(
            onPressed: () async {
              if (_cancelling) return;
              _cancelling = true;
              try {
                await QueueService().remove(appointment.number);
                AppointmentStore.cancel();
                if (!mounted || !context.mounted) return;
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text('Appointment cancelled successfully.'),
                  ),
                );
              } catch (error) {
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text(
                      error is StateError ? error.message.toString() : 'Could not cancel. Check your connection and try again.',
                    ),
                  ),
                );
              } finally {
                _cancelling = false;
              }
            },
            child: const Text('Cancel appointment'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Appointment?>(
      stream: _appointments,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _messagePage(
            'Could not load your appointment. Check your connection and permissions.',
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final appointment = snapshot.data;
        if (appointment == null) {
          return _messagePage(
            'No saved appointment. Book an appointment first.',
          );
        }
        final cancelled = appointment.isCancelled;
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: const PatientAppBar(
            title: 'My Appointment',
            subtitle: 'Your health, our priority',
            subtitleIcon: Icons.favorite,
          ),
          body: Container(
            decoration: const BoxDecoration(gradient: AppGradients.page),
            child: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 92, 20, 24),
                children: [
                  if (cancelled)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('Your appointment has been cancelled.'),
                      ),
                    )
                  else ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: AppGradients.doctorBanner,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 29,
                                    backgroundColor: AppColors.surface,
                                    child: Icon(
                                      Icons.person,
                                      color: AppColors.primary,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          appointment.doctor.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          appointment.doctor.specialization,
                                          style: const TextStyle(
                                            color: AppColors.primaryDark,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          appointment.doctor.location,
                                          style: const TextStyle(
                                            color: AppColors.mutedText,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: AppColors.onPrimary,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            _Detail(
                              icon: Icons.calendar_today_outlined,
                              text: appointment.dateLabel,
                            ),
                            _Detail(
                              icon: Icons.access_time,
                              text: appointment.time,
                            ),
                            _Detail(
                              icon: Icons.location_on_outlined,
                              text: appointment.location,
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withAlpha(22),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: AppColors.success,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Confirmed',
                                      style: TextStyle(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: AppColors.success,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ActionRow(
                      icon: Icons.people_outline,
                      title: 'View Queue Status',
                      subtitle: 'Check your current position',
                      onTap: () => Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.queueStatus,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  ActionRow(
                    icon: Icons.edit_calendar_outlined,
                    title: 'Reschedule / Cancel',
                    subtitle: 'Manage your appointment',
                    onTap: () => _showActions(context),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const PatientBottomNav(currentIndex: 1),
        );
      },
    );
  }

  Widget _messagePage(String text) => Scaffold(
    appBar: const PatientAppBar(
      title: 'My Appointment',
      subtitle: 'Your saved booking',
    ),
    body: Center(
      child: Padding(padding: const EdgeInsets.all(24), child: Text(text)),
    ),
    bottomNavigationBar: const PatientBottomNav(currentIndex: 1),
  );
}

class _Detail extends StatelessWidget {
  const _Detail({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 13),
    child: Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
