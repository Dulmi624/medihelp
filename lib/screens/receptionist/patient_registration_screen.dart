import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'patient_edit_screen.dart';

class PatientRegistrationScreen extends StatefulWidget {
  const PatientRegistrationScreen({super.key});

  @override
  State<PatientRegistrationScreen> createState() =>
      _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState
    extends State<PatientRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController nicController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  String gender = 'Male';
  bool existingPatient = false;
  bool isSaving = false;
  bool isSearchingPatient = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    fullNameController.dispose();
    nicController.dispose();
    dobController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F7FF),

      // ============================================================
      // APP BAR
      // ============================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF1F2937),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patient Registration',
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Add new patient to the system',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),

      // ============================================================
      // BODY
      // ============================================================

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ============================================================
                // PERSONAL INFORMATION
                // ============================================================

                _sectionTitle(
                  Icons.person_outline,
                  'Personal Information',
                ),

                const SizedBox(height: 10),

                _field(
                  controller: fullNameController,
                  label: 'Full Name',
                  hint: "Enter patient's full name",
                  icon: Icons.person_outline,
                  required: true,
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _field(
                        controller: nicController,
                        label: 'NIC / Passport No.',
                        hint: 'e.g. 200012345678',
                        icon: Icons.badge_outlined,
                        required: true,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _field(
                        controller: dobController,
                        label: 'Date of Birth',
                        hint: 'DD/MM/YYYY',
                        icon: Icons.calendar_today_outlined,
                        required: true,
                        readOnly: true,
                        onTap: _selectDateOfBirth,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                const Text(
                  'Gender',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    _genderOption('Male'),
                    const SizedBox(width: 20),
                    _genderOption('Female'),
                    const SizedBox(width: 20),
                    _genderOption('Other'),
                  ],
                ),

                const SizedBox(height: 22),

                // ============================================================
                // CONTACT INFORMATION
                // ============================================================

                _sectionTitle(
                  Icons.contact_phone_outlined,
                  'Contact Information',
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: _field(
                        controller: phoneController,
                        label: 'Contact Number',
                        hint: '077 XXX XXXX',
                        icon: Icons.phone_outlined,
                        required: true,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _field(
                        controller: emailController,
                        label: 'Email',
                        hint: 'Email address',
                        icon: Icons.email_outlined,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                _field(
                  controller: addressController,
                  label: 'Address',
                  hint: 'Enter full address',
                  icon: Icons.location_on_outlined,
                  required: true,
                  maxLines: 2,
                ),

                const SizedBox(height: 22),

                // ============================================================
                // PATIENT STATUS
                // ============================================================

                _sectionTitle(
                  Icons.people_outline,
                  'Patient Status',
                ),

                const SizedBox(height: 10),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFD6E4F5),
                    ),
                  ),
                  child: Column(
                    children: [

                      Row(
                        children: [
                          const Text(
                            'Existing Patient',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const Spacer(),

                          Radio<bool>(
                            value: true,
                            groupValue: existingPatient,
                            activeColor: const Color(0xFF3B82F6),
                            onChanged: (value) {
                              setState(() {
                                existingPatient = value ?? false;
                              });
                            },
                          ),

                          const Text('Yes'),

                          const SizedBox(width: 10),

                          Radio<bool>(
                            value: false,
                            groupValue: existingPatient,
                            activeColor: const Color(0xFF3B82F6),
                            onChanged: (value) {
                              setState(() {
                                existingPatient = value ?? false;
                              });
                            },
                          ),

                          const Text('No'),
                        ],
                      ),

                      // ========================================================
                      // FIND & EDIT EXISTING PATIENT
                      // ========================================================

                      if (existingPatient) ...[
                        const SizedBox(height: 10),

                        const Divider(),

                        const SizedBox(height: 8),

                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: OutlinedButton.icon(
                            onPressed: isSearchingPatient
                                ? null
                                : _findAndEditPatient,
                            icon: isSearchingPatient
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.edit_outlined,
                                  ),
                            label: Text(
                              isSearchingPatient
                                  ? 'Searching...'
                                  : 'Find & Edit Existing Patient',
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  const Color(0xFF2563EB),
                              side: const BorderSide(
                                color: Color(0xFF3B82F6),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ============================================================
                // ADDITIONAL NOTES
                // ============================================================

                _sectionTitle(
                  Icons.notes_outlined,
                  'Additional Notes',
                ),

                const SizedBox(height: 10),

                _field(
                  controller: notesController,
                  label: 'Notes',
                  hint: 'Add any additional notes...',
                  icon: Icons.description_outlined,
                  maxLines: 3,
                ),

                const SizedBox(height: 25),

                // ============================================================
                // BUTTONS
                // ============================================================

                Row(
                  children: [

                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed:
                              isSaving ? null : _registerPatient,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Register Patient',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed:
                              isSaving ? null : _clearForm,
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                const Color(0xFF374151),
                            side: const BorderSide(
                              color: Color(0xFFD1D5DB),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Clear'),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
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
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF2563EB),
          size: 20,
        ),

        const SizedBox(width: 8),

        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1D4ED8),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            children: required
                ? const [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ]
                : null,
          ),
        ),

        const SizedBox(height: 6),

        TextFormField(
          controller: controller,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,

          validator: required
              ? (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Required';
                  }

                  return null;
                }
              : null,

          decoration: InputDecoration(
            hintText: hint,

            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 13,
            ),

            prefixIcon: Icon(
              icon,
              size: 19,
              color: const Color(0xFF9CA3AF),
            ),

            filled: true,
            fillColor: Colors.white,

            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),

            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFD6E4F5),
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFD6E4F5),
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF3B82F6),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // GENDER
  // ============================================================

  Widget _genderOption(String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [

        Radio<String>(
          value: value,
          groupValue: gender,
          activeColor: const Color(0xFF3B82F6),
          onChanged: (newValue) {
            setState(() {
              gender = newValue!;
            });
          },
        ),

        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DATE OF BIRTH - CALENDAR
  // ============================================================

  Future<void> _selectDateOfBirth() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,

      initialDate: DateTime(2000),

      firstDate: DateTime(1900),

      lastDate: DateTime.now(),

      helpText: 'Select Date of Birth',

      cancelText: 'Cancel',

      confirmText: 'Select',

      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B82F6),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1F2937),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final day =
          pickedDate.day.toString().padLeft(2, '0');

      final month =
          pickedDate.month.toString().padLeft(2, '0');

      final year =
          pickedDate.year.toString();

      setState(() {
        dobController.text =
            '$day/$month/$year';
      });
    }
  }

  // ============================================================
  // FIND & EDIT EXISTING PATIENT
  // ============================================================

  Future<void> _findAndEditPatient() async {
    final nic = nicController.text.trim();

    if (nic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter the patient NIC / Passport number first.',
          ),
          backgroundColor: Colors.orange,
        ),
      );

      return;
    }

    setState(() {
      isSearchingPatient = true;
    });

    try {
      final result = await _firestore
          .collection('patients')
          .where(
            'nic',
            isEqualTo: nic,
          )
          .limit(1)
          .get();

      if (!mounted) return;

      setState(() {
        isSearchingPatient = false;
      });

      if (result.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No patient found with this NIC / Passport number.',
            ),
            backgroundColor: Colors.orange,
          ),
        );

        return;
      }

      final updated = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PatientEditScreen(
            nic: nic,
          ),
        ),
      );

      if (!mounted) return;

      if (updated == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Patient details updated successfully.',
            ),
            backgroundColor: Colors.green,
          ),
        );

        _clearForm();
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSearchingPatient = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to find patient: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // REGISTER PATIENT - FIRESTORE
  // ============================================================

  Future<void> _registerPatient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // Check whether this NIC is already registered.
      final existingPatientQuery = await _firestore
          .collection('patients')
          .where(
            'nic',
            isEqualTo: nicController.text.trim(),
          )
          .limit(1)
          .get();

      if (existingPatientQuery.docs.isNotEmpty) {
        if (!mounted) return;

        setState(() {
          isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'A patient with this NIC / Passport number already exists.',
            ),
            backgroundColor: Colors.orange,
          ),
        );

        return;
      }

      // Create patient document.
      await _firestore.collection('patients').add({
        'fullName':
            fullNameController.text.trim(),

        'nic':
            nicController.text.trim(),

        'dateOfBirth':
            dobController.text.trim(),

        'gender':
            gender,

        'phone':
            phoneController.text.trim(),

        'email':
            emailController.text.trim(),

        'address':
            addressController.text.trim(),

        'existingPatient':
            existingPatient,

        'notes':
            notesController.text.trim(),

        'createdAt':
            FieldValue.serverTimestamp(),

        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      // ==========================================================
      // SUCCESS DIALOG
      // ==========================================================

      await showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(16),
            ),

            title: const Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 30,
                ),

                SizedBox(width: 10),

                Text('Success'),
              ],
            ),

            content: Text(
              '${fullNameController.text.trim()} has been registered successfully.',
            ),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },

                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );

      // Clear form after successful registration.
      _clearForm();

    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to register patient: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // CLEAR FORM
  // ============================================================

  void _clearForm() {
    fullNameController.clear();
    nicController.clear();
    dobController.clear();
    phoneController.clear();
    emailController.clear();
    addressController.clear();
    notesController.clear();

    setState(() {
      gender = 'Male';
      existingPatient = false;
    });
  }
}