import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme.dart';
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

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  UserRole _selectedRole = UserRole.patient;
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email and password.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final error = await _authService.signIn(
      _emailController.text,
      _passwordController.text,
      _selectedRole,
    );
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
      body: _AuthBackdrop(
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
                      child: const _BrandHeader(),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -.5,
                          ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Sign in to manage your hospital queue.',
                      style: TextStyle(
                        color: AppColors.softWhite,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 24),
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
                        child: _GlassCard(
                          child: Form(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Sign in to your account',
                                  style: TextStyle(
                                    color: AppColors.text,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                CustomTextField(
                                  controller: _emailController,
                                  label: 'Email address',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 13),
                                CustomTextField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                ),
                                const SizedBox(height: 22),
                                const Text(
                                  'Select your role',
                                  style: TextStyle(
                                    color: AppColors.text,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                RoleSelector(
                                  selectedRole: _selectedRole,
                                  onChanged: (role) =>
                                      setState(() => _selectedRole = role),
                                ),
                                if (_errorMessage != null) ...[
                                  const SizedBox(height: 16),
                                  _ErrorMessage(message: _errorMessage!),
                                ],
                                const SizedBox(height: 22),
                                PrimaryButton(
                                  label: 'Login',
                                  isLoading: _isLoading,
                                  onPressed: _isLoading ? null : _login,
                                ),
                                if (_selectedRole == UserRole.patient) ...[
                                  const SizedBox(height: 14),
                                  TextButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () => Navigator.pushNamed(
                                            context,
                                            AppRoutes.patientSignUp,
                                          ),
                                    child: const Text(
                                      'Don\'t have an account? Create account',
                                    ),
                                  ),
                                ],
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

class _AuthBackdrop extends StatelessWidget {
  const _AuthBackdrop({required this.child});
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
        top: -90,
        right: -70,
        child: _BlurBlob(size: 240, color: AppColors.blobWhite),
      ),
      Positioned(
        top: 260,
        left: -100,
        child: _BlurBlob(size: 210, color: AppColors.blobBlue),
      ),
      Positioned(
        bottom: -100,
        right: -40,
        child: _BlurBlob(size: 260, color: AppColors.blobWhite),
      ),
      child,
    ],
  );
}

class _BlurBlob extends StatelessWidget {
  const _BlurBlob({required this.size, required this.color});
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

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

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
          child: Image.asset('assets/medihelp_logo.png', fit: BoxFit.cover),
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

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});
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

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});
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
