import 'package:ezpc_tasks_app/features/services/data/add_repository.dart';
import 'package:ezpc_tasks_app/features/services/presentation/componentaddservices/schedule_selection_days_widget.dart';
import 'package:ezpc_tasks_app/features/services/presentation/componentaddservices/schedule_selection_hours_widget.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/customcheckbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/features/services/data/task_provider.dart';
import 'package:ezpc_tasks_app/features/services/models/task_model.dart';

class ScheduleStep extends ConsumerWidget {
  const ScheduleStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Acceder a la `currentTask` desde el estado
    final taskState = ref.watch(taskProvider);
    final specialDaysEnabled = ref.watch(specialDaysEnabledProvider);
    final Task? currentTask = taskState.currentTask; // Acceder a `currentTask`

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Selección de días de trabajo
          DaysSelector(
            initialSelection: currentTask?.workingDays ?? [],
            onDaysSelected: (List<String> selectedDays) {
              // Actualizar `workingDays` en la `currentTask` sin usar `copyWith`
              if (currentTask != null) {
                ref.read(taskProvider.notifier).updateTask(
                      workingDays: selectedDays,
                    );
              }
            },
          ),
          Utils.verticalSpace(10),
          // Selección de horas de trabajo
          WorkingHoursSelector(
            initialHours: currentTask?.workingHours,
            onHoursSelected: (Map<String, Map<String, String>> workingHours) {
              // Actualizar `workingHours` en la `currentTask`
              if (currentTask != null) {
                ref.read(taskProvider.notifier).updateTask(
                      workingHours: workingHours,
                    );
              }
            },
          ),
          Utils.verticalSpace(10),
          // Selector de días especiales
          CustomCheckboxListTile(
            title: 'Special days',
            value: specialDaysEnabled,
            onChanged: (bool? value) {
              // Actualizar el estado de días especiales en el TaskProvider
              ref.read(specialDaysEnabledProvider.notifier).state =
                  value ?? false;
            },
          ),
        ],
      ),
    );
  }
}
