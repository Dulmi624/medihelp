import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});
  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final _reports = FirebaseFirestore.instance.collection('admin_reports');
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _stream = _reports
      .orderBy('createdAt', descending: true)
      .snapshots();
  final Set<String> _busy = {};
  bool _editing = false;
  String _date(DateTime d) => '${d.day}/${d.month}/${d.year}';
  DateTime? _timestamp(dynamic value) =>
      value is Timestamp ? value.toDate() : null;
  String _text(Map<String, dynamic> data, String key) =>
      data[key] is String ? data[key] as String : '';

  Uri? _driveUri(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.userInfo.isNotEmpty ||
        (uri.hasPort && uri.port != 443)) {
      return null;
    }
    if (uri.host == 'drive.google.com' &&
        (RegExp(r'^/file/d/[^/]+').hasMatch(uri.path) ||
            (uri.path == '/open' &&
                (uri.queryParameters['id'] ?? '').isNotEmpty))) {
      return uri;
    }
    if (uri.host == 'docs.google.com' &&
        RegExp(r'^/document/d/[^/]+').hasMatch(uri.path)) {
      return uri;
    }
    return null;
  }

  void _message(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  String _error(Object error) {
    if (error is FirebaseException && error.code == 'permission-denied') {
      return 'Access denied. Ask the project owner to check Admin report permissions.';
    }
    return 'Could not complete this action. Check your connection and try again.';
  }

  Future<void> _edit([
    QueryDocumentSnapshot<Map<String, dynamic>>? document,
  ]) async {
    if (_editing) return;
    _editing = true;
    final data = document?.data() ?? <String, dynamic>{};
    final title = TextEditingController(text: _text(data, 'title'));
    final link = TextEditingController(text: _text(data, 'driveLink'));
    final form = GlobalKey<FormState>();
    const types = [
      'Appointment',
      'Queue / Waiting Time',
      'Department',
      'Patient',
      'Other',
    ];
    String type = types.contains(data['type'])
        ? data['type'] as String
        : 'Other';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var range = DateTimeRange(
      start: _timestamp(data['periodStart']) ?? today,
      end: _timestamp(data['periodEnd']) ?? today,
    );
    bool saving = false;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, update) {
            return PopScope(
              canPop: !saving,
              child: AlertDialog(
                title: Text(
                  document == null ? 'Add Drive Report' : 'Edit Report',
                ),
                content: SingleChildScrollView(
                  child: Form(
                    key: form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Upload your Word/PDF file to Google Drive first. Keep sharing Restricted.',
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: title,
                          enabled: !saving,
                          maxLength: 120,
                          decoration: const InputDecoration(
                            labelText: 'Report title',
                          ),
                          validator: (value) => (value ?? '').trim().isEmpty
                              ? 'Enter a title'
                              : null,
                        ),
                        DropdownButtonFormField<String>(
                          initialValue: type,
                          decoration: const InputDecoration(
                            labelText: 'Report type',
                          ),
                          items: types
                              .map(
                                (t) =>
                                    DropdownMenuItem(value: t, child: Text(t)),
                              )
                              .toList(),
                          onChanged: saving
                              ? null
                              : (value) => update(() => type = value ?? type),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Report period'),
                          subtitle: Text(
                            '${_date(range.start)} – ${_date(range.end)}',
                          ),
                          trailing: const Icon(Icons.date_range),
                          onTap: saving
                              ? null
                              : () async {
                                  final picked = await showDateRangePicker(
                                    context: dialogContext,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2100),
                                    initialDateRange: range,
                                  );
                                  if (dialogContext.mounted && picked != null) {
                                    update(() => range = picked);
                                  }
                                },
                        ),
                        TextFormField(
                          controller: link,
                          enabled: !saving,
                          maxLength: 2048,
                          keyboardType: TextInputType.url,
                          minLines: 2,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Google Drive file link',
                          ),
                          validator: (value) => _driveUri(value ?? '') == null
                              ? 'Paste a Google Drive file or Google Docs document link'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: saving
                        ? null
                        : () => Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: saving
                        ? null
                        : () async {
                            if (!form.currentState!.validate()) return;
                            final uid = FirebaseAuth.instance.currentUser?.uid;
                            if (uid == null) {
                              _message('Please sign in again.');
                              return;
                            }
                            update(() => saving = true);
                            try {
                              final values = <String, dynamic>{
                                'title': title.text.trim(),
                                'type': type,
                                'driveLink': link.text.trim(),
                                'periodStart': Timestamp.fromDate(range.start),
                                'periodEnd': Timestamp.fromDate(range.end),
                                'updatedAt': FieldValue.serverTimestamp(),
                              };
                              if (document == null) {
                                await _reports.add({
                                  ...values,
                                  'createdBy': uid,
                                  'createdAt': FieldValue.serverTimestamp(),
                                });
                              } else {
                                await document.reference.update(values);
                              }
                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext);
                              }
                              _message('Report link saved.');
                            } catch (error) {
                              _message(_error(error));
                              if (dialogContext.mounted) {
                                update(() => saving = false);
                              }
                            }
                          },
                    child: Text(saving ? 'Saving…' : 'Save Report'),
                  ),
                ],
              ),
            );
          },
        ),
      );
    } finally {
      // Let the closing dialog finish using its text fields before disposal.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      title.dispose();
      link.dispose();
      _editing = false;
    }
  }

  Future<void> _open(String link) async {
    final uri = _driveUri(link);
    if (uri == null) {
      _message('Invalid Google Drive file link. Edit the report to fix it.');
      return;
    }
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        _message(
          'Could not open this link. Check that a browser is installed.',
        );
      }
    } catch (_) {
      _message('Could not open this link.');
    }
  }

  Future<void> _delete(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) async {
    if (_busy.contains(document.id)) return;
    setState(() => _busy.add(document.id));
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete report link?'),
          content: const Text(
            'This removes the saved entry from the app. The file stays in Google Drive.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      await document.reference.delete();
      _message('Report link deleted.');
    } catch (error) {
      _message(_error(error));
    } finally {
      if (mounted) setState(() => _busy.remove(document.id));
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const Text(
        'Reports',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      const Text(
        'Save links to Word/PDF reports uploaded to Google Drive. Sign in to Drive with the Google account that has access.',
      ),
      const SizedBox(height: 16),
      FilledButton.icon(
        onPressed: () => _edit(),
        icon: const Icon(Icons.add_link),
        label: const Text('Add Report Link'),
      ),
      const SizedBox(height: 24),
      const Text(
        'Saved Reports',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_error(snapshot.error!)),
            );
          }
          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No report links saved yet.'),
            );
          }
          return Column(
            children: docs.map((doc) {
              final data = doc.data();
              final start = _timestamp(data['periodStart']);
              final end = _timestamp(data['periodEnd']);
              final busy = _busy.contains(doc.id);
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _text(data, 'title'),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(_text(data, 'type')),
                      if (start != null && end != null)
                        Text('${_date(start)} – ${_date(end)}'),
                      Wrap(
                        spacing: 8,
                        children: [
                          TextButton.icon(
                            onPressed: busy
                                ? null
                                : () => _open(_text(data, 'driveLink')),
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Open'),
                          ),
                          TextButton.icon(
                            onPressed: busy ? null : () => _edit(doc),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit'),
                          ),
                          TextButton.icon(
                            onPressed: busy ? null : () => _delete(doc),
                            icon: const Icon(Icons.delete_outline),
                            label: Text(busy ? 'Please wait…' : 'Delete'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    ],
  );
}
