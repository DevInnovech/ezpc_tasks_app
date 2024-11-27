import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:flutter/material.dart';

class EmployeeBonusHeader extends StatelessWidget {
  final double totalEarnings;
  final int totalTasks;
  final int totalEmployees;

  const EmployeeBonusHeader({
    super.key,
    required this.totalEarnings,
    required this.totalTasks,
    required this.totalEmployees,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatRow('Recorded earnings', '\$$totalEarnings'),
          _buildStatRow('Tasks performed', '$totalTasks'),
          _buildStatRow('Registered Employees', '$totalEmployees'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: primaryColor)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: primaryColor)),
        ],
      ),
    );
  }
}
