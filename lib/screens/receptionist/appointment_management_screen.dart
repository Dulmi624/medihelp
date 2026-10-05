import 'package:flutter/material.dart';

import 'appointment_details_screen.dart';
import 'walk_in_appointment_screen.dart';

class AppointmentManagementScreen extends StatefulWidget {
  const AppointmentManagementScreen({super.key});

  @override
  State<AppointmentManagementScreen> createState() =>
      _AppointmentManagementScreenState();
}

class _AppointmentManagementScreenState
    extends State<AppointmentManagementScreen> {
  String selectedFilter = 'All';

  final TextEditingController searchController =
      TextEditingController();

  final List<Map<String, String>> appointments = [
    {
      'time': '08:30',
      'patient': 'Sahan Perera',
      'nic': '200012345678',
      'doctor': 'Dr. N. Perera',
      'department': 'General Medicine',
      'status': 'Upcoming',
      'type': 'Regular',
    },
    {
      'time': '09:00',
      'patient': 'Kasun Rajapaksa',
      'nic': '199876543210',
      'doctor': 'Dr. K. Kumara',
      'department': 'Cardiology',
      'status': 'Upcoming',
      'type': 'Regular',
    },
    {
      'time': '09:30',
      'patient': 'Kavindi Silva',
      'nic': '200045678901',
      'doctor': 'Dr. Silva',
      'department': 'Dermatology',
      'status': 'Upcoming',
      'type': 'Regular',
    },
    {
      'time': '10:00',
      'patient': 'Nimal Fernando',
      'nic': '198765432109',
      'doctor': 'Dr. Perera',
      'department': 'Pediatrics',
      'status': 'Upcoming',
      'type': 'Regular',
    },
    {
      'time': '10:30',
      'patient': 'Ruvini Fernando',
      'nic': '200056789123',
      'doctor': 'Dr. Silva',
      'department': 'Gynecology',
      'status': 'Completed',
      'type': 'Regular',
    },
    {
      'time': '11:00',
      'patient': 'Dilinithi Perera',
      'nic': '199345678900',
      'doctor': 'Dr. Perera',
      'department': 'Pediatrics',
      'status': 'Cancelled',
      'type': 'Regular',
    },
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // OPEN WALK-IN APPOINTMENT
  // ============================================================

  Future<void> openWalkInAppointment() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WalkInAppointmentScreen(),
      ),
    );

    if (!mounted) return;

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        appointments.add({
          'time': result['time']?.toString() ?? '',
          'patient': result['patientName']?.toString() ?? '',
          'nic': result['nic']?.toString() ?? 'Walk-in Patient',
          'doctor': result['doctor']?.toString() ?? '',
          'department': result['department']?.toString() ?? '',
          'status': result['status']?.toString() ?? 'Upcoming',
          'type': result['type']?.toString() ?? 'Walk-in',
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Walk-in appointment added successfully.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String searchText =
        searchController.text.trim().toLowerCase();

    final List<Map<String, String>> filteredAppointments =
        appointments.where((appointment) {
      final bool matchesFilter =
          selectedFilter == 'All' ||
              appointment['status'] == selectedFilter;

      final bool matchesSearch =
          appointment['patient']!
                  .toLowerCase()
                  .contains(searchText) ||
              appointment['nic']!
                  .toLowerCase()
                  .contains(searchText);

      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F7FF),

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF1F2937),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appointments',
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'View and manage patient appointments',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: 'Create Walk-in Appointment',
            onPressed: openWalkInAppointment,
            icon: const Icon(
              Icons.add_circle_outline,
              color: Color(0xFF2563EB),
            ),
          ),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ======================================================
            // DATE
            // ======================================================

            Container(
              width: double.infinity,

              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),

                border: Border.all(
                  color: const Color(0xFFD6E4F5),
                ),
              ),

              child: const Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xFF3B82F6),
                    size: 19,
                  ),

                  SizedBox(width: 10),

                  Text(
                    'Today, 02 October 2026',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  Spacer(),

                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ======================================================
            // SEARCH
            // ======================================================

            TextField(
              controller: searchController,

              onChanged: (value) {
                setState(() {});
              },

              decoration: InputDecoration(
                hintText: 'Search patient name or NIC...',

                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF9CA3AF),
                ),

                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),

                  borderSide: const BorderSide(
                    color: Color(0xFFD6E4F5),
                  ),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),

                  borderSide: const BorderSide(
                    color: Color(0xFFD6E4F5),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ======================================================
            // FILTERS
            // ======================================================

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,

              child: Row(
                children: [
                  _filterButton('All'),
                  _filterButton('Upcoming'),
                  _filterButton('Completed'),
                  _filterButton('Cancelled'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ======================================================
            // HEADING
            // ======================================================

            Row(
              children: [
                const Text(
                  "Today's Appointments",

                  style: TextStyle(
                    color: Color(0xFF1D4ED8),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(),

                Text(
                  '${filteredAppointments.length} appointments',

                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ======================================================
            // APPOINTMENT LIST
            // ======================================================

            if (filteredAppointments.isEmpty)
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(30),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(12),

                  border: Border.all(
                    color: const Color(0xFFD6E4F5),
                  ),
                ),

                child: const Column(
                  children: [
                    Icon(
                      Icons.event_busy_outlined,
                      size: 45,
                      color: Colors.grey,
                    ),

                    SizedBox(height: 10),

                    Text(
                      'No appointments found',

                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...filteredAppointments.map(
                (appointment) => _appointmentCard(
                  appointment,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FILTER BUTTON
  // ============================================================

  Widget _filterButton(String filter) {
    final bool selected = selectedFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: 8),

      child: ChoiceChip(
        label: Text(filter),

        selected: selected,

        selectedColor: const Color(0xFF3B82F6),

        labelStyle: TextStyle(
          color: selected
              ? Colors.white
              : const Color(0xFF374151),

          fontWeight: FontWeight.w600,
        ),

        backgroundColor: Colors.white,

        side: const BorderSide(
          color: Color(0xFFD6E4F5),
        ),

        onSelected: (_) {
          setState(() {
            selectedFilter = filter;
          });
        },
      ),
    );
  }

  // ============================================================
  // APPOINTMENT CARD
  // ============================================================

  Widget _appointmentCard(
    Map<String, String> appointment,
  ) {
    final String status = appointment['status']!;

    final String type =
        appointment['type'] ?? 'Regular';

    Color statusColor;

    if (status == 'Completed') {
      statusColor = Colors.green;
    } else if (status == 'Cancelled') {
      statusColor = Colors.red;
    } else {
      statusColor = const Color(0xFF3B82F6);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(
          color: const Color(0xFFD6E4F5),
        ),
      ),

      child: Column(
        children: [
          // ======================================================
          // TOP ROW
          // ======================================================

          Row(
            children: [
              // TIME

              Container(
                width: 65,

                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),

                  borderRadius:
                      BorderRadius.circular(8),
                ),

                child: Text(
                  appointment['time']!,

                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // PATIENT DETAILS

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            appointment['patient']!,

                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        if (type == 'Walk-in')
                          Container(
                            margin:
                                const EdgeInsets.only(
                              left: 8,
                            ),

                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),

                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFFE0F2FE),

                              borderRadius:
                                  BorderRadius.circular(
                                10,
                              ),
                            ),

                            child: const Text(
                              'WALK-IN',

                              style: TextStyle(
                                color: Color(0xFF0369A1),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 3),

                    Text(
                      'NIC: ${appointment['nic']!}',

                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      appointment['doctor']!,

                      style: const TextStyle(
                        color: Color(0xFF4B5563),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // EDIT BUTTON
              // ==================================================

              IconButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) =>
                          AppointmentDetailsScreen(
                        patientName:
                            appointment['patient']!,

                        nic:
                            appointment['nic']!,

                        doctor:
                            appointment['doctor']!,

                        time:
                            appointment['time']!,

                        department:
                            appointment['department']!,

                        status:
                            appointment['status']!,
                      ),
                    ),
                  );

                  if (!mounted) return;

                  // ==================================================
                  // UPDATE MANAGEMENT LIST
                  // ==================================================

                  if (result != null &&
                      result is Map<String, dynamic>) {
                    setState(() {
                      appointment['patient'] =
                          result['patientName']
                                  ?.toString() ??
                              appointment['patient']!;

                      appointment['nic'] =
                          result['nic']?.toString() ??
                              appointment['nic']!;

                      appointment['doctor'] =
                          result['doctor']?.toString() ??
                              appointment['doctor']!;

                      appointment['time'] =
                          result['time']?.toString() ??
                              appointment['time']!;

                      appointment['department'] =
                          result['department']
                                  ?.toString() ??
                              appointment['department']!;

                      appointment['status'] =
                          result['status']?.toString() ??
                              appointment['status']!;
                    });

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Appointment updated successfully.',
                        ),

                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },

                icon: const Icon(
                  Icons.edit_outlined,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
            ],
          ),

          const Divider(height: 20),

          // ======================================================
          // DEPARTMENT + STATUS
          // ======================================================

          Row(
            children: [
              const Icon(
                Icons.local_hospital_outlined,
                size: 16,
                color: Colors.grey,
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  appointment['department']!,

                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),

                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),

                  borderRadius:
                      BorderRadius.circular(20),
                ),

                child: Text(
                  status,

                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}