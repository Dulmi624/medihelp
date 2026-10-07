import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../models/doctor.dart';
import '../../services/dummy_data.dart';
import '../../widgets/doctor_card.dart';
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
  State<SelectDoctorScreen> createState() => _SelectDoctorScreenState();
}

class _SelectDoctorScreenState extends State<SelectDoctorScreen> {
  Doctor? _selectedDoctor;
  String _specialization = 'All';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doctors = DummyData.doctors
        .where(
          (doctor) =>
              (_specialization == 'All' ||
                  doctor.specialization == _specialization) &&
              doctor.name.toLowerCase().contains(
                _searchController.text.toLowerCase(),
              ),
        )
        .toList();
    const filters = [
      'All',
      'General Medicine',
      'Pediatrician',
      'Dermatologist',
      'Cardiology',
    ];
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (widget.showBookingSteps) const StepIndicator(currentStep: 1),
          SizedBox(height: widget.showBookingSteps ? 26 : 8),
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Search doctor',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, index) => ChoiceChip(
                label: Text(filters[index]),
                selected: _specialization == filters[index],
                onSelected: (_) =>
                    setState(() => _specialization = filters[index]),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...doctors.map(
            (doctor) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DoctorCard(
                doctor: doctor,
                selected: _selectedDoctor?.id == doctor.id,
                onTap: () => setState(() => _selectedDoctor = doctor),
              ),
            ),
          ),
          if (widget.showBookingSteps) ...[
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Next',
              onPressed: _selectedDoctor == null
                  ? null
                  : () => Navigator.pushNamed(
                      context,
                      AppRoutes.selectDateTime,
                      arguments: _selectedDoctor,
                    ),
            ),
          ] else if (_selectedDoctor != null) ...[
            const SizedBox(height: 12),
            Card(
              color: AppColors.primarySoft,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${_selectedDoctor!.name} is available at ${_selectedDoctor!.location}.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
