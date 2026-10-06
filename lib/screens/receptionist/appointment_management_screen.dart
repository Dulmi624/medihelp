import 'package:cloud_firestore/cloud_firestore.dart';
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

  final ValueNotifier<String> searchTextNotifier =
      ValueNotifier<String>('');

  final CollectionReference<Map<String, dynamic>> appointmentsRef =
      FirebaseFirestore.instance.collection('appointments');

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  @override
  void dispose() {
    searchController.dispose();
    searchTextNotifier.dispose();
    super.dispose();
  }

  // ============================================================
  // WALK-IN APPOINTMENT
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

  // ============================================================
  // FIRESTORE DATA
  // ============================================================

  Map<String, String> appointmentData(
    String documentId,
    Map<String, dynamic> data,
  ) {
    return {
      'id': documentId,
      'appointmentNumber':
          data['appointmentNumber']?.toString() ?? '',
      'patientId':
          data['patientId']?.toString() ?? '',
      'time':
          data['time']?.toString() ?? '',
      'patient':
          data['patientName']?.toString() ?? '',
      'nic':
          data['nic']?.toString() ?? '',
      'doctor':
          data['doctorName']?.toString() ?? '',
      'doctorId':
          data['doctorId']?.toString() ?? '',
      'department':
          data['department']?.toString() ??
              data['clinic']?.toString() ??
              '',
      'clinic':
          data['clinic']?.toString() ??
              data['department']?.toString() ??
              '',
      'contactNumber':
          data['contactNumber']?.toString() ??
              data['phone']?.toString() ??
              '',
      'email':
          data['email']?.toString() ?? '',
      'status':
          displayStatus(
        data['status']?.toString() ?? '',
      ),
      'type':
          displayType(
        data['type']?.toString() ?? '',
      ),
      'date':
          data['date']?.toString() ?? '',
    };
  }

  // ============================================================
  // DISPLAY STATUS
  // ============================================================

  String displayStatus(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
      case 'upcoming':
        return 'Upcoming';

      case 'checked_in':
      case 'checked-in':
      case 'checked in':
        return 'Checked In';

      case 'completed':
        return 'Completed';

      case 'cancelled':
      case 'canceled':
        return 'Cancelled';

      default:
        return status.isEmpty ? 'Upcoming' : status;
    }
  }

  // ============================================================
  // DISPLAY TYPE
  // ============================================================

  String displayType(String type) {
    switch (type.toLowerCase()) {
      case 'walk_in':
      case 'walk-in':
      case 'walk in':
        return 'Walk-in';

      case 'regular':
        return 'Regular';

      default:
        return type.isEmpty ? 'Regular' : type;
    }
  }

  // ============================================================
  // FILTER
  // ============================================================

  bool matchesFilter(
    Map<String, String> appointment,
  ) {
    if (selectedFilter == 'All') {
      return true;
    }

    return appointment['status'] == selectedFilter;
  }

  // ============================================================
  // SEARCH
  // ============================================================

  bool matchesSearch(
    Map<String, String> appointment,
    String searchText,
  ) {
    final text = searchText.trim().toLowerCase();

    if (text.isEmpty) {
      return true;
    }

    final patient =
        appointment['patient']?.toLowerCase() ?? '';

    final nic =
        appointment['nic']?.toLowerCase() ?? '';

    final doctor =
        appointment['doctor']?.toLowerCase() ?? '';

    return patient.contains(text) ||
        nic.contains(text) ||
        doctor.contains(text);
  }

  // ============================================================
  // OPEN APPOINTMENT DETAILS
  // ============================================================

  Future<void> openAppointmentDetails(
    Map<String, String> appointment,
  ) async {
    final appointmentId =
        appointment['id'] ?? '';

    if (appointmentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Appointment ID not found.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppointmentDetailsScreen(
          appointmentId: appointmentId,
          patientName:
              appointment['patient'] ?? '',
          nic:
              appointment['nic'] ?? '',
          doctor:
              appointment['doctor'] ?? '',
          time:
              appointment['time'] ?? '',
          department:
              appointment['department'] ?? '',
          status:
              appointment['status'] ?? 'Upcoming',
          date:
              appointment['date'] ?? '',
        ),
      ),
    );
  }

  // ============================================================
  // CHECK IN
  // ============================================================

  Future<void> checkInAppointment(
    Map<String, String> appointment,
  ) async {
    final appointmentId =
        appointment['id'] ?? '';

    if (appointmentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Appointment ID not found.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final patientName =
        appointment['patient'] ?? '';

    final appointmentTime =
        appointment['time'] ?? '';

    final appointmentDate =
        appointment['date'] ?? '';

    // ------------------------------------------------------------
    // CONFIRM
    // ------------------------------------------------------------

    final bool? confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Check In Patient',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to check in this patient?',
              ),
              const SizedBox(height: 16),
              Text(
                patientName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Appointment time: $appointmentTime',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),
              child: const Text('Check In'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    // ------------------------------------------------------------
    // LOADING
    // ------------------------------------------------------------

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // ----------------------------------------------------------
      // CHECK EXISTING QUEUE
      // ----------------------------------------------------------

      final existingQueue =
          await firestore
              .collection('queues')
              .where(
                'appointmentId',
                isEqualTo: appointmentId,
              )
              .limit(1)
              .get();

      if (existingQueue.docs.isNotEmpty) {
        await firestore
            .collection('appointments')
            .doc(appointmentId)
            .update({
          'status': 'checked_in',
          'updatedAt':
              FieldValue.serverTimestamp(),
        });

        if (!mounted) return;

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Patient is already in the queue.',
            ),
            backgroundColor: Colors.orange,
          ),
        );

        return;
      }

      // ----------------------------------------------------------
      // GET EXISTING QUEUES
      // ----------------------------------------------------------

      QuerySnapshot<Map<String, dynamic>>
          existingQueues;

      if (appointmentDate.isNotEmpty) {
        existingQueues =
            await firestore
                .collection('queues')
                .where(
                  'date',
                  isEqualTo: appointmentDate,
                )
                .get();
      } else {
        existingQueues =
            await firestore
                .collection('queues')
                .get();
      }

      // ----------------------------------------------------------
      // QUEUE NUMBER
      // ----------------------------------------------------------

      final int nextNumber =
          existingQueues.docs.length + 1;

      final String dateCode =
          queueDateCode();

      final String queueNumber =
          'OPD$dateCode-${nextNumber.toString().padLeft(3, '0')}';

      // ----------------------------------------------------------
      // CREATE QUEUE
      // ----------------------------------------------------------

      await firestore
          .collection('queues')
          .doc(queueNumber)
          .set({
        'queueNumber':
            queueNumber,

        'appointmentId':
            appointmentId,

        'appointmentNumber':
            appointment['appointmentNumber'] ?? '',

        'patientId':
            appointment['patientId'] ?? '',

        'patientName':
            appointment['patient'] ?? '',

        'nic':
            appointment['nic'] ?? '',

        'doctorId':
            appointment['doctorId'] ?? '',

        'doctorName':
            appointment['doctor'] ?? '',

        'department':
            appointment['department'] ?? '',

        'clinic':
            appointment['clinic'] ??
                appointment['department'] ??
                '',

        'date':
            appointmentDate,

        'appointmentTime':
            appointmentTime,

        'time':
            appointmentTime,

        'status':
            'waiting',

        'currentServing':
            0,

        'peopleAhead':
            existingQueues.docs.length,

        'totalInQueue':
            existingQueues.docs.length + 1,

        'estimatedMinutes':
            existingQueues.docs.length * 10,

        'notes':
            '',

        'createdAt':
            FieldValue.serverTimestamp(),

        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      // ----------------------------------------------------------
      // UPDATE APPOINTMENT
      // ----------------------------------------------------------

      await firestore
          .collection('appointments')
          .doc(appointmentId)
          .update({
        'status':
            'checked_in',

        'queueNumber':
            queueNumber,

        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      // ----------------------------------------------------------
      // SUCCESS
      // ----------------------------------------------------------

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$patientName checked in successfully.\n'
            'Queue No: $queueNumber',
          ),
          backgroundColor: Colors.green,
          duration:
              const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Check-in failed: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // QUEUE DATE
  // ============================================================

  String queueDateCode() {
    final now = DateTime.now();

    final year =
        now.year.toString();

    final month =
        now.month.toString().padLeft(2, '0');

    final day =
        now.day.toString().padLeft(2, '0');

    return '$year$month$day';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF1F7FF),

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
          crossAxisAlignment:
              CrossAxisAlignment.start,
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
            tooltip:
                'Create Walk-in Appointment',
            onPressed:
                openWalkInAppointment,
            icon: const Icon(
              Icons.add_circle_outline,
              color: Color(0xFF2563EB),
            ),
          ),
        ],
      ),

      // ==========================================================
      // FIRESTORE
      // ==========================================================

      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: appointmentsRef
            .orderBy('time')
            .snapshots(),

        builder:
            (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),
                child: Text(
                  'Error loading appointments.\n\n'
                  '${snapshot.error}',
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
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

          final appointments =
              snapshot.data!.docs.map(
            (document) {
              return appointmentData(
                document.id,
                document.data(),
              );
            },
          ).toList();

          return buildBody(
            appointments,
          );
        },
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget buildBody(
    List<Map<String, String>> appointments,
  ) {
    return SingleChildScrollView(
      padding:
          const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // ------------------------------------------------------
          // DATE
          // ------------------------------------------------------

          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),

            decoration:
                BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(10),
              border: Border.all(
                color:
                    const Color(0xFFD6E4F5),
              ),
            ),

            child: const Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color:
                      Color(0xFF3B82F6),
                  size: 19,
                ),
                SizedBox(width: 10),
                Text(
                  'Today, 06 October 2026',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w600,
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

          // ------------------------------------------------------
          // SEARCH
          // ------------------------------------------------------

          TextField(
            controller:
                searchController,

            onChanged: (value) {
              // IMPORTANT:
              // No setState here.
              // This keeps the cursor inside the search box.
              searchTextNotifier.value =
                  value;
            },

            decoration:
                InputDecoration(
              hintText:
                  'Search patient name or NIC...',

              prefixIcon:
                  const Icon(
                Icons.search,
                color:
                    Color(0xFF9CA3AF),
              ),

              filled: true,
              fillColor: Colors.white,

              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
                borderSide:
                    const BorderSide(
                  color:
                      Color(0xFFD6E4F5),
                ),
              ),

              enabledBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
                borderSide:
                    const BorderSide(
                  color:
                      Color(0xFFD6E4F5),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ------------------------------------------------------
          // FILTERS
          // ------------------------------------------------------

          SingleChildScrollView(
            scrollDirection:
                Axis.horizontal,

            child: Row(
              children: [
                filterButton('All'),
                filterButton('Upcoming'),
                filterButton('Checked In'),
                filterButton('Completed'),
                filterButton('Cancelled'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ------------------------------------------------------
          // SEARCH RESULT AREA ONLY
          // ------------------------------------------------------

          ValueListenableBuilder<String>(
            valueListenable:
                searchTextNotifier,

            builder:
                (context, searchText, child) {
              final filteredAppointments =
                  appointments.where(
                (appointment) {
                  return matchesFilter(
                        appointment,
                      ) &&
                      matchesSearch(
                        appointment,
                        searchText,
                      );
                },
              ).toList();

              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      const Text(
                        "Today's Appointments",
                        style: TextStyle(
                          color:
                              Color(0xFF1D4ED8),
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      Text(
                        '${filteredAppointments.length} appointments',
                        style:
                            const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (filteredAppointments
                      .isEmpty)
                    Container(
                      width:
                          double.infinity,

                      padding:
                          const EdgeInsets
                              .all(30),

                      decoration:
                          BoxDecoration(
                        color:
                            Colors.white,

                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),

                        border:
                            Border.all(
                          color:
                              const Color(
                            0xFFD6E4F5,
                          ),
                        ),
                      ),

                      child:
                          const Column(
                        children: [
                          Icon(
                            Icons
                                .event_busy_outlined,
                            size: 45,
                            color:
                                Colors.grey,
                          ),

                          SizedBox(
                              height: 10),

                          Text(
                            'No appointments found',
                            style:
                                TextStyle(
                              color:
                                  Colors.grey,
                              fontWeight:
                                  FontWeight
                                      .w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...filteredAppointments
                        .map(
                      (appointment) =>
                          appointmentCard(
                        appointment,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTER BUTTON
  // ============================================================

  Widget filterButton(
    String filter,
  ) {
    final selected =
        selectedFilter == filter;

    return Padding(
      padding:
          const EdgeInsets.only(
        right: 8,
      ),

      child: ChoiceChip(
        label: Text(filter),

        selected: selected,

        selectedColor:
            const Color(0xFF3B82F6),

        labelStyle: TextStyle(
          color: selected
              ? Colors.white
              : const Color(0xFF374151),
          fontWeight:
              FontWeight.w600,
        ),

        backgroundColor:
            Colors.white,

        side:
            const BorderSide(
          color:
              Color(0xFFD6E4F5),
        ),

        onSelected: (_) {
          setState(() {
            selectedFilter =
                filter;
          });
        },
      ),
    );
  }

  // ============================================================
  // APPOINTMENT CARD
  // ============================================================

  Widget appointmentCard(
    Map<String, String> appointment,
  ) {
    final status =
        appointment['status'] ??
            'Upcoming';

    final type =
        appointment['type'] ??
            'Regular';

    Color statusColor;

    if (status == 'Completed') {
      statusColor =
          Colors.green;
    } else if (status == 'Cancelled') {
      statusColor =
          Colors.red;
    } else if (status == 'Checked In') {
      statusColor =
          Colors.orange;
    } else {
      statusColor =
          const Color(0xFF3B82F6);
    }

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      padding:
          const EdgeInsets.all(14),

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(12),

        border: Border.all(
          color:
              const Color(0xFFD6E4F5),
        ),
      ),

      child: Column(
        children: [
          // ------------------------------------------------------
          // TOP
          // ------------------------------------------------------

          Row(
            children: [
              Container(
                width: 65,

                padding:
                    const EdgeInsets
                        .symmetric(
                  vertical: 10,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFEAF2FF,
                  ),

                  borderRadius:
                      BorderRadius
                          .circular(8),
                ),

                child: Text(
                  appointment['time'] ??
                      '',

                  textAlign:
                      TextAlign.center,

                  style:
                      const TextStyle(
                    color:
                        Color(0xFF2563EB),
                    fontSize: 14,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            appointment[
                                    'patient'] ??
                                '',
                            style:
                                const TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),

                        if (type ==
                            'Walk-in')
                          Container(
                            margin:
                                const EdgeInsets
                                    .only(
                              left: 8,
                            ),

                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),

                            decoration:
                                BoxDecoration(
                              color:
                                  const Color(
                                0xFFE0F2FE,
                              ),

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                10,
                              ),
                            ),

                            child:
                                const Text(
                              'WALK-IN',
                              style:
                                  TextStyle(
                                color:
                                    Color(
                                  0xFF0369A1,
                                ),
                                fontSize: 9,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(
                        height: 3),

                    Text(
                      'NIC: ${appointment['nic'] ?? ''}',
                      style:
                          const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(
                        height: 3),

                    Text(
                      appointment[
                              'doctor'] ??
                          '',
                      style:
                          const TextStyle(
                        color:
                            Color(0xFF4B5563),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () {
                  openAppointmentDetails(
                    appointment,
                  );
                },

                icon: const Icon(
                  Icons.edit_outlined,
                  color:
                      Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
            ],
          ),

          const Divider(
            height: 20,
          ),

          // ------------------------------------------------------
          // DEPARTMENT + STATUS
          // ------------------------------------------------------

          Row(
            children: [
              const Icon(
                Icons
                    .local_hospital_outlined,
                size: 16,
                color: Colors.grey,
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  appointment[
                          'department'] ??
                      '',
                  style:
                      const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),

                decoration:
                    BoxDecoration(
                  color: statusColor
                      .withOpacity(0.1),

                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),

                child: Text(
                  status,
                  style: TextStyle(
                    color:
                        statusColor,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // ------------------------------------------------------
          // CHECK IN
          // ------------------------------------------------------

          if (status == 'Upcoming') ...[
            const SizedBox(height: 12),

            SizedBox(
              width:
                  double.infinity,

              child:
                  ElevatedButton.icon(
                onPressed: () {
                  checkInAppointment(
                    appointment,
                  );
                },

                icon: const Icon(
                  Icons.login,
                  size: 18,
                ),

                label: const Text(
                  'Check In',
                ),

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(
                    0xFF2563EB,
                  ),

                  foregroundColor:
                      Colors.white,

                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 12,
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}