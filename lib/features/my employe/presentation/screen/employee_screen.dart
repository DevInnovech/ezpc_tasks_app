import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/my%20employe/data/employee_provider.dart';
import 'package:ezpc_tasks_app/features/my%20employe/presentation/widgets/employee_bonus_header.dart';
import 'package:ezpc_tasks_app/features/my%20employe/presentation/widgets/employee_search_bar.dart';
import 'package:ezpc_tasks_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/employee_list.dart';

class EmployeeScreen extends ConsumerWidget {
  const EmployeeScreen({super.key});

  Future<String?> getEmployeeCode(String userID) async {
    try {
      // Buscar el documento del proveedor usando el userID
      DocumentSnapshot providerDoc = await FirebaseFirestore.instance
          .collection('providers') // Colección de proveedores
          .doc(userID) // Buscar por el userID (este es el ID del proveedor)
          .get();

      if (providerDoc.exists) {
        // Extraer el employeeCode desde el documento del proveedor
        String employeeCode = providerDoc.get('employeeCode');
        return employeeCode;
      } else {
        // Si no se encuentra el documento
        print('No provider found for this user');
        return null;
      }
    } catch (e) {
      print('Error fetching employee code: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController searchController = TextEditingController();

    // Watching the search query and filtered employee list
    final searchQuery = ref.watch(employeeSearchProvider);
    final filteredEmployeeList = ref.watch(filteredEmployeeListProvider);

    // Obtener el UID del usuario autenticado
    final userID = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            color: primaryColor,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomAppBar(
                title: 'Employers',
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Search bar with onChanged listener
                      const EmployeeSearchBar(),
                      filteredEmployeeList.when(
                        loading: () => const Expanded(
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (error, stackTrace) => Center(
                          child: Text('Error: $error'),
                        ),
                        data: (employeeList) {
                          // Calcular ganancias totales y tareas totales
                          final totalEarnings = employeeList.fold<double>(
                            0.0,
                            (sum, employee) => sum + (employee.earnings ?? 0.0),
                          );
                          final totalTasks = employeeList.fold<int>(
                            0,
                            (sum, employee) =>
                                sum + (employee.tasksCompleted ?? 0),
                          );
                          return EmployeeBonusHeader(
                            totalEarnings: totalEarnings,
                            totalTasks: totalTasks,
                            totalEmployees: employeeList.length,
                          );
                        },
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: EmployeeList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FutureBuilder<String?>(
        future: userID != null ? getEmployeeCode(userID) : null,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final employeeCode = snapshot.data ?? "No employee code found";

          return Align(
            alignment: Alignment.bottomCenter, // Centrar el FAB
            child: buildCopyReferral(
              context,
              employeeCode,
              'Employee Code',
              showBorder: true,
              showTitle: false,
              backgroundColor: primaryColor, // Fondo claro
              textColor: Colors.white, // Texto blanco
              iconColor: Colors.white, // Icono blanco
            ),
          );
        },
      ),
    );
  }
}
