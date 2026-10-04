import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme.dart';
import '../../widgets/patient_app_bar.dart';
import '../../widgets/patient_bottom_nav.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (!_formKey.currentState!.validate()) return;
    _messageController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your message was sent. Our team will contact you soon.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PatientAppBar(
        title: 'Contact Us',
        subtitle: 'We are here to help',
        showBackButton: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.page),
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 96, 20, 24),
            children: [
              const Text(
                'How can we help?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Reach our hospital team or send us a message.',
                style: TextStyle(color: AppColors.mutedText),
              ),
              const SizedBox(height: 20),
              _ContactTile(
                icon: Icons.phone_outlined,
                title: 'Call the hospital',
                value: '+94 11 234 5678',
                uri: Uri(scheme: 'tel', path: '+94112345678'),
              ),
              _ContactTile(
                icon: Icons.email_outlined,
                title: 'Email support',
                value: 'support@mediqueue.lk',
                uri: Uri(scheme: 'mailto', path: 'support@mediqueue.lk'),
              ),
              _ContactTile(
                icon: Icons.location_on_outlined,
                title: 'Reception desk',
                value: 'No. 25 Hospital Road, Colombo',
                uri: Uri.parse(
                  'https://maps.google.com/?q=MediQueue+Central+Hospital+Colombo',
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Send a message',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _messageController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'Tell us how we can help...',
                            alignLabelWithHint: true,
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Please enter a message'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _sendMessage,
                            child: const Text('Send Message'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const PatientBottomNav(currentIndex: 0),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.uri,
  });
  final IconData icon;
  final String title;
  final String value;
  final Uri uri;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primarySoft,
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(value),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final launched = await launchUrl(uri);
        if (!launched && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open $value')),
          );
        }
      },
    ),
  );
}
