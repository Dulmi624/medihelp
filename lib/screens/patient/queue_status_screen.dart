import 'package:flutter/material.dart';

import 'patient_queue_view.dart';

class QueueStatusScreen extends StatelessWidget {
  const QueueStatusScreen({super.key});
  @override
  Widget build(BuildContext context) => const PatientQueueView(details: false);
}
