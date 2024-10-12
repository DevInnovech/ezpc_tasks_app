import 'package:ezpc_tasks_app/features/services/data/add_repository.dart';
import 'package:ezpc_tasks_app/features/services/presentation/componentaddservices/schedule_selection_days_widget.dart';
import 'package:ezpc_tasks_app/features/services/presentation/componentaddservices/schedule_selection_hours_widget.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/customcheckbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/features/services/data/task_provider.dart';
import 'package:ezpc_tasks_app/features/services/models/task_model.dart';

class ScheduleStep extends ConsumerStatefulWidget {
  final GlobalKey<FormState> formKey;

  const ScheduleStep({super.key, required this.formKey});

  @override
  _ScheduleStepState createState() => _ScheduleStepState();
}

class _ScheduleStepState extends ConsumerState<ScheduleStep> {
  @override
  Widget build(BuildContext context) {
    // Acceder a la `currentTask` desde el estado
    final taskState = ref.watch(taskProvider);
    final specialDaysEnabled = ref.watch(specialDaysEnabledProvider);
    final Task? currentTask = taskState.currentTask;

    return Form(
      key: widget.formKey, // Usar formKey para validación
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Selección de días de trabajo
            DaysSelector(
              initialSelection: currentTask?.workingDays ?? [],
              onDaysSelected: (List<String> selectedDays) {
                if (currentTask != null) {
                  ref.read(taskProvider.notifier).updateTask(
                        workingDays: selectedDays,
                      );
                }
              },
            ),
            Utils.verticalSpace(10),

            // Validar que se hayan seleccionado días de trabajo
            if (currentTask?.workingDays == null ||
                currentTask!.workingDays.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Please select working days',
                  style: TextStyle(color: Colors.red),
                ),
              ),

            // Selección de horas de trabajo
            WorkingHoursSelector(
              initialHours: currentTask?.workingHours,
              onHoursSelected: (Map<String, Map<String, String>> workingHours) {
                if (currentTask != null) {
                  ref.read(taskProvider.notifier).updateTask(
                        workingHours: workingHours,
                      );
                }
              },
            ),
            Utils.verticalSpace(10),

            // Validar que se hayan seleccionado horas de trabajo
            if (currentTask?.workingHours == null ||
                currentTask!.workingHours.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Please select working hours',
                  style: TextStyle(color: Colors.red),
                ),
              ),

            // Selector de días especiales
            CustomCheckboxListTile(
              title: 'Special days',
              value: specialDaysEnabled,
              onChanged: (bool? value) {
                ref.read(specialDaysEnabledProvider.notifier).state =
                    value ?? false;
              },
            ),
          ],
        ),
      ),
    );
  }
}
