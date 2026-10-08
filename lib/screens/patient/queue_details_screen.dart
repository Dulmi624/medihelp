import 'package:flutter/material.dart';

import 'patient_queue_view.dart';

class QueueDetailsScreen extends StatelessWidget {
  const QueueDetailsScreen({super.key});
  @override
  Widget build(BuildContext context) => const PatientQueueView(details: true);
}
