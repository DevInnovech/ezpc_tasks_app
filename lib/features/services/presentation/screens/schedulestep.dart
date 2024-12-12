import 'package:ezpc_tasks_app/features/services/data/add_repository.dart';
import 'package:ezpc_tasks_app/features/services/presentation/componentaddservices/schedule_selection_days_widget.dart';
import 'package:ezpc_tasks_app/features/services/presentation/componentaddservices/schedule_selection_hours_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/features/services/data/task_provider.dart';
import 'package:ezpc_tasks_app/shared/widgets/customcheckbox.dart';

class ScheduleStep extends ConsumerStatefulWidget {
  final GlobalKey<FormState> formKey;

  const ScheduleStep({super.key, required this.formKey});

  @override
  _ScheduleStepState createState() => _ScheduleStepState();
}

class _ScheduleStepState extends ConsumerState<ScheduleStep> {
  final String _defaultStartHour = '8:00 AM';
  final String _defaultEndHour = '8:00 PM';

  @override
  Widget build(BuildContext context) {
    final selectedDays = ref.watch(selectedDaysProvider);
    final specialDaysEnabled = ref.watch(specialDaysEnabledProvider);

    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selector de días
            DaysSelector(
              initialSelection: selectedDays,
              onDaysSelected: (selectedDays) {
                ref.read(selectedDaysProvider.notifier).state = selectedDays;
                _initializeDefaultWorkingHours(selectedDays);
              },
            ),
            const SizedBox(height: 16),

            // Selector de horas
            if (selectedDays.isNotEmpty)
              WorkingHoursSelector(
                selectedDays: selectedDays,
                onHoursSelected: (workingHours) {
                  if (_validateWorkingHours(workingHours)) {
                    ref.read(taskProvider.notifier).updateTask(
                          workingDays: selectedDays,
                          workingHours: workingHours,
                        );
                  } else {
                    _showSnackBar(context,
                        "Invalid hours! Start time must be before end time.");
                  }
                },
              ),
            const SizedBox(height: 16),

            // Checkbox para habilitar días especiales
            CustomCheckboxListTile(
              title: 'Enable Special Days',
              value: specialDaysEnabled,
              onChanged: (value) {
                ref.read(specialDaysEnabledProvider.notifier).state =
                    value ?? false;
              },
              activeColor: Colors.blue,
            ),
            const SizedBox(height: 16),

            // Botón de guardar
            ElevatedButton(
              onPressed: () {
                if (selectedDays.isEmpty) {
                  _showSnackBar(
                      context, "Please select at least one working day.");
                  return;
                }

                final workingHours = _getWorkingHoursFromProvider(selectedDays);

                if (!_validateWorkingHours(workingHours)) {
                  _showSnackBar(context,
                      "Invalid hours! Start time must be before end time.");
                  return;
                }

                ref.read(taskProvider.notifier).updateTask(
                      workingDays: selectedDays,
                      workingHours: workingHours,
                    );

                _showSnackBar(context, "Working hours updated successfully!",
                    isError: false);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  void _initializeDefaultWorkingHours(List<String> selectedDays) {
    final currentTask = ref.read(taskProvider).currentTask;

    final Map<String, Map<String, String>> workingHours =
        currentTask?.workingHours ?? {};
    for (var day in selectedDays) {
      workingHours[day] ??= {
        'start': _defaultStartHour,
        'end': _defaultEndHour,
      };
    }

    ref.read(taskProvider.notifier).updateTask(workingHours: workingHours);
  }

  Map<String, Map<String, String>> _getWorkingHoursFromProvider(
      List<String> selectedDays) {
    final currentTask = ref.read(taskProvider).currentTask;

    if (currentTask == null) {
      return {};
    }

    final workingHours = currentTask.workingHours;

    // Filtrar el mapa utilizando `entries` y convertir de nuevo a un mapa
    return Map.fromEntries(
      workingHours.entries.where((entry) => selectedDays.contains(entry.key)),
    );
  }

  bool _validateWorkingHours(Map<String, Map<String, String>> workingHours) {
    for (var entry in workingHours.entries) {
      final startTime = entry.value['start'] ?? '';
      final endTime = entry.value['end'] ?? '';
      if (!_isValidTimeRange(startTime, endTime)) {
        return false;
      }
    }
    return true;
  }

  bool _isValidTimeRange(String startTime, String endTime) {
    final start = _parseTime(startTime);
    final end = _parseTime(endTime);
    return start != null && end != null && start.isBefore(end);
  }

  DateTime? _parseTime(String time) {
    try {
      final format = TimeOfDay(
        hour: int.parse(time.split(':')[0]),
        minute: int.parse(time.split(':')[1].split(' ')[0]),
      );
      return DateTime(0, 0, 0, format.hour, format.minute);
    } catch (e) {
      return null;
    }
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = true}) {
    final color = isError ? Colors.red : Colors.green;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
