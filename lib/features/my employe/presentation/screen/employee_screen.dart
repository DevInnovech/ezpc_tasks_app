import 'package:ezpc_tasks_app/features/my%20employe/data/employee_provider.dart';
import 'package:ezpc_tasks_app/features/my%20employe/presentation/widgets/employee_bonus_header.dart';
import 'package:ezpc_tasks_app/features/my%20employe/presentation/widgets/employee_search_bar.dart';
import 'package:ezpc_tasks_app/features/referral/presentation/screens/referral_screen.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/employee_list.dart';

class EmployeeScreen extends ConsumerWidget {
  const EmployeeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController searchController = TextEditingController();

    // Watching the search query and filtered employee list
    final searchQuery = ref.watch(employeeSearchProvider);
    final filteredEmployeeList = ref.watch(filteredEmployeeListProvider);

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
              buildCustomAppBar(context, "Employees"),
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
                      EmployeeBonusHeader(
                        totalEarnings: 500,
                        totalTasks: 210,
                        totalEmployees: filteredEmployeeList.length,
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
    );
  }
}
