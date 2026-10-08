import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../models/doctor.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/step_indicator.dart';

class SelectDoctorScreen extends StatefulWidget {
  const SelectDoctorScreen({
    this.title = 'Select Doctor',
    this.showBookingSteps = true,
    super.key,
  });

  final String title;
  final bool showBookingSteps;

  @override
  State<SelectDoctorScreen> createState() =>
      _SelectDoctorScreenState();
}

class _SelectDoctorScreenState extends State<SelectDoctorScreen> {
  final _searchController = TextEditingController();

  late final Stream<QuerySnapshot<Map<String, dynamic>>>
      _doctorStream;

  String? _selectedDoctorId;
  String _specialization = 'All';

  @override
  void initState() {
    super.initState();

    _doctorStream = FirebaseFirestore.instance
        .collection('doctors')
        .where('isAvailable', isEqualTo: true)
        .snapshots();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _text(Map<String, dynamic> data, String key) {
    final value = data[key];
    return value is String ? value.trim() : '';
  }

  Doctor _toDoctor(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    return Doctor(
      id: document.id,
      name: _text(data, 'name'),
      specialization: _text(data, 'specialization'),
      location: _text(data, 'clinic'),
      experience: _text(data, 'experience'),
      rating: data['rating'] is num
          ? (data['rating'] as num).toDouble()
          : 0,
      imageUrl: data['imageUrl'] is String
          ? data['imageUrl'] as String
          : null,
    );
  }

  Widget _message(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _doctorCard(Doctor doctor) {
    final selected = _selectedDoctorId == doctor.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: selected ? AppColors.primarySoft : Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            setState(() => _selectedDoctorId = doctor.id);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  child: Icon(Icons.person_outline, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        doctor.specialization,
                        style: const TextStyle(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        doctor.location,
                        style: const TextStyle(
                          color: AppColors.mutedText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  selected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: selected
                      ? AppColors.primary
                      : AppColors.mutedText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _doctorStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load doctors. '
                  'Please check your connection and sign in again.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final allDoctors = snapshot.data!.docs
              .map(_toDoctor)
              .where(
                (doctor) =>
                    doctor.name.isNotEmpty &&
                    doctor.specialization.isNotEmpty &&
                    doctor.location.isNotEmpty,
              )
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));

          final specializations = allDoctors
              .map((doctor) => doctor.specialization)
              .where((value) => value != 'All')
              .toSet()
              .toList()
            ..sort();

          final filters = ['All', ...specializations];

          final activeFilter = filters.contains(_specialization)
              ? _specialization
              : 'All';

          final search = _searchController.text.trim().toLowerCase();

          final doctors = allDoctors.where((doctor) {
            final matchesFilter = activeFilter == 'All' ||
                doctor.specialization == activeFilter;

            final matchesSearch =
                doctor.name.toLowerCase().contains(search) ||
                doctor.specialization.toLowerCase().contains(search);

            return matchesFilter && matchesSearch;
          }).toList();

          Doctor? selectedDoctor;

          for (final doctor in doctors) {
            if (doctor.id == _selectedDoctorId) {
              selectedDoctor = doctor;
              break;
            }
          }

          final selected = selectedDoctor;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (widget.showBookingSteps)
                const StepIndicator(currentStep: 1),
              SizedBox(
                height: widget.showBookingSteps ? 26 : 8,
              ),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Search doctor or specialization',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    final filter = filters[index];

                    return ChoiceChip(
                      label: Text(filter),
                      selected: activeFilter == filter,
                      onSelected: (_) {
                        setState(() => _specialization = filter);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              if (allDoctors.isEmpty)
                _message('No available doctors at the moment.')
              else if (doctors.isEmpty)
                _message('No doctors match your search.')
              else
                ...doctors.map(_doctorCard),
              if (widget.showBookingSteps) ...[
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Next',
                  onPressed: selected == null
                      ? null
                      : () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.selectDateTime,
                            arguments: selected,
                          );
                        },
                ),
              ] else if (selected != null) ...[
                const SizedBox(height: 12),
                Card(
                  color: AppColors.primarySoft,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${selected.name} — ${selected.location}.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}