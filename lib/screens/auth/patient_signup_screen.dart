import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class PatientSignUpScreen extends StatefulWidget {
  const PatientSignUpScreen({super.key});

  @override
  State<PatientSignUpScreen> createState() => _PatientSignUpScreenState();
}

class _PatientSignUpScreenState extends State<PatientSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    for (final controller in [_nameController, _phoneController, _emailController, _passwordController, _confirmPasswordController]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    final error = await _authService.registerPatient(_nameController.text, _emailController.text, _passwordController.text, _phoneController.text);
    if (!mounted) return;
    if (error != null) {
      setState(() { _isLoading = false; _errorMessage = error; });
      return;
    }
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.patientHome, (route) => false);
  }

  String? _required(String? value) => value == null || value.trim().isEmpty ? 'Required' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Patient Account')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text('Get started with MediQueue', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('Create your patient account to book appointments.'),
              const SizedBox(height: 28),
              CustomTextField(controller: _nameController, label: 'Full name', icon: Icons.person_outline, validator: _required),
              const SizedBox(height: 14),
              CustomTextField(controller: _phoneController, label: 'Phone number', icon: Icons.phone_outlined, keyboardType: TextInputType.phone, validator: _required),
              const SizedBox(height: 14),
              CustomTextField(controller: _emailController, label: 'Email address', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (value) => value == null || !value.contains('@') ? 'Enter a valid email' : null),
              const SizedBox(height: 14),
              CustomTextField(controller: _passwordController, label: 'Password', icon: Icons.lock_outline, isPassword: true, validator: (value) => value == null || value.length < 6 ? 'Use at least 6 characters' : null),
              const SizedBox(height: 14),
              CustomTextField(controller: _confirmPasswordController, label: 'Confirm password', icon: Icons.lock_reset_outlined, isPassword: true, validator: (value) => value != _passwordController.text ? 'Passwords do not match' : null),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600)),
              ],
              const SizedBox(height: 24),
              PrimaryButton(label: 'Create account', onPressed: _isLoading ? null : _register),
              if (_isLoading) const Padding(padding: EdgeInsets.only(top: 14), child: Center(child: CircularProgressIndicator())),
            ],
          ),
        ),
      ),
    );
  }
}
