import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/role_selector.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  UserRole _selectedRole = UserRole.patient;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email and password.');
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });
    final error = await _authService.signIn(_emailController.text, _passwordController.text, _selectedRole);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (error != null) {
      setState(() => _errorMessage = error);
      return;
    }
    Navigator.of(context).pushReplacementNamed(_routeForRole(_selectedRole));
  }

  String _routeForRole(UserRole role) => switch (role) {
        UserRole.patient => AppRoutes.patientHome,
        UserRole.receptionist => AppRoutes.receptionistHome,
        UserRole.admin => AppRoutes.adminHome,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MediQueue'), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.local_hospital_outlined, size: 58),
                    const SizedBox(height: 18),
                    Text('Welcome back', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text('Sign in to manage your hospital queue.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 32),
                    CustomTextField(controller: _emailController, label: 'Email address', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 16),
                    CustomTextField(controller: _passwordController, label: 'Password', icon: Icons.lock_outline, isPassword: true),
                    const SizedBox(height: 24),
                    Text('I am a', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    RoleSelector(selectedRole: _selectedRole, onChanged: (role) => setState(() => _selectedRole = role)),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600)),
                    ],
                    const SizedBox(height: 24),
                    PrimaryButton(label: 'Login', onPressed: _isLoading ? null : _login),
                    if (_isLoading) ...[
                      const SizedBox(height: 14),
                      const Center(child: CircularProgressIndicator()),
                    ],
                    if (_selectedRole == UserRole.patient) ...[
                      const SizedBox(height: 18),
                      TextButton(onPressed: _isLoading ? null : () => Navigator.pushNamed(context, AppRoutes.patientSignUp), child: const Text('Create account')),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
