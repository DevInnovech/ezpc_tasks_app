import 'package:ezpc_tasks_app/features/services/data/add_repositoey.dart';
import 'package:ezpc_tasks_app/features/services/presentation/componentaddservices/schedule_selection_days_widget.dart';
import 'package:ezpc_tasks_app/features/services/presentation/componentaddservices/schedule_selection_hours_widget.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/customcheckbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScheduleStep extends ConsumerWidget {
  const ScheduleStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final specialDaysEnabled = ref.watch(specialDaysEnabledProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const DaysSelector(),
          Utils.verticalSpace(10),
          const WorkingHoursSelector(),
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
