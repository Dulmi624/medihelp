import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/routes.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class PatientSignUpScreen extends StatefulWidget {
  const PatientSignUpScreen({super.key});

  @override
  State<PatientSignUpScreen> createState() => _PatientSignUpScreenState();
}

class _PatientSignUpScreenState extends State<PatientSignUpScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
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
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (final controller in [
      _nameController,
      _phoneController,
      _emailController,
      _passwordController,
      _confirmPasswordController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final error = await _authService.registerPatient(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
      _phoneController.text,
    );
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
      return;
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.patientHome,
      (route) => false,
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _SignUpBackdrop(
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FadeTransition(
                      opacity: _animationController,
                      child: const _SignUpBrandHeader(),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Create your account',
                      style: TextStyle(
                        color: AppColors.onPrimary,
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Join MediQueue for simpler, healthier care.',
                      style: TextStyle(
                        color: AppColors.softWhite,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 22),
                    FadeTransition(
                      opacity: _animationController,
                      child: SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0, .12),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: _SignUpGlassCard(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Patient details',
                                  style: TextStyle(
                                    color: AppColors.text,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                CustomTextField(
                                  controller: _nameController,
                                  label: 'Full name',
                                  icon: Icons.person_outline,
                                  validator: _required,
                                ),
                                const SizedBox(height: 13),
                                CustomTextField(
                                  controller: _phoneController,
                                  label: 'Phone number',
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  validator: _required,
                                ),
                                const SizedBox(height: 13),
                                CustomTextField(
                                  controller: _emailController,
                                  label: 'Email address',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) =>
                                      value == null || !value.contains('@')
                                      ? 'Enter a valid email'
                                      : null,
                                ),
                                const SizedBox(height: 13),
                                CustomTextField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  validator: (value) =>
                                      value == null || value.length < 6
                                      ? 'Use at least 6 characters'
                                      : null,
                                ),
                                const SizedBox(height: 13),
                                CustomTextField(
                                  controller: _confirmPasswordController,
                                  label: 'Confirm password',
                                  icon: Icons.lock_reset_outlined,
                                  isPassword: true,
                                  validator: (value) =>
                                      value != _passwordController.text
                                      ? 'Passwords do not match'
                                      : null,
                                ),
                                if (_errorMessage != null) ...[
                                  const SizedBox(height: 16),
                                  _SignUpErrorMessage(message: _errorMessage!),
                                ],
                                const SizedBox(height: 22),
                                PrimaryButton(
                                  label: 'Create account',
                                  isLoading: _isLoading,
                                  onPressed: _isLoading ? null : _register,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Caring People, Healthier Tomorrow',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.softWhite,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

class _SignUpBackdrop extends StatelessWidget {
  const _SignUpBackdrop({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppGradients.page),
        ),
      ),
      Positioned(
        top: -80,
        right: -70,
        child: _SignUpBlob(size: 230, color: AppColors.blobWhite),
      ),
      Positioned(
        top: 300,
        left: -100,
        child: _SignUpBlob(size: 210, color: AppColors.blobBlue),
      ),
      Positioned(
        bottom: -100,
        right: -50,
        child: _SignUpBlob(size: 250, color: AppColors.blobWhite),
      ),
      child,
    ],
  );
}

class _SignUpBlob extends StatelessWidget {
  const _SignUpBlob({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => ImageFiltered(
    imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    ),
  );
}

class _SignUpBrandHeader extends StatelessWidget {
  const _SignUpBrandHeader();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(17),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 16,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Image.asset(
            'assets/medihelp_logo.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
      const SizedBox(width: 13),
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MediHelp',
            style: TextStyle(
              color: AppColors.onPrimary,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Hospital Management System',
            style: TextStyle(color: AppColors.softWhite, fontSize: 11),
          ),
        ],
      ),
    ],
  );
}

class _SignUpGlassCard extends StatelessWidget {
  const _SignUpGlassCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(28),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.glass,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 28,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: child,
      ),
    ),
  );
}

class _SignUpErrorMessage extends StatelessWidget {
  const _SignUpErrorMessage({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
    decoration: BoxDecoration(
      color: AppColors.errorSurface,
      borderRadius: BorderRadius.circular(13),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.error_outline_rounded,
          color: AppColors.errorText,
          size: 20,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: AppColors.errorText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
