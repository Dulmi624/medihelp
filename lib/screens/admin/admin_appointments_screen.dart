import 'package:flutter/material.dart';

import 'admin_demo_store.dart';

class AdminAppointmentsScreen extends StatefulWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  State<AdminAppointmentsScreen> createState() =>
      _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState extends State<AdminAppointmentsScreen> {
  final _searchController = TextEditingController();
  String _filter = 'All';
  final Set<String> _saving = {};

  static const _statuses = [
    'Scheduled',
    'Checked In',
    'Completed',
    'Cancelled',
  ];

  final _store = AdminDataStore.instance;
  List<AdminAppointment> get _appointments => _store.appointments;

  @override
  void initState() {
    super.initState();
    _store.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _store.removeListener(_refresh);
    _searchController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Checked In':
        return Colors.teal;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Future<void> _changeStatus(AdminAppointment appointment) async {
    if (_saving.contains(appointment.id)) return;
    if (['Completed', 'Cancelled'].contains(appointment.status)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completed/cancelled appointments cannot be reopened.'),
        ),
      );
      return;
    }
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Change appointment status'),
        children: [
          for (final status in _statuses)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, status),
              child: Row(
                children: [
                  Icon(
                    appointment.status == status
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: _statusColor(status),
                  ),
                  const SizedBox(width: 12),
                  Text(status),
                ],
              ),
            ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );

    if (!mounted || selected == null || selected == appointment.status) {
      return;
    }

    setState(() => _saving.add(appointment.id));
    try {
      await _store.updateAppointment(appointment, selected);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment status saved.')),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AdminDataStore.messageFor(error))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving.remove(appointment.id));
    }
  }

  Future<void> _showDetails(AdminAppointment appointment) async {
    final edit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Appointment Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detail('Appointment', appointment.id),
              _detail('Patient', appointment.patient),
              _detail('Doctor', appointment.doctor),
              _detail('Department', appointment.department),
              _detail(
                'Date',
                '${appointment.date.day}/${appointment.date.month}/${appointment.date.year}',
              ),
              _detail('Time', appointment.time),
              _detail('Status', appointment.status),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Change Status'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (edit == true) await _changeStatus(appointment);
  }

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text('$label: $value'),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_store.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(_store.error!),
        ),
      );
    }
    if (_store.loading) return const Center(child: CircularProgressIndicator());
    final query = _searchController.text.trim().toLowerCase();

    final visible = _appointments.where((appointment) {
      final matchesStatus = _filter == 'All' || appointment.status == _filter;
      final matchesSearch = [
        appointment.id,
        appointment.patient,
        appointment.doctor,
        appointment.department,
      ].any((value) => value.toLowerCase().contains(query));

      return matchesStatus && matchesSearch;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Appointments',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Live Firestore appointments • All dates',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search patient, doctor or appointment ID',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.clear),
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final status in ['All', ..._statuses])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(status),
                          selected: _filter == status,
                          onSelected: (_) {
                            setState(() => _filter = status);
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text('${visible.length} appointments'),
            ],
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? const Center(child: Text('No matching appointments'))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: visible.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final appointment = visible[index];
                    final color = _statusColor(appointment.status);

                    return Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _saving.contains(appointment.id)
                            ? null
                            : () => _showDetails(appointment),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    child: Text(
                                      appointment.patient.isEmpty
                                          ? '?'
                                          : appointment.patient
                                                .substring(0, 1)
                                                .toUpperCase(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      appointment.patient,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${appointment.department} • '
                                '${appointment.doctor}',
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${appointment.id} • '
                                '${appointment.date.day}/${appointment.date.month}/${appointment.date.year} • ${appointment.time}',
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withAlpha(25),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  appointment.status,
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
