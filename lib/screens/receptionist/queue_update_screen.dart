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
  State<QueueUpdateScreen> createState() => _QueueUpdateScreenState();
}

class _QueueUpdateScreenState extends State<QueueUpdateScreen> {
  late String status;

  final TextEditingController notesController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    status = widget.currentStatus;
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  // ===============================================================
  // UPDATE STATUS
  // ===============================================================

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

  // ===============================================================
  // STATUS COLOR
  // ===============================================================

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

  // ===============================================================
  // SAVE AND RETURN TO QUEUE MANAGEMENT
  // ===============================================================

  void saveUpdate() {
    Navigator.pop(
      context,
      status,
    );
  }

  @override
  Widget build(BuildContext context) {
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

          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),

      // ===========================================================
      // BODY
      // ===========================================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              // =====================================================
              // CURRENT PATIENT
              // =====================================================

              Container(
                width: double.infinity,

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),

                  border: Border.all(
                    color: const Color(0xFFBFDBFE),
                  ),
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    // -------------------------------------------------
                    // CURRENT PATIENT HEADER
                    // -------------------------------------------------

                    Container(
                      width: double.infinity,

                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),

                      decoration: const BoxDecoration(
                        color: Color(0xFFE7F1FF),

                        borderRadius:
                            BorderRadius.only(
                          topLeft:
                              Radius.circular(14),
                          topRight:
                              Radius.circular(14),
                        ),
                      ),

                      child: const Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 18,
                            color: Color(0xFF2563EB),
                          ),

                          SizedBox(width: 8),

                          Text(
                            'Current Patient',
                            style: TextStyle(
                              color: Color(0xFF2563EB),
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // -------------------------------------------------
                    // QUEUE NUMBER
                    // -------------------------------------------------

                    _infoRow(
                      Icons.format_list_numbered,
                      'Queue No.',
                      widget.queueNo,
                    ),

                    // -------------------------------------------------
                    // PATIENT NAME
                    // -------------------------------------------------

                    _infoRow(
                      Icons.person_outline,
                      'Patient Name',
                      widget.patientName,
                    ),

                    // -------------------------------------------------
                    // NIC
                    // -------------------------------------------------

                    _infoRow(
                      Icons.badge_outlined,
                      'NIC',
                      widget.nic,
                    ),

                    // -------------------------------------------------
                    // DOCTOR
                    // -------------------------------------------------

                    _infoRow(
                      Icons.medical_services_outlined,
                      'Doctor',
                      widget.doctor,
                    ),

                    // -------------------------------------------------
                    // DEPARTMENT
                    // -------------------------------------------------

                    _infoRow(
                      Icons.local_hospital_outlined,
                      'OPD / Clinic',
                      widget.department,
                    ),

                    // -------------------------------------------------
                    // TIME
                    // -------------------------------------------------

                    _infoRow(
                      Icons.access_time,
                      'Appointment Time',
                      widget.appointmentTime,
                    ),

                    // -------------------------------------------------
                    // CURRENT STATUS
                    // -------------------------------------------------

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
                                const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),

                            decoration: BoxDecoration(
                              color: getStatusColor()
                                  .withOpacity(0.1),

                              borderRadius:
                                  BorderRadius.circular(20),
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

              // =====================================================
              // QUEUE ACTIONS
              // =====================================================

              const Text(
                'Queue Actions',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D4ED8),
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(14),

                  border: Border.all(
                    color: const Color(0xFFBFDBFE),
                  ),
                ),

                child: Column(
                  children: [

                    // =================================================
                    // CALL NEXT
                    // =================================================

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
                                      '${widget.patientName} has been called next.',
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
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF3B82F6),

                          disabledBackgroundColor:
                              Colors.grey.shade300,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // =================================================
                    // COMPLETE
                    // =================================================

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
                                      '${widget.patientName} consultation completed.',
                                    );
                                  }
                                : null,

                        icon: const Icon(
                          Icons.check_circle_outline,
                        ),

                        label: const Text(
                          'Complete',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),

                        style:
                            OutlinedButton.styleFrom(
                          foregroundColor:
                              Colors.green,

                          side: BorderSide(
                            color: status ==
                                    'In Consultation'
                                ? Colors.green
                                : Colors.grey.shade300,
                          ),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // =================================================
                    // SKIP
                    // =================================================

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
                                      '${widget.patientName} has been skipped.',
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
                            OutlinedButton.styleFrom(
                          foregroundColor:
                              Colors.grey.shade700,

                          side: BorderSide(
                            color:
                                Colors.grey.shade400,
                          ),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // =====================================================
              // ADDITIONAL NOTES
              // =====================================================

              const Text(
                'Additional Notes',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D4ED8),
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(14),

                  border: Border.all(
                    color: const Color(0xFFBFDBFE),
                  ),
                ),

                child: TextField(
                  controller: notesController,

                  maxLines: 5,

                  decoration: InputDecoration(
                    hintText:
                        'Add notes about this patient...',

                    hintStyle:
                        const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),

                    filled: true,

                    fillColor:
                        const Color(0xFFF8FAFC),

                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(10),

                      borderSide:
                          BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // =====================================================
              // SAVE UPDATE
              // =====================================================

              SizedBox(
                width: double.infinity,
                height: 48,

                child: ElevatedButton(
                  onPressed: saveUpdate,

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF2563EB),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),

                  child: const Text(
                    'Save Update',

                    style: TextStyle(
                      color: Colors.white,
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

  // ===============================================================
  // INFO ROW
  // ===============================================================

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

          Text(
            value,

            style: const TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}