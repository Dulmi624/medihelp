import 'package:flutter/material.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  final String patientName;
  final String nic;
  final String doctor;
  final String time;
  final String department;
  final String status;

  const AppointmentDetailsScreen({
    super.key,
    required this.patientName,
    required this.nic,
    required this.doctor,
    required this.time,
    required this.department,
    required this.status,
  });

  @override
  State<AppointmentDetailsScreen> createState() =>
      _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState
    extends State<AppointmentDetailsScreen> {
  late String selectedDoctor;
  late String selectedTime;
  late String selectedStatus;

  DateTime selectedDate = DateTime(2026, 10, 2);

  bool isEditing = false;

  final List<String> doctors = [
    'Dr. N. Perera',
    'Dr. K. Kumara',
    'Dr. Silva',
    'Dr. Perera',
  ];

  final List<String> timeSlots = [
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
  ];

  @override
  void initState() {
    super.initState();

    selectedDoctor = widget.doctor;
    selectedTime = widget.time;
    selectedStatus = widget.status;
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2027, 12, 31),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // ============================================================
  // SAVE CHANGES
  // ============================================================

  void _saveChanges() {
    // Return the updated appointment data to
    // Appointment Management screen.
    Navigator.pop(
      context,
      {
        'status': selectedStatus,
        'patientName': widget.patientName,
        'nic': widget.nic,
        'doctor': selectedDoctor,
        'time': selectedTime,
        'department': widget.department,
        'date': _formatDate(selectedDate),
      },
    );
  }

  // ============================================================
  // CANCEL APPOINTMENT
  // ============================================================

  void _cancelAppointment() {
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
                Icons.warning_amber_rounded,
                color: Colors.red,
              ),
              SizedBox(width: 10),
              Text(
                'Cancel Appointment',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to cancel this appointment?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'No',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedStatus = 'Cancelled';
                });

                // Close confirmation dialog
                Navigator.pop(dialogContext);

                // Return cancelled appointment
                // to Appointment Management screen
                Navigator.pop(
                  context,
                  {
                    'status': 'Cancelled',
                    'patientName': widget.patientName,
                    'nic': widget.nic,
                    'doctor': selectedDoctor,
                    'time': selectedTime,
                    'department': widget.department,
                    'date': _formatDate(selectedDate),
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Yes, Cancel',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime date) {
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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F7FF),

      // ========================================================
      // APP BAR
      // ========================================================

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
              'Appointment Details',
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'View and manage appointment information',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // PATIENT INFORMATION
            // ==================================================

            _sectionTitle(
              Icons.person_outline,
              'Patient Information',
            ),

            _whiteCard(
              child: Column(
                children: [
                  _infoRow(
                    Icons.person_outline,
                    'Full Name',
                    widget.patientName,
                  ),

                  _divider(),

                  _infoRow(
                    Icons.badge_outlined,
                    'NIC / Passport No.',
                    widget.nic,
                  ),

                  _divider(),

                  _infoRow(
                    Icons.phone_outlined,
                    'Contact Number',
                    '077 123 4567',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // ==================================================
            // APPOINTMENT INFORMATION
            // ==================================================

            _sectionTitle(
              Icons.calendar_month_outlined,
              'Appointment Information',
            ),

            _whiteCard(
              child: Column(
                children: [
                  // DATE
                  _infoRow(
                    Icons.calendar_today_outlined,
                    'Date',
                    _formatDate(selectedDate),
                  ),

                  _divider(),

                  // TIME
                  _infoRow(
                    Icons.access_time_outlined,
                    'Time',
                    selectedTime,
                  ),

                  _divider(),

                  // DOCTOR
                  _infoRow(
                    Icons.person_outline,
                    'Doctor',
                    selectedDoctor,
                  ),

                  _divider(),

                  // DEPARTMENT
                  _infoRow(
                    Icons.local_hospital_outlined,
                    'OPD / Clinic',
                    widget.department,
                  ),

                  _divider(),

                  // STATUS
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.sell_outlined,
                          color: Colors.grey,
                          size: 22,
                        ),

                        const SizedBox(width: 16),

                        const Expanded(
                          child: Text(
                            'Status',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),

                        _statusBadge(selectedStatus),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // ==================================================
            // ADDITIONAL NOTES
            // ==================================================

            _sectionTitle(
              Icons.description_outlined,
              'Additional Notes',
            ),

            _whiteCard(
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 8,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'No additional notes...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ==================================================
            // EDIT SECTION
            // ==================================================

            if (isEditing) ...[
              _sectionTitle(
                Icons.edit_calendar_outlined,
                'Edit / Reschedule',
              ),

              _whiteCard(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Appointment Date',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),

                    const SizedBox(height: 8),

                    InkWell(
                      onTap: _selectDate,
                      child: Container(
                        width: double.infinity,

                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(10),

                          border: Border.all(
                            color: const Color(0xFFD6E4F5),
                          ),
                        ),

                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: Color(0xFF3B82F6),
                            ),

                            const SizedBox(width: 12),

                            Text(
                              _formatDate(selectedDate),
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),

                            const Spacer(),

                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Doctor',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),

                    const SizedBox(height: 8),

                    DropdownButtonFormField<String>(
                      value: selectedDoctor,

                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: Color(0xFF3B82F6),
                        ),

                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                      ),

                      items: doctors.map(
                        (doctor) {
                          return DropdownMenuItem<String>(
                            value: doctor,
                            child: Text(doctor),
                          );
                        },
                      ).toList(),

                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedDoctor = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Appointment Time',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,

                      children: timeSlots.map(
                        (time) {
                          final bool selected =
                              selectedTime == time;

                          return ChoiceChip(
                            label: Text(time),

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

                            side: const BorderSide(
                              color: Color(0xFFD6E4F5),
                            ),

                            onSelected: (_) {
                              setState(() {
                                selectedTime = time;
                              });
                            },
                          );
                        },
                      ).toList(),
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // SAVE
                    // ==================================================

                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton.icon(
                        onPressed: _saveChanges,

                        icon: const Icon(
                          Icons.check,
                        ),

                        label: const Text(
                          'Save Changes',
                        ),

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF3B82F6),

                          foregroundColor:
                              Colors.white,

                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 15,
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

                    // ==================================================
                    // CLOSE EDIT
                    // ==================================================

                    SizedBox(
                      width: double.infinity,

                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            isEditing = false;
                          });
                        },

                        child: const Text(
                          'Close Edit',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],

            // ==================================================
            // ACTION BUTTONS
            // ==================================================

            if (!isEditing)
              Row(
                children: [
                  // EDIT / RESCHEDULE

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          isEditing = true;
                        });
                      },

                      icon: const Icon(
                        Icons.edit_calendar_outlined,
                        size: 18,
                      ),

                      label: const Text(
                        'Edit / Reschedule',
                      ),

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF3B82F6),

                        foregroundColor:
                            Colors.white,

                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 15,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // CANCEL

                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          selectedStatus == 'Cancelled'
                              ? null
                              : _cancelAppointment,

                      icon: const Icon(
                        Icons.close,
                        color: Colors.red,
                      ),

                      label: const Text(
                        'Cancel Appointment',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),

                      style:
                          OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.red,
                        ),

                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 15,
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

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
    IconData icon,
    String title,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
        left: 2,
      ),

      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF2563EB),
            size: 22,
          ),

          const SizedBox(width: 10),

          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF2563EB),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WHITE CARD
  // ============================================================

  Widget _whiteCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 4,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(
          color: const Color(0xFFD6E4F5),
        ),
      ),

      child: child,
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
      ),

      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey,
            size: 22,
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,

              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _divider() {
    return const Divider(
      height: 1,
      color: Color(0xFFE5E7EB),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _statusBadge(String status) {
    Color color;

    if (status == 'Cancelled') {
      color = Colors.red;
    } else if (status == 'Completed') {
      color = Colors.green;
    } else {
      color = const Color(0xFF3B82F6);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),

      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        status,

        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}