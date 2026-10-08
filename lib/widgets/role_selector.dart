import 'package:flutter/material.dart';

import '../core/theme.dart';

enum UserRole { patient, receptionist, admin }

class RoleSelector extends StatelessWidget {
  const RoleSelector({required this.selectedRole, required this.onChanged, super.key});

  final UserRole selectedRole;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    final roles = [
      (UserRole.patient, 'Patient', Icons.person_outline),
      (UserRole.receptionist, 'Receptionist', Icons.desk_outlined),
      (UserRole.admin, 'Admin', Icons.admin_panel_settings_outlined),
    ];
    return Row(
      children: [
        for (var index = 0; index < roles.length; index++) ...[
          if (index > 0) const SizedBox(width: 8),
          Expanded(
            child: _RoleTile(
              role: roles[index].$1,
              label: roles[index].$2,
              icon: roles[index].$3,
              selected: roles[index].$1 == selectedRole,
              onTap: () => onChanged(roles[index].$1),
            ),
          ),
        ],
      ],
    );
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.role,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final UserRole role;
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      height: 78,
      decoration: BoxDecoration(
        gradient: selected ? AppGradients.primary : null,
        color: selected ? null : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? Colors.transparent : AppColors.border,
        ),
        boxShadow: selected
            ? const [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? Colors.white : AppColors.mutedText,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}