import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PatientEditScreen extends StatefulWidget {
  final String nic;

  const PatientEditScreen({
    super.key,
    required this.nic,
  });

  @override
  State<PatientEditScreen> createState() => _PatientEditScreenState();
}

class _PatientEditScreenState extends State<PatientEditScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController =
      TextEditingController();

  final TextEditingController nicController =
      TextEditingController();

  final TextEditingController dobController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController addressController =
      TextEditingController();

  final TextEditingController notesController =
      TextEditingController();

  String gender = 'Male';
  bool existingPatient = false;

  String? patientDocumentId;

  bool isLoading = true;
  bool isSaving = false;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadPatient();
  }

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

  // ============================================================
  // LOAD PATIENT
  // ============================================================

  Future<void> _loadPatient() async {
    try {
      final query = await _firestore
          .collection('patients')
          .where('nic', isEqualTo: widget.nic)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient record not found.'),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }

      final document = query.docs.first;
      final data = document.data();

      patientDocumentId = document.id;

      fullNameController.text =
          data['fullName']?.toString() ?? '';

      nicController.text =
          data['nic']?.toString() ?? widget.nic;

      dobController.text =
          data['dateOfBirth']?.toString() ?? '';

      phoneController.text =
          data['phone']?.toString() ??
              data['contactNumber']?.toString() ??
              '';

      emailController.text =
          data['email']?.toString() ?? '';

      addressController.text =
          data['address']?.toString() ?? '';

      notesController.text =
          data['notes']?.toString() ?? '';

      gender =
          data['gender']?.toString() ?? 'Male';

      existingPatient =
          data['existingPatient'] == true ||
          data['isExistingPatient'] == true;

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load patient: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // UPDATE PATIENT
  // ============================================================

  Future<void> _updatePatient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (patientDocumentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patient record not found.'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await _firestore
          .collection('patients')
          .doc(patientDocumentId)
          .update({
        'fullName': fullNameController.text.trim(),
        'nic': nicController.text.trim(),
        'dateOfBirth': dobController.text.trim(),
        'gender': gender,
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'address': addressController.text.trim(),
        'existingPatient': existingPatient,
        'notes': notesController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      await showDialog(
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
                  size: 30,
                ),
                SizedBox(width: 10),
                Text('Success'),
              ],
            ),
            content: const Text(
              'Patient details updated successfully.',
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

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update patient: $e',
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

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,

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
              'Edit Patient',
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Update patient information',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Form(
                key: _formKey,

                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      // ==================================================
                      // PERSONAL INFORMATION
                      // ==================================================

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
                              hint: 'NIC / Passport No.',
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
                              icon:
                                  Icons.calendar_today_outlined,
                              required: true,
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

                      // ==================================================
                      // CONTACT INFORMATION
                      // ==================================================

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

                      // ==================================================
                      // PATIENT STATUS
                      // ==================================================

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
                          borderRadius:
                              BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                const Color(0xFFD6E4F5),
                          ),
                        ),

                        child: Row(
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
                              activeColor:
                                  const Color(0xFF3B82F6),
                              onChanged: (value) {
                                setState(() {
                                  existingPatient =
                                      value ?? false;
                                });
                              },
                            ),

                            const Text('Yes'),

                            const SizedBox(width: 10),

                            Radio<bool>(
                              value: false,
                              groupValue: existingPatient,
                              activeColor:
                                  const Color(0xFF3B82F6),
                              onChanged: (value) {
                                setState(() {
                                  existingPatient =
                                      value ?? false;
                                });
                              },
                            ),

                            const Text('No'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      // ==================================================
                      // NOTES
                      // ==================================================

                      _sectionTitle(
                        Icons.notes_outlined,
                        'Additional Notes',
                      ),

                      const SizedBox(height: 10),

                      _field(
                        controller: notesController,
                        label: 'Notes',
                        hint:
                            'Add any additional notes...',
                        icon: Icons.description_outlined,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 25),

                      // ==================================================
                      // UPDATE BUTTON
                      // ==================================================

                      SizedBox(
                        width: double.infinity,
                        height: 52,

                        child: ElevatedButton.icon(
                          onPressed:
                              isSaving
                                  ? null
                                  : _updatePatient,

                          icon: isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.save_outlined,
                                ),

                          label: Text(
                            isSaving
                                ? 'Updating...'
                                : 'Update Patient',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            elevation: 2,

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
          activeColor:
              const Color(0xFF3B82F6),

          onChanged: (newValue) {
            setState(() {
              gender = newValue!;
            });
          },
        ),

        Text(
          value,
          style:
              const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}