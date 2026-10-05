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

  String? selectedPatient;
  String? selectedDoctor;
  String? selectedDepartment;
  String? selectedTime;

  DateTime selectedDate = DateTime.now();

  final List<String> patients = [
    'Sahan Perera',
    'Nimal Fernando',
    'Kavindi Silva',
    'Malee De Pera',
    'Ruvini Fernando',
    'Kasun N.',
  ];

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

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  void createWalkInAppointment() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedPatient == null ||
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

    // Create appointment data to send back
    // to Appointment Management screen.
    final Map<String, dynamic> newAppointment = {
      'patientName': selectedPatient!,
      'nic': 'Walk-in Patient',
      'doctor': selectedDoctor!,
      'time': selectedTime!,
      'department': selectedDepartment!,
      'status': 'Upcoming',
      'type': 'Walk-in',
      'date': formatDate(selectedDate),
    };

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              SizedBox(width: 10),
              Text('Appointment Created'),
            ],
          ),
          content: Text(
            'Walk-in appointment for $selectedPatient '
            'has been created successfully.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Close success dialog
                Navigator.pop(dialogContext);

                // Return appointment data
                // to Appointment Management screen.
                Navigator.pop(
                  context,
                  newAppointment,
                );
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F7FF),

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

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // =========================================================
                // PATIENT INFORMATION
                // =========================================================

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
                  padding: const EdgeInsets.all(16),

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

                      const Text(
                        'Search / Select Patient',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller:
                            patientSearchController,

                        decoration: InputDecoration(
                          hintText:
                              'Search patient name...',
                          prefixIcon:
                              const Icon(Icons.search),

                          filled: true,
                          fillColor:
                              const Color(0xFFF8FAFC),

                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10),
                            borderSide:
                                BorderSide.none,
                          ),
                        ),

                        onChanged: (value) {
                          setState(() {});
                        },
                      ),

                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: selectedPatient,

                        decoration:
                            fieldDecoration(
                          label: 'Select Patient',
                          icon:
                              Icons.person_outline,
                        ),

                        items: patients
                            .where(
                              (patient) => patient
                                  .toLowerCase()
                                  .contains(
                                    patientSearchController
                                        .text
                                        .toLowerCase(),
                                  ),
                            )
                            .map(
                              (patient) =>
                                  DropdownMenuItem<String>(
                                value: patient,
                                child: Text(patient),
                              ),
                            )
                            .toList(),

                        onChanged: (value) {
                          setState(() {
                            selectedPatient = value;
                          });
                        },

                        validator: (value) {
                          if (value == null) {
                            return 'Please select a patient';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // =========================================================
                // APPOINTMENT DETAILS
                // =========================================================

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
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFBFDBFE),
                    ),
                  ),

                  child: Column(
                    children: [

                      // ===================================================
                      // DATE
                      // ===================================================

                      InkWell(
                        onTap: selectDate,
                        borderRadius:
                            BorderRadius.circular(10),

                        child: InputDecorator(
                          decoration:
                              fieldDecoration(
                            label: 'Appointment Date',
                            icon:
                                Icons.calendar_today_outlined,
                          ),

                          child: Text(
                            formatDate(selectedDate),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ===================================================
                      // DOCTOR
                      // ===================================================

                      DropdownButtonFormField<String>(
                        value: selectedDoctor,

                        decoration:
                            fieldDecoration(
                          label: 'Select Doctor',
                          icon:
                              Icons.medical_services_outlined,
                        ),

                        items: doctors
                            .map(
                              (doctor) =>
                                  DropdownMenuItem<String>(
                                value: doctor,
                                child: Text(doctor),
                              ),
                            )
                            .toList(),

                        onChanged: (value) {
                          setState(() {
                            selectedDoctor = value;
                          });
                        },

                        validator: (value) {
                          if (value == null) {
                            return 'Please select a doctor';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 14),

                      // ===================================================
                      // OPD / CLINIC
                      // ===================================================

                      DropdownButtonFormField<String>(
                        value: selectedDepartment,

                        decoration:
                            fieldDecoration(
                          label: 'OPD / Clinic',
                          icon:
                              Icons.local_hospital_outlined,
                        ),

                        items: departments
                            .map(
                              (department) =>
                                  DropdownMenuItem<String>(
                                value: department,
                                child:
                                    Text(department),
                              ),
                            )
                            .toList(),

                        onChanged: (value) {
                          setState(() {
                            selectedDepartment = value;
                          });
                        },

                        validator: (value) {
                          if (value == null) {
                            return 'Please select OPD / Clinic';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 14),

                      // ===================================================
                      // TIME
                      // ===================================================

                      DropdownButtonFormField<String>(
                        value: selectedTime,

                        decoration:
                            fieldDecoration(
                          label: 'Appointment Time',
                          icon:
                              Icons.access_time,
                        ),

                        items: timeSlots
                            .map(
                              (time) =>
                                  DropdownMenuItem<String>(
                                value: time,
                                child: Text(time),
                              ),
                            )
                            .toList(),

                        onChanged: (value) {
                          setState(() {
                            selectedTime = value;
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

                // =========================================================
                // WALK-IN INFORMATION
                // =========================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F1FF),
                    borderRadius:
                        BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFBFDBFE),
                    ),
                  ),

                  child: const Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Icon(
                        Icons.info_outline,
                        color: Color(0xFF2563EB),
                      ),

                      SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          'This appointment will be marked '
                          'as a walk-in appointment and added '
                          'to the receptionist appointment list.',

                          style: TextStyle(
                            color: Color(0xFF1E40AF),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // =========================================================
                // CREATE BUTTON
                // =========================================================

                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton.icon(
                    onPressed:
                        createWalkInAppointment,

                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                    ),

                    label: const Text(
                      'Create Walk-in Appointment',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

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