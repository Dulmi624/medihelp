import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/medical_logo.dart';
import '../../widgets/role_selector.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _redirectAfterSplash();
  }

  Future<void> _redirectAfterSplash() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final role = await _authService.getCurrentUserRole();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(_routeForRole(role));
  }

  String _routeForRole(UserRole? role) => switch (role) {
        UserRole.patient => AppRoutes.patientHome,
        UserRole.receptionist => AppRoutes.receptionistHome,
        UserRole.admin => AppRoutes.adminHome,
        null => AppRoutes.login,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(18)),
          child: const Center(child: RepaintBoundary(child: MedicalLogo())),
        ),
      ),
    );
  }
}