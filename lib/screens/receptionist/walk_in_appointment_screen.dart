import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WalkInAppointmentScreen extends StatefulWidget {
  const WalkInAppointmentScreen({super.key});

  @override
  State<WalkInAppointmentScreen> createState() =>
      _WalkInAppointmentScreenState();
}

class _WalkInAppointmentScreenState
    extends State<WalkInAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController patientSearchController =
      TextEditingController();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  String? selectedPatient;
  String? selectedPatientId;
  String? selectedPatientNic;
  String? selectedPatientPhone;
  String? selectedPatientEmail;

  String? selectedDoctor;
  String? selectedDepartment;
  String? selectedTime;

  DateTime selectedDate = DateTime.now();

  bool isSaving = false;

  final List<String> doctors = [
    'Dr. N. Perera',
    'Dr. K. Kumarasinghe',
    'Dr. Silva',
    'Dr. Perera',
  ];

  final List<String> departments = [
    'General Medicine',
    'Cardiology',
    'Dermatology',
    'Pediatrics',
  ];

  final List<String> timeSlots = [
    '08:30 AM',
    '09:00 AM',
    '09:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
  ];

  @override
  void dispose() {
    patientSearchController.dispose();
    super.dispose();
  }

  // ============================================================
  // SELECT DATE
  // ============================================================

  Future<void> selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 30),
      ),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String formatDate(DateTime date) {
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

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // ============================================================
  // PATIENT SEARCH
  // ============================================================

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      searchPatients(String searchText) async {
    final String text = searchText.trim();

    if (text.isEmpty) {
      return [];
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _firestore
            .collection('patients')
            .orderBy('fullName')
            .startAt([text])
            .endAt(['$text\uf8ff'])
            .limit(10)
            .get();

    return snapshot.docs;
  }

  // ============================================================
  // LOAD ALL PATIENTS
  // ============================================================

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      loadPatients() async {
    final snapshot = await _firestore
        .collection('patients')
        .orderBy('fullName')
        .limit(50)
        .get();

    return snapshot.docs;
  }

  // ============================================================
  // SELECT PATIENT
  // ============================================================

  void selectPatient(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    setState(() {
      selectedPatientId = document.id;

      selectedPatient =
          data['fullName']?.toString() ?? '';

      selectedPatientNic =
          data['nic']?.toString() ?? '';

      selectedPatientPhone =
          data['phone']?.toString() ??
              data['contactNumber']?.toString() ??
              '';

      selectedPatientEmail =
          data['email']?.toString() ?? '';

      patientSearchController.text =
          selectedPatient ?? '';
    });
  }

  // ============================================================
  // CREATE WALK-IN APPOINTMENT
  // ============================================================

  Future<void> createWalkInAppointment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedPatientId == null ||
        selectedPatient == null ||
        selectedDoctor == null ||
        selectedDepartment == null ||
        selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please complete all appointment details.',
          ),
        ),
      );

      return;
    }

    if (isSaving) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // ========================================================
      // GENERATE APPOINTMENT NUMBER
      // ========================================================

      final String appointmentNumber =
          'WALK-${DateTime.now().millisecondsSinceEpoch}';

      // ========================================================
      // CREATE FIRESTORE DOCUMENT
      // ========================================================

      final DocumentReference<Map<String, dynamic>>
          appointmentDocument =
          await _firestore.collection('appointments').add({
        'appointmentNumber': appointmentNumber,

        'patientId': selectedPatientId,

        'patientName': selectedPatient,

        'nic': selectedPatientNic ?? '',

        'doctorId': '',

        'doctorName': selectedDoctor,

        'department': selectedDepartment,

        'clinic': selectedDepartment,

        'date': formatDate(selectedDate),

        'time': selectedTime,

        'contactNumber': selectedPatientPhone ?? '',

        'email': selectedPatientEmail ?? '',

        'status': 'scheduled',

        'type': 'walk_in',

        'notes': 'Walk-in appointment',

        'createdAt': FieldValue.serverTimestamp(),

        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      // ========================================================
      // SUCCESS DIALOG
      // ========================================================

      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),

            title: const Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),

                SizedBox(width: 10),

                Text(
                  'Appointment Created',
                ),
              ],
            ),

            content: Text(
              'Walk-in appointment for '
              '$selectedPatient has been created successfully.\n\n'
              'Appointment No: $appointmentNumber',
            ),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);

                  Navigator.pop(
                    context,
                    {
                      'appointmentId':
                          appointmentDocument.id,
                      'appointmentNumber':
                          appointmentNumber,
                      'patientName':
                          selectedPatient,
                      'nic':
                          selectedPatientNic ?? '',
                      'doctor':
                          selectedDoctor,
                      'time':
                          selectedTime,
                      'department':
                          selectedDepartment,
                      'status':
                          'Upcoming',
                      'type':
                          'Walk-in',
                      'date':
                          formatDate(selectedDate),
                    },
                  );
                },

                child: const Text(
                  'Done',
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to create appointment: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // FIELD DECORATION
  // ============================================================

  InputDecoration fieldDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,

      prefixIcon: Icon(icon),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),

        borderSide: const BorderSide(
          color: Color(0xFFD1E3F8),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),

        borderSide: const BorderSide(
          color: Color(0xFF2563EB),
          width: 1.5,
        ),
      ),

      filled: true,

      fillColor: Colors.white,
    );
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
              'Walk-in Appointment',

              style: TextStyle(
                color: Color(0xFF2563EB),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              'Create an appointment for a walk-in patient',

              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                // =================================================
                // PATIENT INFORMATION
                // =================================================

                const Text(
                  'Patient Information',

                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D4ED8),
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  width: double.infinity,

                  padding:
                      const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(14),

                    border: Border.all(
                      color: const Color(
                        0xFFBFDBFE,
                      ),
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'Search / Select Patient',

                        style: TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller:
                            patientSearchController,

                        decoration:
                            InputDecoration(
                          hintText:
                              'Search patient name...',

                          prefixIcon:
                              const Icon(
                            Icons.search,
                          ),

                          filled: true,

                          fillColor:
                              const Color(
                            0xFFF8FAFC,
                          ),

                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                              10,
                            ),
                            borderSide:
                                BorderSide.none,
                          ),
                        ),

                        onChanged: (value) {
                          setState(() {});
                        },
                      ),

                      const SizedBox(height: 12),

                      FutureBuilder<
                          List<
                              QueryDocumentSnapshot<
                                  Map<String,
                                      dynamic>>>>(
                        future: patientSearchController
                                .text
                                .trim()
                                .isEmpty
                            ? loadPatients()
                            : searchPatients(
                                patientSearchController
                                    .text,
                              ),

                        builder:
                            (context, snapshot) {
                          if (snapshot
                                  .connectionState ==
                              ConnectionState
                                  .waiting) {
                            return const Padding(
                              padding:
                                  EdgeInsets.all(10),
                              child:
                                  Center(
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Text(
                              'Unable to load patients.',
                              style:
                                  const TextStyle(
                                color: Colors.red,
                              ),
                            );
                          }

                          final docs =
                              snapshot.data ?? [];

                          return DropdownButtonFormField<
                              String>(
                            value:
                                selectedPatient,

                            decoration:
                                fieldDecoration(
                              label:
                                  'Select Patient',
                              icon:
                                  Icons.person_outline,
                            ),

                            items: docs
                                .map(
                              (document) {
                                final data =
                                    document.data();

                                final name =
                                    data['fullName']
                                            ?.toString() ??
                                        '';

                                return DropdownMenuItem<
                                    String>(
                                  value: name,

                                  child:
                                      Text(name),

                                  onTap: () {
                                    selectPatient(
                                      document,
                                    );
                                  },
                                );
                              },
                            ).toList(),

                            onChanged:
                                (value) {
                              setState(() {
                                selectedPatient =
                                    value;
                              });
                            },

                            validator:
                                (value) {
                              if (value ==
                                  null) {
                                return 'Please select a patient';
                              }

                              return null;
                            },
                          );
                        },
                      ),

                      if (selectedPatientId !=
                          null) ...[
                        const SizedBox(
                          height: 12,
                        ),

                        Container(
                          width:
                              double.infinity,

                          padding:
                              const EdgeInsets.all(
                            12,
                          ),

                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFF8FAFC,
                            ),

                            borderRadius:
                                BorderRadius.circular(
                              10,
                            ),
                          ),

                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [
                              Text(
                                'NIC: ${selectedPatientNic ?? 'N/A'}',

                                style:
                                    const TextStyle(
                                  fontSize: 12,
                                  color:
                                      Colors.grey,
                                ),
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(
                                'Contact: ${selectedPatientPhone ?? 'N/A'}',

                                style:
                                    const TextStyle(
                                  fontSize: 12,
                                  color:
                                      Colors.grey,
                                ),
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(
                                'Email: ${selectedPatientEmail ?? 'N/A'}',

                                style:
                                    const TextStyle(
                                  fontSize: 12,
                                  color:
                                      Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // =================================================
                // APPOINTMENT DETAILS
                // =================================================

                const Text(
                  'Appointment Details',

                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D4ED8),
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  width: double.infinity,

                  padding:
                      const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(14),

                    border: Border.all(
                      color: const Color(
                        0xFFBFDBFE,
                      ),
                    ),
                  ),

                  child: Column(
                    children: [
                      // DATE

                      InkWell(
                        onTap: selectDate,

                        borderRadius:
                            BorderRadius.circular(
                          10,
                        ),

                        child: InputDecorator(
                          decoration:
                              fieldDecoration(
                            label:
                                'Appointment Date',
                            icon:
                                Icons.calendar_today_outlined,
                          ),

                          child: Text(
                            formatDate(
                              selectedDate,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      // DOCTOR

                      DropdownButtonFormField<
                          String>(
                        value: selectedDoctor,

                        decoration:
                            fieldDecoration(
                          label:
                              'Select Doctor',
                          icon:
                              Icons.medical_services_outlined,
                        ),

                        items: doctors
                            .map(
                          (doctor) {
                            return DropdownMenuItem<
                                String>(
                              value: doctor,

                              child:
                                  Text(doctor),
                            );
                          },
                        ).toList(),

                        onChanged: (value) {
                          setState(() {
                            selectedDoctor =
                                value;
                          });
                        },

                        validator: (value) {
                          if (value == null) {
                            return 'Please select a doctor';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      // OPD / CLINIC

                      DropdownButtonFormField<
                          String>(
                        value:
                            selectedDepartment,

                        decoration:
                            fieldDecoration(
                          label:
                              'OPD / Clinic',
                          icon:
                              Icons.local_hospital_outlined,
                        ),

                        items: departments
                            .map(
                          (department) {
                            return DropdownMenuItem<
                                String>(
                              value: department,

                              child: Text(
                                department,
                              ),
                            );
                          },
                        ).toList(),

                        onChanged: (value) {
                          setState(() {
                            selectedDepartment =
                                value;
                          });
                        },

                        validator: (value) {
                          if (value == null) {
                            return 'Please select OPD / Clinic';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      // TIME

                      DropdownButtonFormField<
                          String>(
                        value: selectedTime,

                        decoration:
                            fieldDecoration(
                          label:
                              'Appointment Time',
                          icon:
                              Icons.access_time,
                        ),

                        items: timeSlots
                            .map(
                          (time) {
                            return DropdownMenuItem<
                                String>(
                              value: time,

                              child:
                                  Text(time),
                            );
                          },
                        ).toList(),

                        onChanged: (value) {
                          setState(() {
                            selectedTime =
                                value;
                          });
                        },

                        validator: (value) {
                          if (value == null) {
                            return 'Please select appointment time';
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // =================================================
                // WALK-IN INFORMATION
                // =================================================

                Container(
                  width: double.infinity,

                  padding:
                      const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFE7F1FF),

                    borderRadius:
                        BorderRadius.circular(12),

                    border: Border.all(
                      color: const Color(
                        0xFFBFDBFE,
                      ),
                    ),
                  ),

                  child: const Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Icon(
                        Icons.info_outline,
                        color:
                            Color(0xFF2563EB),
                      ),

                      SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          'This appointment will be marked '
                          'as a walk-in appointment and added '
                          'to the receptionist appointment list.',

                          style: TextStyle(
                            color:
                                Color(0xFF1E40AF),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // =================================================
                // CREATE BUTTON
                // =================================================

                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child:
                      ElevatedButton.icon(
                    onPressed:
                        isSaving
                            ? null
                            : createWalkInAppointment,

                    icon: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color:
                                  Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons
                                .add_circle_outline,
                            color:
                                Colors.white,
                          ),

                    label: Text(
                      isSaving
                          ? 'Creating...'
                          : 'Create Walk-in Appointment',

                      style:
                          const TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(
                        0xFF2563EB,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}