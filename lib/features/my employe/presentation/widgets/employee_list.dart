import 'package:ezpc_tasks_app/features/my%20employe/data/employee_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/employee_card.dart';

class EmployeeList extends ConsumerWidget {
  const EmployeeList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeList = ref.watch(filteredEmployeeListProvider);

    return employeeList.isEmpty
        ? const Center(child: Text('No employees found'))
        : ListView.builder(
            itemCount: employeeList.length,
            itemBuilder: (context, index) {
              final employee = employeeList[index];
              return EmployeeCard(employee: employee);
            },
          );
  }
}
