import 'package:flutter/material.dart';

enum UserRole { patient, receptionist, admin }

class RoleSelector extends StatelessWidget {
  const RoleSelector({required this.selectedRole, required this.onChanged, super.key});

  final UserRole selectedRole;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<UserRole>(
      segments: const [
        ButtonSegment(value: UserRole.patient, label: Text('Patient'), icon: Icon(Icons.person_outline)),
        ButtonSegment(value: UserRole.receptionist, label: Text('Receptionist'), icon: Icon(Icons.desk_outlined)),
        ButtonSegment(value: UserRole.admin, label: Text('Admin'), icon: Icon(Icons.admin_panel_settings_outlined)),
      ],
      selected: {selectedRole},
      onSelectionChanged: (roles) => onChanged(roles.first),
      multiSelectionEnabled: false,
      showSelectedIcon: false,
    );
  }
}