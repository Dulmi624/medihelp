import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QueueUpdateScreen extends StatefulWidget {
  final String queueNo;
  final String patientName;
  final String nic;
  final String doctor;
  final String department;
  final String appointmentTime;
  final String currentStatus;

  const QueueUpdateScreen({
    super.key,
    required this.queueNo,
    required this.patientName,
    required this.nic,
    required this.doctor,
    required this.department,
    required this.appointmentTime,
    required this.currentStatus,
  });

  @override
  State<QueueUpdateScreen> createState() =>
      _QueueUpdateScreenState();
}

class _QueueUpdateScreenState
    extends State<QueueUpdateScreen> {
  late String status;

  late String patientName;
  late String nic;
  late String doctor;
  late String department;
  late String appointmentTime;

  bool isLoading = true;
  bool isSaving = false;

  final TextEditingController notesController =
      TextEditingController();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();

    status = widget.currentStatus;

    patientName = widget.patientName;
    nic = widget.nic;
    doctor = widget.doctor;
    department = widget.department;
    appointmentTime = widget.appointmentTime;

    _loadQueueData();
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD QUEUE DATA FROM FIREBASE
  // ============================================================

  Future<void> _loadQueueData() async {
    try {
      final document = await _firestore
          .collection('queues')
          .doc(widget.queueNo)
          .get();

      if (document.exists) {
        final data = document.data();

        if (data != null) {
          setState(() {
            patientName =
                data['patientName']?.toString() ??
                    data['name']?.toString() ??
                    patientName;

            nic =
                data['nic']?.toString() ??
                    nic;

            doctor =
                data['doctorName']?.toString() ??
                    data['doctor']?.toString() ??
                    doctor;

            department =
                data['department']?.toString() ??
                    data['clinic']?.toString() ??
                    department;

            appointmentTime =
                data['appointmentTime']?.toString() ??
                    data['time']?.toString() ??
                    appointmentTime;

            status = _displayStatus(
              data['status']?.toString() ?? status,
            );

            notesController.text =
                data['notes']?.toString() ?? '';
          });
        }
      }
    } catch (_) {
      // Keep the values received from Queue Management.
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // CHANGE STATUS
  // ============================================================

  void updateStatus(
    String newStatus,
    String message,
  ) {
    setState(() {
      status = newStatus;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color getStatusColor() {
    switch (status) {
      case 'Waiting':
        return Colors.orange;

      case 'In Consultation':
        return Colors.blue;

      case 'Completed':
        return Colors.green;

      case 'Skipped':
        return Colors.grey;

      default:
        return Colors.blue;
    }
  }

  // ============================================================
  // FIRESTORE STATUS
  // ============================================================

  String _firestoreStatus(String value) {
    switch (value) {
      case 'Waiting':
        return 'waiting';

      case 'In Consultation':
        return 'in_consultation';

      case 'Completed':
        return 'completed';

      case 'Skipped':
        return 'skipped';

      default:
        return value.toLowerCase();
    }
  }

  // ============================================================
  // DISPLAY STATUS
  // ============================================================

  String _displayStatus(String value) {
    switch (value.toLowerCase()) {
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

      default:
        return value.isEmpty ? 'Waiting' : value;
    }
  }

  // ============================================================
  // SAVE UPDATE TO FIREBASE
  // ============================================================

  Future<void> saveUpdate() async {
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    try {
      await _firestore
          .collection('queues')
          .doc(widget.queueNo)
          .update({
        'status': _firestoreStatus(status),
        'notes': notesController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Queue updated successfully.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, status);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
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
              'Queue Update',
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              'Manage patient queue progress',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    // =================================================
                    // CURRENT PATIENT
                    // =================================================

                    Container(
                      width: double.infinity,

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius:
                            BorderRadius.circular(14),

                        border: Border.all(
                          color:
                              const Color(0xFFBFDBFE),
                        ),
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          Container(
                            width: double.infinity,

                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 13,
                            ),

                            decoration:
                                const BoxDecoration(
                              color:
                                  Color(0xFFE7F1FF),

                              borderRadius:
                                  BorderRadius.only(
                                topLeft:
                                    Radius.circular(
                                  14,
                                ),
                                topRight:
                                    Radius.circular(
                                  14,
                                ),
                              ),
                            ),

                            child: const Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 18,
                                  color:
                                      Color(0xFF2563EB),
                                ),

                                SizedBox(width: 8),

                                Text(
                                  'Current Patient',
                                  style: TextStyle(
                                    color:
                                        Color(0xFF2563EB),
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          _infoRow(
                            Icons.format_list_numbered,
                            'Queue No.',
                            widget.queueNo,
                          ),

                          _infoRow(
                            Icons.person_outline,
                            'Patient Name',
                            patientName.isEmpty
                                ? 'Unknown Patient'
                                : patientName,
                          ),

                          _infoRow(
                            Icons.badge_outlined,
                            'NIC',
                            nic.isEmpty
                                ? 'Not available'
                                : nic,
                          ),

                          _infoRow(
                            Icons.medical_services_outlined,
                            'Doctor',
                            doctor.isEmpty
                                ? 'Not available'
                                : doctor,
                          ),

                          _infoRow(
                            Icons.local_hospital_outlined,
                            'OPD / Clinic',
                            department.isEmpty
                                ? 'Not available'
                                : department,
                          ),

                          _infoRow(
                            Icons.access_time,
                            'Appointment Time',
                            appointmentTime.isEmpty
                                ? 'Not available'
                                : appointmentTime,
                          ),

                          Padding(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),

                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  size: 18,
                                  color: Colors.grey,
                                ),

                                const SizedBox(width: 12),

                                const Expanded(
                                  child: Text(
                                    'Current Status',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),

                                Container(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),

                                  decoration:
                                      BoxDecoration(
                                    color:
                                        getStatusColor()
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

                                    style: TextStyle(
                                      color:
                                          getStatusColor(),
                                      fontWeight:
                                          FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =================================================
                    // QUEUE ACTIONS
                    // =================================================

                    const Text(
                      'Queue Actions',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Color(0xFF1D4ED8),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,

                      padding:
                          const EdgeInsets.all(14),

                      decoration:
                          BoxDecoration(
                        color: Colors.white,

                        borderRadius:
                            BorderRadius.circular(14),

                        border: Border.all(
                          color:
                              const Color(0xFFBFDBFE),
                        ),
                      ),

                      child: Column(
                        children: [
                          // =========================================
                          // CALL NEXT
                          // =========================================

                          SizedBox(
                            width: double.infinity,
                            height: 48,

                            child:
                                ElevatedButton.icon(
                              onPressed:
                                  status == 'Waiting'
                                      ? () {
                                          updateStatus(
                                            'In Consultation',
                                            '$patientName has been called next.',
                                          );
                                        }
                                      : null,

                              icon: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                              ),

                              label: const Text(
                                'Call Next',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),

                              style:
                                  ElevatedButton
                                      .styleFrom(
                                backgroundColor:
                                    const Color(
                                  0xFF3B82F6,
                                ),

                                disabledBackgroundColor:
                                    Colors.grey
                                        .shade300,

                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    10,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // =========================================
                          // COMPLETE
                          // =========================================

                          SizedBox(
                            width: double.infinity,
                            height: 48,

                            child:
                                OutlinedButton.icon(
                              onPressed:
                                  status ==
                                          'In Consultation'
                                      ? () {
                                          updateStatus(
                                            'Completed',
                                            '$patientName consultation completed.',
                                          );
                                        }
                                      : null,

                              icon: const Icon(
                                Icons
                                    .check_circle_outline,
                              ),

                              label: const Text(
                                'Complete',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),

                              style:
                                  OutlinedButton
                                      .styleFrom(
                                foregroundColor:
                                    Colors.green,

                                side: BorderSide(
                                  color: status ==
                                          'In Consultation'
                                      ? Colors.green
                                      : Colors
                                          .grey
                                          .shade300,
                                ),

                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    10,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // =========================================
                          // SKIP
                          // =========================================

                          SizedBox(
                            width: double.infinity,
                            height: 48,

                            child:
                                OutlinedButton.icon(
                              onPressed:
                                  status == 'Waiting'
                                      ? () {
                                          updateStatus(
                                            'Skipped',
                                            '$patientName has been skipped.',
                                          );
                                        }
                                      : null,

                              icon: const Icon(
                                Icons.skip_next,
                              ),

                              label: const Text(
                                'Skip',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),

                              style:
                                  OutlinedButton
                                      .styleFrom(
                                foregroundColor:
                                    Colors.grey
                                        .shade700,

                                side: BorderSide(
                                  color:
                                      Colors.grey
                                          .shade400,
                                ),

                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    10,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =================================================
                    // ADDITIONAL NOTES
                    // =================================================

                    const Text(
                      'Additional Notes',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Color(0xFF1D4ED8),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,

                      padding:
                          const EdgeInsets.all(14),

                      decoration:
                          BoxDecoration(
                        color: Colors.white,

                        borderRadius:
                            BorderRadius.circular(14),

                        border: Border.all(
                          color:
                              const Color(0xFFBFDBFE),
                        ),
                      ),

                      child: TextField(
                        controller:
                            notesController,

                        maxLines: 5,

                        decoration:
                            const InputDecoration(
                          hintText:
                              'Add notes about this patient...',

                          hintStyle:
                              TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),

                          filled: true,

                          fillColor:
                              Color(0xFFF8FAFC),

                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(
                              Radius.circular(10),
                            ),

                            borderSide:
                                BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =================================================
                    // SAVE UPDATE
                    // =================================================

                    SizedBox(
                      width: double.infinity,
                      height: 48,

                      child: ElevatedButton(
                        onPressed:
                            isSaving
                                ? null
                                : saveUpdate,

                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              const Color(
                            0xFF2563EB,
                          ),

                          disabledBackgroundColor:
                              Colors.grey.shade400,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              10,
                            ),
                          ),
                        ),

                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Save Update',
                                style:
                                    TextStyle(
                                  color:
                                      Colors.white,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 13,
      ),

      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),

      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}