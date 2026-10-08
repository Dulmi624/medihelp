import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../models/doctor.dart';
import '../../models/appointment.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/step_indicator.dart';
import '../../widgets/time_slot_chip.dart';

class SelectDateTimeScreen extends StatefulWidget {
  const SelectDateTimeScreen({required this.doctor, this.existingAppointment, super.key});
  final Doctor doctor;
  final Appointment? existingAppointment;

  @override
  State<SelectDateTimeScreen> createState() => _SelectDateTimeScreenState();
}

class _SelectDateTimeScreenState extends State<SelectDateTimeScreen> {
  late DateTime _selectedDate;
  String? _selectedTime;
  final _dates = List.generate(7, (index) => DateTime(2026, 9, 21).add(Duration(days: index)));
  static const _slots = ['09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '02:00 PM', '02:30 PM', '03:00 PM'];

  @override
  void initState() {
    super.initState();
    _selectedDate = _dates.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Date & Time')), body: ListView(padding: const EdgeInsets.all(20), children: [
      const StepIndicator(currentStep: 2), const SizedBox(height: 24),
      Card(elevation: 0, child: ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: Text(widget.doctor.name, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(widget.doctor.specialization))),
      const SizedBox(height: 24), const Text('Select Date', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 12),
      SizedBox(height: 86, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: _dates.length, separatorBuilder: (_, _) => const SizedBox(width: 10), itemBuilder: (_, index) { final date = _dates[index]; final selected = date == _selectedDate; return InkWell(onTap: () => setState(() { _selectedDate = date; _selectedTime = null; }), borderRadius: BorderRadius.circular(14), child: Container(width: 66, decoration: BoxDecoration(color: selected ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: selected ? AppColors.primary : AppColors.border)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1], style: TextStyle(color: selected ? Colors.white : AppColors.mutedText, fontSize: 12)), const SizedBox(height: 6), Text('${date.day}', style: TextStyle(color: selected ? Colors.white : AppColors.text, fontSize: 20, fontWeight: FontWeight.w800))]))); })),
      const SizedBox(height: 24), const Text('Available Time Slots', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 12),
      GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: _slots.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.7), itemBuilder: (_, index) { final unavailable = index == 1 || index == 5; return TimeSlotChip(time: _slots[index], selected: _selectedTime == _slots[index], unavailable: unavailable, onTap: () => setState(() => _selectedTime = _slots[index])); }),
      const SizedBox(height: 26), PrimaryButton(label: 'Continue', onPressed: _selectedTime == null ? null : () => Navigator.pushNamed(context, AppRoutes.confirmBooking, arguments: {'doctor': widget.doctor, 'date': _selectedDate, 'time': _selectedTime, 'existingAppointment': widget.existingAppointment})),
    ]));
  }
}