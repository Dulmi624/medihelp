import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../models/doctor.dart';
import '../../services/dummy_data.dart';
import '../../widgets/doctor_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/step_indicator.dart';

class SelectDoctorScreen extends StatefulWidget {
  const SelectDoctorScreen({super.key});

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
    final doctors = DummyData.doctors.where((doctor) => (_specialization == 'All' || doctor.specialization == _specialization) && doctor.name.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
    const filters = ['All', 'General Physician', 'Pediatrician', 'Dermatologist', 'Cardiology'];
    return Scaffold(appBar: AppBar(title: const Text('Select Doctor')), body: ListView(padding: const EdgeInsets.all(20), children: [
      const StepIndicator(currentStep: 1), const SizedBox(height: 26),
      TextField(controller: _searchController, onChanged: (_) => setState(() {}), decoration: const InputDecoration(hintText: 'Search doctor', prefixIcon: Icon(Icons.search))),
      const SizedBox(height: 18),
      SizedBox(height: 42, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: filters.length, separatorBuilder: (_, _) => const SizedBox(width: 8), itemBuilder: (_, index) => ChoiceChip(label: Text(filters[index]), selected: _specialization == filters[index], onSelected: (_) => setState(() => _specialization = filters[index])))),
      const SizedBox(height: 20),
      ...doctors.map((doctor) => Padding(padding: const EdgeInsets.only(bottom: 12), child: DoctorCard(doctor: doctor, selected: _selectedDoctor?.id == doctor.id, onTap: () => setState(() => _selectedDoctor = doctor)))),
      const SizedBox(height: 12),
      PrimaryButton(label: 'Next', onPressed: _selectedDoctor == null ? null : () => Navigator.pushNamed(context, AppRoutes.selectDateTime, arguments: _selectedDoctor)),
    ]));
  }
}