import 'package:ezpc_tasks_app/features/my%20employe/data/employee_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/employee_card.dart';

class EmployeeList extends ConsumerWidget {
  const EmployeeList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener el estado del proveedor
    final employeeListState = ref.watch(filteredEmployeeListProvider);

    return employeeListState.when(
      // Estado de carga
      loading: () => const Center(child: CircularProgressIndicator()),

      // Estado de error
      error: (error, stackTrace) => Center(
        child: Text('Error: $error'),
      ),

      // Cuando la lista de empleados se carga correctamente
      data: (employeeList) {
        return employeeList.isEmpty
            ? const Center(child: Text('No employees found'))
            : ListView.builder(
                itemCount: employeeList.length,
                itemBuilder: (context, index) {
                  final employee = employeeList[index];
                  return EmployeeCard(employee: employee);
                },
              );
      },
    );
  }
}
