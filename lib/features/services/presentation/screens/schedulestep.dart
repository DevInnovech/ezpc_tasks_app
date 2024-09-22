import 'package:ezpc_tasks_app/features/services/data/add_repository.dart';
import 'package:ezpc_tasks_app/features/services/presentation/componentaddservices/schedule_selection_days_widget.dart';
import 'package:ezpc_tasks_app/features/services/presentation/componentaddservices/schedule_selection_hours_widget.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/customcheckbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/features/services/data/task_provider.dart';
import 'package:ezpc_tasks_app/features/services/models/task_model.dart';
import 'package:uuid/uuid.dart';

class ScheduleStep extends ConsumerWidget {
  const ScheduleStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final specialDaysEnabled = ref.watch(specialDaysEnabledProvider);
    final task = ref.watch(taskProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          DaysSelector(
            initialSelection: task?.workingDays ?? [],
            onDaysSelected: (List<String> selectedDays) {
              ref.read(taskProvider.notifier).updateTask((currentTask) {
                return Task(
                  id: currentTask?.id ?? const Uuid().v4(),
                  name: currentTask?.name ?? '',
                  category: currentTask?.category ?? '',
                  subCategory: currentTask?.subCategory ?? '',
                  price: currentTask?.price ?? 0.0,
                  imageUrl: currentTask?.imageUrl ?? '',
                  requiresLicense: currentTask?.requiresLicense ?? false,
                  workingDays: selectedDays,
                  workingHours: currentTask?.workingHours ?? {},
                  specialDays: currentTask?.specialDays ?? [],
                  licenseType: '',
                  licenseNumber: '',
                  licenseExpirationDate: '',
                  phone: '',
                  service: '',
                  issueDate: '',
                  documentUrl: '',
                );
              });
            },
          ),
          Utils.verticalSpace(10),
          WorkingHoursSelector(
            initialHours: task?.workingHours,
            onHoursSelected: (Map<String, Map<String, String>> workingHours) {
              ref.read(taskProvider.notifier).updateTask((currentTask) {
                return Task(
                  id: currentTask?.id ?? const Uuid().v4(),
                  name: currentTask?.name ?? '',
                  category: currentTask?.category ?? '',
                  subCategory: currentTask?.subCategory ?? '',
                  price: currentTask?.price ?? 0.0,
                  imageUrl: currentTask?.imageUrl ?? '',
                  requiresLicense: currentTask?.requiresLicense ?? false,
                  workingDays: currentTask?.workingDays ?? [],
                  workingHours: workingHours,
                  specialDays: currentTask?.specialDays ?? [],
                  licenseType: '',
                  licenseNumber: '',
                  licenseExpirationDate: '',
                  phone: '',
                  service: '',
                  issueDate: '',
                  documentUrl: '',
                );
              });
            },
          ),
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
    );
  }
}
