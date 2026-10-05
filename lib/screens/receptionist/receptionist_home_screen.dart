import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../services/auth_service.dart';
import 'patient_registration_screen.dart';
import 'appointment_management_screen.dart';
import 'receptionist_queue_screen.dart';

class ReceptionistHomeScreen extends StatelessWidget {
  const ReceptionistHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F7FF),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,

        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 22,
              ),
            ),

            const SizedBox(width: 10),

            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MediQueue',
                  style: TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Receptionist',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: () async {
              await AuthService().signOut();

              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout),
          ),

          const SizedBox(width: 10),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // =====================================================
              // WELCOME
              // =====================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: const Color(0xFFE7F1FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFBFDBFE),
                  ),
                ),

                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Morning!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D4ED8),
                            ),
                          ),

                          SizedBox(height: 6),

                          Text(
                            "Here's today's overview.",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFBFDBFE),
                        ),
                      ),

                      child: const Icon(
                        Icons.person_outline,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // =====================================================
              // DATE
              // =====================================================

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 13,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: const Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: Color(0xFF3B82F6),
                    ),

                    SizedBox(width: 10),

                    Text(
                      'Today, 02 October 2026',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    Spacer(),

                    Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: Colors.grey,
                    ),

                    SizedBox(width: 5),

                    Text(
                      'OPD 1',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // =====================================================
              // STATISTICS
              // =====================================================

              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      icon: Icons.calendar_month,
                      number: '24',
                      label: 'Appointments',
                      iconColor: Colors.blue,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _statCard(
                      icon: Icons.access_time,
                      number: '12',
                      label: 'Waiting',
                      iconColor: Colors.orange,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _statCard(
                      icon: Icons.check_circle_outline,
                      number: '8',
                      label: 'Completed',
                      iconColor: Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // =====================================================
              // QUICK ACTIONS
              // =====================================================

              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D4ED8),
                ),
              ),

              const SizedBox(height: 12),

              // =====================================================
              // REGISTER PATIENT
              // =====================================================

              _actionCard(
                context,
                icon: Icons.person_add_alt_1,
                title: 'Register Patient',
                subtitle: 'Add a new patient to the system',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const PatientRegistrationScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              // =====================================================
              // MANAGE APPOINTMENTS
              // =====================================================

              _actionCard(
                context,
                icon: Icons.calendar_month_outlined,
                title: 'Manage Appointments',
                subtitle: 'View and manage patient appointments',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AppointmentManagementScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              // =====================================================
              // MANAGE QUEUE
              // =====================================================

              _actionCard(
                context,
                icon: Icons.people_outline,
                title: 'Manage Queue',
                subtitle:
                    'Manage patient queue and waiting status',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const ReceptionistQueueScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),

              // =====================================================
              // TODAY'S APPOINTMENTS
              // =====================================================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: [
                  const Text(
                    "Today's Appointments",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),

                  Text(
                    'View All',
                    style: TextStyle(
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _appointmentCard(
                '08:30',
                'Sahan Perera',
                'Dr. N. Perera',
                'Waiting',
                Colors.orange,
              ),

              _appointmentCard(
                '09:00',
                'Malini Silva',
                'Dr. A. Fernando',
                'Scheduled',
                Colors.blue,
              ),

              _appointmentCard(
                '09:30',
                'Kasun Rajapaksa',
                'Dr. N. Perera',
                'Completed',
                Colors.green,
              ),

              _appointmentCard(
                '10:00',
                'Thilini G.',
                'Dr. R. Dias',
                'Waiting',
                Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // STAT CARD
  // ===============================================================

  Widget _statCard({
    required IconData icon,
    required String number,
    required String label,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 8,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 22,
          ),

          const SizedBox(height: 8),

          Text(
            number,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // ACTION CARD
  // ===============================================================

  Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(15),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),

        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),

              decoration: BoxDecoration(
                color: const Color(0xFFE7F1FF),
                borderRadius: BorderRadius.circular(10),
              ),

              child: Icon(
                icon,
                color: const Color(0xFF3B82F6),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // APPOINTMENT CARD
  // ===============================================================

  Widget _appointmentCard(
    String time,
    String patient,
    String doctor,
    String status,
    Color statusColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        children: [
          SizedBox(
            width: 55,

            child: Text(
              time,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  patient,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  doctor,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),

            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),

            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}