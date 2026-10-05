import 'package:flutter/material.dart';
import 'queue_update_screen.dart';

class ReceptionistQueueScreen extends StatefulWidget {
  const ReceptionistQueueScreen({super.key});

  @override
  State<ReceptionistQueueScreen> createState() =>
      _ReceptionistQueueScreenState();
}

class _ReceptionistQueueScreenState
    extends State<ReceptionistQueueScreen> {
  final List<Map<String, dynamic>> patients = [
    {
      'queue': 'Q001',
      'name': 'Sahan Perera',
      'nic': '199876543210',
      'doctor': 'Dr. N. Perera',
      'department': 'General Medicine',
      'time': '08:30 AM',
      'status': 'In Consultation',
    },
    {
      'queue': 'Q002',
      'name': 'Nimal Fernando',
      'nic': '199865432109',
      'doctor': 'Dr. K. Kumarasinghe',
      'department': 'Cardiology',
      'time': '09:00 AM',
      'status': 'Waiting',
    },
    {
      'queue': 'Q003',
      'name': 'Kavindi Silva',
      'nic': '200012345678',
      'doctor': 'Dr. Silva',
      'department': 'Dermatology',
      'time': '09:30 AM',
      'status': 'Waiting',
    },
    {
      'queue': 'Q004',
      'name': 'Malee De Pera',
      'nic': '199934567890',
      'doctor': 'Dr. Perera',
      'department': 'General Medicine',
      'time': '10:00 AM',
      'status': 'Waiting',
    },
    {
      'queue': 'Q005',
      'name': 'Ruvini Fernando',
      'nic': '199945678901',
      'doctor': 'Dr. Silva',
      'department': 'Dermatology',
      'time': '10:30 AM',
      'status': 'Scheduled',
    },
    {
      'queue': 'Q006',
      'name': 'Kasun N.',
      'nic': '200056789012',
      'doctor': 'Dr. Kumarasinghe',
      'department': 'Cardiology',
      'time': '11:00 AM',
      'status': 'Scheduled',
    },
  ];

  Color statusColor(String status) {
    switch (status) {
      case 'In Consultation':
        return Colors.blue;

      case 'Waiting':
        return Colors.orange;

      case 'Completed':
        return Colors.green;

      case 'Skipped':
        return Colors.grey;

      case 'Scheduled':
        return Colors.blueGrey;

      default:
        return Colors.grey;
    }
  }

  void callNext(int index) {
    setState(() {
      patients[index]['status'] = 'In Consultation';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${patients[index]['name']} has been called next.',
        ),
      ),
    );
  }

  // ===============================================================
  // OPEN QUEUE UPDATE SCREEN
  // ===============================================================

  Future<void> openQueueUpdate(int index) async {
    final patient = patients[index];

    final updatedStatus = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => QueueUpdateScreen(
          queueNo: patient['queue'],
          patientName: patient['name'],
          nic: patient['nic'],
          doctor: patient['doctor'],
          department: patient['department'],
          appointmentTime: patient['time'],
          currentStatus: patient['status'],
        ),
      ),
    );

    // Update Queue Management screen after returning
    if (updatedStatus != null && mounted) {
      setState(() {
        patients[index]['status'] = updatedStatus;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${patient['name']} status updated to $updatedStatus.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final waitingCount =
        patients.where((p) => p['status'] == 'Waiting').length;

    final consultationCount = patients
        .where((p) => p['status'] == 'In Consultation')
        .length;

    final completedCount =
        patients.where((p) => p['status'] == 'Completed').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F7FF),

      // ===========================================================
      // APP BAR
      // ===========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Queue Management',
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              'Manage today\'s patient queue',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),

      // ===========================================================
      // BODY
      // ===========================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // =====================================================
            // DATE AND OPD
            // =====================================================

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFD6E5FF),
                ),
              ),

              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    color: Color(0xFF3B82F6),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Text(
                      'Today, 02 October 2026',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const Icon(
                    Icons.location_on_outlined,
                    color: Colors.grey,
                  ),

                  const SizedBox(width: 4),

                  const Text(
                    'OPD 1',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // =====================================================
            // STATISTICS
            // =====================================================

            Row(
              children: [
                _statCard(
                  icon: Icons.people_outline,
                  value: patients.length.toString(),
                  label: 'Total Patients',
                  iconColor: Colors.blue,
                ),

                const SizedBox(width: 10),

                _statCard(
                  icon: Icons.access_time,
                  value: waitingCount.toString(),
                  label: 'Waiting',
                  iconColor: Colors.orange,
                ),

                const SizedBox(width: 10),

                _statCard(
                  icon: Icons.medical_services_outlined,
                  value: consultationCount.toString(),
                  label: 'In Consultation',
                  iconColor: Colors.deepPurple,
                ),

                const SizedBox(width: 10),

                _statCard(
                  icon: Icons.check_circle_outline,
                  value: completedCount.toString(),
                  label: 'Completed',
                  iconColor: Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // =====================================================
            // QUEUE TITLE
            // =====================================================

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Queue List',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),

                SizedBox(
                  width: 250,

                  child: TextField(
                    decoration: InputDecoration(
                      hintText:
                          'Search patient or queue no...',
                      prefixIcon:
                          const Icon(Icons.search),

                      filled: true,
                      fillColor: Colors.white,

                      contentPadding:
                          const EdgeInsets.symmetric(
                        vertical: 12,
                      ),

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),

                        borderSide: const BorderSide(
                          color: Color(0xFFD6E5FF),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // =====================================================
            // QUEUE LIST
            // =====================================================

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFD6E5FF),
                ),
              ),

              child: Column(
                children: [

                  // -------------------------------------------------
                  // HEADER
                  // -------------------------------------------------

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),

                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),

                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(14),
                      ),
                    ),

                    child: const Row(
                      children: [
                        SizedBox(
                          width: 50,
                          child: Text(
                            '#',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        SizedBox(
                          width: 80,
                          child: Text(
                            'Q NO.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 2,
                          child: Text(
                            'PATIENT',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Expanded(
                          child: Text(
                            'TIME',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 2,
                          child: Text(
                            'STATUS',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        SizedBox(
                          width: 120,
                          child: Text(
                            'ACTION',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // -------------------------------------------------
                  // PATIENT ROWS
                  // -------------------------------------------------

                  ...List.generate(
                    patients.length,
                    (index) {
                      final patient = patients[index];

                      final color =
                          statusColor(patient['status']);

                      return Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),

                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Colors.grey.shade200,
                            ),
                          ),
                        ),

                        child: Row(
                          children: [

                            // NUMBER
                            SizedBox(
                              width: 50,
                              child: Text(
                                '${index + 1}',
                              ),
                            ),

                            // QUEUE NUMBER
                            SizedBox(
                              width: 80,
                              child: Text(
                                patient['queue'],
                                style: const TextStyle(
                                  color:
                                      Color(0xFF2563EB),
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),

                            // PATIENT
                            Expanded(
                              flex: 2,

                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    patient['name'],
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  ),

                                  Text(
                                    patient['doctor'],
                                    style:
                                        const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // TIME
                            Expanded(
                              child: Text(
                                patient['time'],
                              ),
                            ),

                            // STATUS
                            Expanded(
                              flex: 2,

                              child: Align(
                                alignment:
                                    Alignment.centerLeft,

                                child: Container(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),

                                  decoration:
                                      BoxDecoration(
                                    color: color
                                        .withOpacity(0.1),

                                    borderRadius:
                                        BorderRadius
                                            .circular(20),
                                  ),

                                  child: Text(
                                    patient['status'],
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 12,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // ACTION
                            SizedBox(
                              width: 120,

                              child:
                                  patient['status'] ==
                                          'Waiting'
                                      ? ElevatedButton(
                                          onPressed: () =>
                                              callNext(index),

                                          style:
                                              ElevatedButton
                                                  .styleFrom(
                                            backgroundColor:
                                                const Color(
                                              0xFF3B82F6,
                                            ),

                                            foregroundColor:
                                                Colors.white,

                                            padding:
                                                const EdgeInsets
                                                    .symmetric(
                                              vertical: 10,
                                            ),
                                          ),

                                          child:
                                              const Text(
                                            'Call Next',
                                          ),
                                        )
                                      : OutlinedButton(
                                          onPressed: () =>
                                              openQueueUpdate(
                                            index,
                                          ),

                                          child:
                                              const Text(
                                            'View',
                                          ),
                                        ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // STAT CARD
  // ===============================================================

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 10,
        ),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFD6E5FF),
          ),
        ),

        child: Column(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 25,
            ),

            const SizedBox(height: 8),

            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}