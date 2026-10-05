import 'package:flutter/material.dart';

import 'admin_demo_store.dart';

class AdminQueueScreen extends StatefulWidget {
  const AdminQueueScreen({super.key});

  @override
  State<AdminQueueScreen> createState() => _AdminQueueScreenState();
}

class _AdminQueueScreenState extends State<AdminQueueScreen> {
  static const _departments = ['OPD', 'Dental', 'Paediatrics'];

  String _department = 'All';
  bool _showFlow = false;
  late DateTime _selectedDate;
  final _store = AdminDemoStore.instance;
  List<DemoQueuePatient> get _patients => _store.patients;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);

    _store.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _store.removeListener(_refresh);
    super.dispose();
  }

  String _dateLabel(DateTime date) => '${date.day}/${date.month}/${date.year}';

  bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<DemoQueuePatient> get _dayPatients =>
      _patients.where((p) => _sameDate(p.date, _selectedDate)).toList();

  List<DemoQueuePatient> get _visible => _dayPatients
      .where((p) => _department == 'All' || p.department == _department)
      .toList();

  int _count(List<DemoQueuePatient> patients, String status) =>
      patients.where((p) => p.status == status).length;

  double? _averageWait(List<DemoQueuePatient> patients) {
    final waiting = patients.where((p) => p.status == 'Waiting').toList();

    if (waiting.isEmpty) return null;

    return waiting.fold<int>(0, (sum, p) => sum + p.waitMinutes) /
        waiting.length;
  }

  bool _isInQueue(DemoQueuePatient patient) =>
      patient.status == 'Waiting' || patient.status == 'Called';

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (!mounted || selected == null) return;
    setState(() => _selectedDate = selected);
  }

  Future<void> _callNext() async {
    final waiting = _visible.where((p) => p.status == 'Waiting').toList();
    if (waiting.isEmpty) return;

    waiting.sort((a, b) => a.number.compareTo(b.number));
    final next = waiting.first;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Call next patient?'),
        content: Text(
          '${next.number} • ${next.name}\n'
          '${next.department}\n\n'
          'Demo action only. Firebase will not be updated.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Call Patient'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    _store.callPatient(next);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${next.number} called — demo only')),
    );
  }

  Widget _summary(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _queueList(List<DemoQueuePatient> patients) {
    if (patients.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('No patients for this date and department.'),
      );
    }

    return Column(
      children: [
        for (final patient in patients)
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text(patient.number.substring(1))),
              title: Text(patient.name),
              subtitle: Text(
                '${patient.department} • ${patient.number}\n'
                '${patient.status}'
                '${patient.status == 'Waiting' ? ' • ${patient.waitMinutes} min elapsed' : ''}',
              ),
              isThreeLine: true,
            ),
          ),
      ],
    );
  }

  Widget _flowView() {
    final dayPatients = _dayPatients;
    final queueCounts = <String, int>{};
    final averages = <String, double>{};

    for (final department in _departments) {
      final patients = dayPatients
          .where((p) => p.department == department)
          .toList();

      final queueCount = patients.where(_isInQueue).length;
      if (queueCount > 0) queueCounts[department] = queueCount;

      final average = _averageWait(patients);
      if (average != null) averages[department] = average;
    }

    final maxQueue = queueCounts.isEmpty
        ? 0
        : queueCounts.values.reduce((a, b) => a > b ? a : b);

    final maxWait = averages.isEmpty
        ? null
        : averages.values.reduce((a, b) => a > b ? a : b);

    final longestQueues = queueCounts.entries
        .where((entry) => entry.value == maxQueue)
        .map((entry) => entry.key)
        .join(', ');

    final longestWaits = averages.entries
        .where((entry) => entry.value == maxWait)
        .map((entry) => entry.key)
        .join(', ');

    final departments = _department == 'All' ? _departments : [_department];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Patient Flow & Waiting Times',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Daily comparison across all departments',
          style: TextStyle(color: Colors.grey),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  maxQueue == 0
                      ? 'Longest queue: No active queue'
                      : 'Longest queue: $longestQueues ($maxQueue patients)',
                ),
                const SizedBox(height: 8),
                Text(
                  maxWait == null
                      ? 'Highest average elapsed wait: No waiting patients'
                      : 'Highest average elapsed wait: '
                            '$longestWaits (${maxWait.round()} min)',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final department in departments)
          _departmentCard(
            department,
            dayPatients.where((p) => p.department == department).toList(),
          ),
        const SizedBox(height: 8),
        const Text(
          'Elapsed wait is time already spent waiting, '
          'not an estimate of time remaining. '
          'Demo minutes are fixed sample values.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _departmentCard(String department, List<DemoQueuePatient> patients) {
    final average = _averageWait(patients);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              department,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('Waiting: ${_count(patients, 'Waiting')}')),
                Chip(label: Text('Called: ${_count(patients, 'Called')}')),
                Chip(
                  label: Text(
                    'In consultation: '
                    '${_count(patients, 'In Consultation')}',
                  ),
                ),
                Chip(
                  label: Text('Completed: ${_count(patients, 'Completed')}'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              average == null
                  ? 'Average elapsed wait: No waiting patients'
                  : 'Average elapsed wait: ${average.round()} min',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final waitingCount = _count(visible, 'Waiting');
    final average = _averageWait(visible);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Queue Monitoring',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Demo mode • Sample data • Temporary changes',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _department,
          decoration: const InputDecoration(
            labelText: 'Department',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final department in ['All', ..._departments])
              DropdownMenuItem(value: department, child: Text(department)),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _department = value);
            }
          },
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Selected Date'),
            subtitle: Text(_dateLabel(_selectedDate)),
            trailing: const Icon(Icons.edit_outlined),
            onTap: _selectDate,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Queue'),
              selected: !_showFlow,
              onSelected: (_) => setState(() => _showFlow = false),
            ),
            ChoiceChip(
              label: const Text('Patient Flow / Waiting Times'),
              selected: _showFlow,
              onSelected: (_) => setState(() => _showFlow = true),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_showFlow)
          _flowView()
        else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _summary(
                  'Waiting',
                  '$waitingCount',
                  Icons.people_outline,
                ),
              ),
              Expanded(
                child: _summary(
                  'Avg. elapsed wait',
                  average == null ? '—' : '${average.round()}m',
                  Icons.schedule,
                ),
              ),
              Expanded(
                child: _summary(
                  'In consultation',
                  '${_count(visible, 'In Consultation')}',
                  Icons.medical_services_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _queueList(visible),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: waitingCount == 0 ? null : _callNext,
            icon: const Icon(Icons.campaign_outlined),
            label: const Text('Call Next Patient'),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}
