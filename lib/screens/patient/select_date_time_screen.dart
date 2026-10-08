import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../models/doctor.dart';
import '../../models/appointment.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/step_indicator.dart';
import '../../widgets/time_slot_chip.dart';

class SelectDateTimeScreen extends StatefulWidget {
  const SelectDateTimeScreen({
    required this.doctor,
    this.existingAppointment,
    super.key,
  });

  final Doctor doctor;
  final Appointment? existingAppointment;

  @override
  State<SelectDateTimeScreen> createState() =>
      _SelectDateTimeScreenState();
}

class _SelectDateTimeScreenState
    extends State<SelectDateTimeScreen> {
  late final Stream<DocumentSnapshot<Map<String, dynamic>>>
      _doctorStream;

  DateTime? _selectedDate;
  String? _selectedTime;

  static const _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  void initState() {
    super.initState();

    _doctorStream = FirebaseFirestore.instance
        .collection('doctors')
        .doc(widget.doctor.id)
        .snapshots();
  }

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  List<DateTime> _readDates(dynamic value) {
    if (value is! List) return [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dates = <String, DateTime>{};

    for (final item in value) {
      if (item is! String ||
          !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(item)) {
        continue;
      }

      final date = DateTime.tryParse(item);

      // Also rejects invalid dates that DateTime normalizes.
      if (date == null ||
          _dateKey(date) != item ||
          date.isBefore(today)) {
        continue;
      }

      dates[item] = date;
    }

    return dates.values.toList()
      ..sort((a, b) => a.compareTo(b));
  }

  int? _timeMinutes(String time) {
    final match = RegExp(
      r'^(0[1-9]|1[0-2]):([0-5][0-9]) (AM|PM)$',
    ).firstMatch(time);

    if (match == null) return null;

    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);

    if (hour == 12) hour = 0;
    if (match.group(3) == 'PM') hour += 12;

    return hour * 60 + minute;
  }

  List<String> _readSlots(dynamic value) {
    if (value is! List) return [];

    final slots = value
        .whereType<String>()
        .where((time) => _timeMinutes(time) != null)
        .toSet()
        .toList();

    slots.sort(
      (a, b) => _timeMinutes(a)!.compareTo(_timeMinutes(b)!),
    );

    return slots;
  }

  bool _isPast(DateTime date, String time) {
    final minutes = _timeMinutes(time);
    if (minutes == null) return true;

    final appointmentTime = DateTime(
      date.year,
      date.month,
      date.day,
      minutes ~/ 60,
      minutes % 60,
    );

    return !appointmentTime.isAfter(DateTime.now());
  }

  Widget _message(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _continue(DateTime date, String time) {
    if (_isPast(date, time)) {
      setState(() => _selectedTime = null);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This time has already passed. '
            'Please select another slot.',
          ),
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.confirmBooking,
      arguments: {
        'doctor': widget.doctor,
        'date': date,
        'time': time,
        'existingAppointment': widget.existingAppointment,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Date & Time')),
      body: widget.existingAppointment != null
          ? _message(
              'Rescheduling is not connected yet. '
              'You can edit patient details from My Appointments.',
            )
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _doctorStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _message(
                    'Could not load doctor availability. '
                    'Please check your connection and sign in again.',
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data = snapshot.data!.data();

                if (data == null) {
                  return _message('This doctor was not found.');
                }

                if (data['isAvailable'] != true) {
                  return _message(
                    'This doctor is currently unavailable.',
                  );
                }

                final dates = _readDates(data['availableDates']);
                final slots = _readSlots(data['availableTimeSlots']);

                if (dates.isEmpty || slots.isEmpty) {
                  return _message(
                    'No upcoming appointment slots are published '
                    'for this doctor.',
                  );
                }

                // Use the first date if the selected date was removed.
                var activeDate = dates.first;

                for (final date in dates) {
                  if (date == _selectedDate) {
                    activeDate = date;
                    break;
                  }
                }

                final selectedTime = _selectedTime;
                final canContinue = selectedTime != null &&
                    slots.contains(selectedTime) &&
                    !_isPast(activeDate, selectedTime);

                final allTimesPassed = slots.every(
                  (time) => _isPast(activeDate, time),
                );

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const StepIndicator(currentStep: 2),
                    const SizedBox(height: 24),
                    Card(
                      elevation: 0,
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(
                          widget.doctor.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        subtitle: Text(
                          widget.doctor.specialization,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Select Date',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: dates.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: 10),
                        itemBuilder: (_, index) {
                          final date = dates[index];
                          final selected = date == activeDate;

                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedDate = date;
                                _selectedTime = null;
                              });
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: 76,
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primary
                                    : Colors.white,
                                borderRadius:
                                    BorderRadius.circular(14),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _weekdays[date.weekday - 1],
                                    style: TextStyle(
                                      color: selected
                                          ? Colors.white
                                          : AppColors.mutedText,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${date.day}',
                                    style: TextStyle(
                                      color: selected
                                          ? Colors.white
                                          : AppColors.text,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${date.month}/${date.year}',
                                    style: TextStyle(
                                      color: selected
                                          ? Colors.white
                                          : AppColors.mutedText,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Available Time Slots',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (allTimesPassed)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text(
                          'All times for this date have passed. '
                          'Please select another date.',
                        ),
                      ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount: slots.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 2.7,
                      ),
                      itemBuilder: (_, index) {
                        final time = slots[index];
                        final unavailable = _isPast(
                          activeDate,
                          time,
                        );

                        return TimeSlotChip(
                          time: time,
                          selected: !unavailable &&
                              selectedTime == time,
                          unavailable: unavailable,
                          onTap: () {
                            if (_isPast(activeDate, time)) return;

                            setState(() {
                              _selectedDate = activeDate;
                              _selectedTime = time;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 26),
                    PrimaryButton(
                      label: 'Continue',
                      onPressed: canContinue
                          ? () => _continue(
                                activeDate,
                                selectedTime,
                              )
                          : null,
                    ),
                  ],
                );
              },
            ),
    );
  }
}