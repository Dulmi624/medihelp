import 'package:flutter/material.dart';

import 'admin_demo_store.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  String _type = 'Appointment';
  late DateTimeRange _range;
  final List<_DemoReport> _reports = [];
  int _nextId = 1;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _range = DateTimeRange(start: today, end: today);
  }

  String _date(DateTime date) => '${date.day}/${date.month}/${date.year}';

  Future<void> _selectDates() async {
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _range,
    );

    if (!mounted || selected == null) return;
    setState(() => _range = selected);
  }

  void _generate() {
    final now = DateTime.now();
    final store = AdminDemoStore.instance;
    final sampleDate = store.patients.isEmpty
        ? DateTime(now.year, now.month, now.day)
        : store.patients.first.date;
    final includesToday =
        !sampleDate.isBefore(_range.start) && !sampleDate.isAfter(_range.end);

    final appointments = includesToday
        ? store.appointments
        : <DemoAppointment>[];
    final patients = store.patients.where((p) {
      final day = DateTime(p.date.year, p.date.month, p.date.day);
      return !day.isBefore(_range.start) && !day.isAfter(_range.end);
    }).toList();
    final waiting = patients.where((p) => p.status == 'Waiting').toList();
    int count(String status) =>
        patients.where((p) => p.status == status).length;
    final results = <String, String>{};

    switch (_type) {
      case 'Appointment':
        results.addAll({
          'Total appointments': '${appointments.length}',
          for (final status in [
            'Scheduled',
            'Checked In',
            'Completed',
            'Cancelled',
          ])
            status: '${appointments.where((a) => a.status == status).length}',
        });
        break;
      case 'Queue / Waiting Time':
        results.addAll({
          'In queue (Waiting + Called)':
              '${count('Waiting') + count('Called')}',
          'Waiting patients': '${waiting.length}',
          'Called': '${count('Called')}',
          'In consultation': '${count('In Consultation')}',
          'Completed queue entries': '${count('Completed')}',
          'Average elapsed wait (Waiting only)': waiting.isEmpty
              ? 'No data'
              : '${(waiting.fold<int>(0, (sum, p) => sum + p.waitMinutes) / waiting.length).toStringAsFixed(1)} min',
          'Longest elapsed wait (Waiting only)': waiting.isEmpty
              ? 'No data'
              : '${waiting.map((p) => p.waitMinutes).reduce((a, b) => a > b ? a : b)} min',
        });
        break;
      case 'Department':
        results.addAll({
          for (final department in ['OPD', 'Dental', 'Paediatrics']) ...{
            '$department appointments':
                '${appointments.where((a) => a.department == department).length}',
            '$department queue entries (all statuses)':
                '${patients.where((p) => p.department == department).length}',
            '$department in queue':
                '${patients.where((p) => p.department == department && (p.status == 'Waiting' || p.status == 'Called')).length}',
          },
        });
        break;
      case 'Patient':
        results.addAll({
          'Distinct appointment sample names':
              '${appointments.map((a) => a.patient).toSet().length}',
          'Distinct queue sample names':
              '${patients.map((p) => p.name).toSet().length}',
        });
        break;
    }

    final report = _DemoReport(
      id: 'DEMO-${_nextId++}',
      type: _type,
      range: _range,
      generatedAt: now,
      results: results,
    );

    setState(() => _reports.insert(0, report));
    _showDetails(report);
  }

  Future<void> _showDetails(_DemoReport report) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${report.type} Report'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'DEMO • Sample data only',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text('ID: ${report.id}'),
              Text(
                'Period: ${_date(report.range.start)}'
                ' – ${_date(report.range.end)}',
              ),
              Text('Generated: ${_date(report.generatedAt)}'),
              const Divider(),
              for (final entry in report.results.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text('${entry.key}: ${entry.value}'),
                ),
              const SizedBox(height: 8),
              const Text(
                'Snapshot of shared demo data at generation time. '
                'Generate a new report after changes. Appointment samples use the demo session date. '
                'Appointment and queue datasets are separate. Waiting times are fixed sample values. '
                'Sample names are not verified patient identities.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(_DemoReport report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete demo report?'),
        content: Text('Remove ${report.id} from this temporary list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;
    setState(() => _reports.remove(report));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Reports & Analytics',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Demo mode • Reports reset after restarting the app',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          initialValue: _type,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Report Type',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final type in [
              'Appointment',
              'Queue / Waiting Time',
              'Department',
              'Patient',
            ])
              DropdownMenuItem(value: type, child: Text(type)),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _type = value);
          },
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.date_range),
            title: const Text('Date Range'),
            subtitle: Text('${_date(_range.start)} – ${_date(_range.end)}'),
            trailing: const Icon(Icons.edit_outlined),
            onTap: _selectDates,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _generate,
          icon: const Icon(Icons.add_chart),
          label: const Text('Generate Demo Report'),
        ),
        const SizedBox(height: 24),
        const Text(
          'Recent Reports',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (_reports.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('No reports generated yet.'),
          ),
        for (final report in _reports)
          Card(
            child: ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text('${report.type} Report'),
              subtitle: Text(
                '${report.id}\n'
                '${_date(report.range.start)} – '
                '${_date(report.range.end)}',
              ),
              isThreeLine: true,
              onTap: () => _showDetails(report),
              trailing: IconButton(
                tooltip: 'Delete report',
                onPressed: () => _delete(report),
                icon: const Icon(Icons.delete_outline),
              ),
            ),
          ),
      ],
    );
  }
}

class _DemoReport {
  const _DemoReport({
    required this.id,
    required this.type,
    required this.range,
    required this.generatedAt,
    required this.results,
  });

  final String id;
  final String type;
  final DateTimeRange range;
  final DateTime generatedAt;
  final Map<String, String> results;
}
