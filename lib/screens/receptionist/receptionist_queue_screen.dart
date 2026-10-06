import 'package:cloud_firestore/cloud_firestore.dart';
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
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final TextEditingController searchController =
      TextEditingController();

  String searchText = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // STATUS DISPLAY
  // ============================================================

  String displayStatus(String status) {
    switch (status.toLowerCase()) {
      case 'waiting':
        return 'Waiting';

      case 'in_consultation':
      case 'in consultation':
      case 'consultation':
        return 'In Consultation';

      case 'completed':
        return 'Completed';

      case 'skipped':
        return 'Skipped';

      case 'scheduled':
        return 'Scheduled';

      default:
        return status.isEmpty ? 'Waiting' : status;
    }
  }

  // ============================================================
  // FIRESTORE STATUS
  // ============================================================

  String firestoreStatus(String status) {
    switch (status) {
      case 'Waiting':
        return 'waiting';

      case 'In Consultation':
        return 'in_consultation';

      case 'Completed':
        return 'completed';

      case 'Skipped':
        return 'skipped';

      case 'Scheduled':
        return 'scheduled';

      default:
        return status.toLowerCase();
    }
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

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

  // ============================================================
  // CALL NEXT
  // ============================================================

  Future<void> callNext(
    String documentId,
    String patientName,
  ) async {
    try {
      await _firestore
          .collection('queues')
          .doc(documentId)
          .update({
        'status': 'in_consultation',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$patientName has been called next.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to call patient: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // OPEN QUEUE UPDATE SCREEN
  // ============================================================

  Future<void> openQueueUpdate(
    String documentId,
    Map<String, dynamic> patient,
  ) async {
    final String currentStatus =
        displayStatus(
      patient['status']?.toString() ?? '',
    );

    final String? updatedStatus =
        await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => QueueUpdateScreen(
          queueNo:
              patient['queue']?.toString() ?? '',
          patientName:
              patient['name']?.toString() ?? '',
          nic:
              patient['nic']?.toString() ?? '',
          doctor:
              patient['doctor']?.toString() ?? '',
          department:
              patient['department']?.toString() ?? '',
          appointmentTime:
              patient['time']?.toString() ?? '',
          currentStatus: currentStatus,
        ),
      ),
    );

    if (updatedStatus == null || !mounted) {
      return;
    }

    try {
      await _firestore
          .collection('queues')
          .doc(documentId)
          .update({
        'status':
            firestoreStatus(updatedStatus),
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${patient['name'] ?? 'Patient'} '
            'status updated to $updatedStatus.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update queue: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // CONVERT FIRESTORE DOCUMENT
  // ============================================================

  Map<String, dynamic> convertQueueDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    return {
      'id': document.id,

      'queue':
          data['queueNumber']?.toString() ??
          data['queue']?.toString() ??
          document.id,

      'name':
          data['patientName']?.toString() ??
          data['name']?.toString() ??
          'Unknown Patient',

      'nic':
          data['nic']?.toString() ?? '',

      'doctor':
          data['doctorName']?.toString() ??
          data['doctor']?.toString() ??
          '',

      'department':
          data['department']?.toString() ??
          data['clinic']?.toString() ??
          '',

      'time':
          data['appointmentTime']?.toString() ??
          data['time']?.toString() ??
          '',

      'status':
          displayStatus(
        data['status']?.toString() ?? '',
      ),

      'patientId':
          data['patientId']?.toString() ?? '',

      'appointmentId':
          data['appointmentId']?.toString() ?? '',
    };
  }

  // ============================================================
  // SEARCH
  // ============================================================

  bool matchesSearch(
    Map<String, dynamic> patient,
  ) {
    final search =
        searchText.trim().toLowerCase();

    if (search.isEmpty) {
      return true;
    }

    final queue =
        patient['queue']?.toString().toLowerCase() ?? '';

    final name =
        patient['name']?.toString().toLowerCase() ?? '';

    final nic =
        patient['nic']?.toString().toLowerCase() ?? '';

    final doctor =
        patient['doctor']?.toString().toLowerCase() ?? '';

    return queue.contains(search) ||
        name.contains(search) ||
        nic.contains(search) ||
        doctor.contains(search);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF1F7FF),

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black87,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Queue Management',
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            Text(
              "Manage today's patient queue",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),

      // ==========================================================
      // FIRESTORE STREAM
      // ==========================================================

      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestore
            .collection('queues')
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),
                child: Text(
                  'Error loading queue.\n\n'
                  '${snapshot.error}',
                  textAlign:
                      TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final allPatients =
              snapshot.data!.docs
                  .map(
                    convertQueueDocument,
                  )
                  .toList();

          final filteredPatients =
              allPatients
                  .where(matchesSearch)
                  .toList();

          return _buildBody(
            filteredPatients,
          );
        },
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody(
    List<Map<String, dynamic>> patients,
  ) {
    final waitingCount = patients
        .where(
          (p) =>
              p['status'] == 'Waiting',
        )
        .length;

    final consultationCount = patients
        .where(
          (p) =>
              p['status'] ==
              'In Consultation',
        )
        .length;

    final completedCount = patients
        .where(
          (p) =>
              p['status'] ==
              'Completed',
        )
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // ======================================================
          // DATE AND OPD
          // ======================================================

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(14),

              border: Border.all(
                color:
                    const Color(0xFFD6E5FF),
              ),
            ),

            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                  color: Color(0xFF3B82F6),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    'Today, ${_todayDate()}',
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w500,
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

          // ======================================================
          // STATISTICS
          // ======================================================

          Row(
            children: [
              _statCard(
                icon:
                    Icons.people_outline,
                value:
                    patients.length.toString(),
                label:
                    'Total Patients',
                iconColor:
                    Colors.blue,
              ),

              const SizedBox(width: 10),

              _statCard(
                icon:
                    Icons.access_time,
                value:
                    waitingCount.toString(),
                label:
                    'Waiting',
                iconColor:
                    Colors.orange,
              ),

              const SizedBox(width: 10),

              _statCard(
                icon:
                    Icons.medical_services_outlined,
                value:
                    consultationCount.toString(),
                label:
                    'In Consultation',
                iconColor:
                    Colors.deepPurple,
              ),

              const SizedBox(width: 10),

              _statCard(
                icon:
                    Icons.check_circle_outline,
                value:
                    completedCount.toString(),
                label:
                    'Completed',
                iconColor:
                    Colors.green,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ======================================================
          // QUEUE TITLE + SEARCH
          // ======================================================

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Queue List',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFF2563EB),
                  ),
                ),
              ),

              SizedBox(
                width: 250,

                child: TextField(
                  controller:
                      searchController,

                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },

                  decoration:
                      InputDecoration(
                    hintText:
                        'Search patient or queue no...',

                    prefixIcon:
                        const Icon(
                      Icons.search,
                    ),

                    filled: true,

                    fillColor:
                        Colors.white,

                    contentPadding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 12,
                    ),

                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),

                      borderSide:
                          const BorderSide(
                        color:
                            Color(0xFFD6E5FF),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ======================================================
          // QUEUE LIST
          // ======================================================

          if (patients.isEmpty)
            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.all(35),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(
                  14,
                ),

                border: Border.all(
                  color:
                      const Color(0xFFD6E5FF),
                ),
              ),

              child: const Column(
                children: [
                  Icon(
                    Icons.queue_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 12),

                  Text(
                    'No queue patients found',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              decoration:
                  BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(
                  14,
                ),

                border: Border.all(
                  color:
                      const Color(0xFFD6E5FF),
                ),
              ),

              child: Column(
                children: [
                  // HEADER

                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),

                    decoration:
                        const BoxDecoration(
                      color:
                          Color(0xFFF8FAFC),

                      borderRadius:
                          BorderRadius.vertical(
                        top:
                            Radius.circular(
                          14,
                        ),
                      ),
                    ),

                    child: const Row(
                      children: [
                        SizedBox(
                          width: 50,
                          child: Text(
                            '#',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),

                        SizedBox(
                          width: 80,
                          child: Text(
                            'Q NO.',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 2,
                          child: Text(
                            'PATIENT',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),

                        Expanded(
                          child: Text(
                            'TIME',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 2,
                          child: Text(
                            'STATUS',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),

                        SizedBox(
                          width: 120,
                          child: Text(
                            'ACTION',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ROWS

                  ...List.generate(
                    patients.length,
                    (index) {
                      final patient =
                          patients[index];

                      final status =
                          patient['status']
                              .toString();

                      final color =
                          statusColor(status);

                      return Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),

                        decoration:
                            BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Colors
                                  .grey
                                  .shade200,
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
                                patient[
                                        'queue']
                                    .toString(),

                                style:
                                    const TextStyle(
                                  color:
                                      Color(
                                    0xFF2563EB,
                                  ),
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ),

                            // PATIENT

                            Expanded(
                              flex: 2,

                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [
                                  Text(
                                    patient[
                                            'name']
                                        .toString(),

                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .w600,
                                    ),
                                  ),

                                  Text(
                                    patient[
                                            'doctor']
                                        .toString(),

                                    style:
                                        const TextStyle(
                                      fontSize:
                                          12,
                                      color:
                                          Colors
                                              .grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // TIME

                            Expanded(
                              child: Text(
                                patient[
                                        'time']
                                    .toString(),
                              ),
                            ),

                            // STATUS

                            Expanded(
                              flex: 2,

                              child: Align(
                                alignment:
                                    Alignment
                                        .centerLeft,

                                child:
                                    Container(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal:
                                        10,
                                    vertical:
                                        6,
                                  ),

                                  decoration:
                                      BoxDecoration(
                                    color: color
                                        .withOpacity(
                                      0.1,
                                    ),

                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      20,
                                    ),
                                  ),

                                  child: Text(
                                    status,

                                    style:
                                        TextStyle(
                                      color:
                                          color,
                                      fontSize:
                                          12,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // ACTION

                            SizedBox(
                              width: 120,

                              child:
                                  status ==
                                          'Waiting'
                                      ? ElevatedButton(
                                          onPressed:
                                              () =>
                                                  callNext(
                                            patient[
                                                    'id']
                                                .toString(),
                                            patient[
                                                    'name']
                                                .toString(),
                                          ),

                                          style:
                                              ElevatedButton
                                                  .styleFrom(
                                            backgroundColor:
                                                const Color(
                                              0xFF3B82F6,
                                            ),

                                            foregroundColor:
                                                Colors
                                                    .white,

                                            padding:
                                                const EdgeInsets
                                                    .symmetric(
                                              vertical:
                                                  10,
                                            ),
                                          ),

                                          child:
                                              const Text(
                                            'Call Next',
                                          ),
                                        )
                                      : OutlinedButton(
                                          onPressed:
                                              () =>
                                                  openQueueUpdate(
                                            patient[
                                                    'id']
                                                .toString(),
                                            patient,
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
    );
  }

  // ============================================================
  // TODAY DATE
  // ============================================================

  String _todayDate() {
    final now = DateTime.now();

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 10,
        ),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(14),

          border: Border.all(
            color:
                const Color(0xFFD6E5FF),
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
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              label,
              textAlign:
                  TextAlign.center,

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