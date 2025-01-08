import 'package:ezpc_tasks_app/features/services/data/add_repository.dart';
import 'package:ezpc_tasks_app/features/services/presentation/componentaddservices/schedule_selection_days_widget.dart';
import 'package:ezpc_tasks_app/features/services/presentation/componentaddservices/schedule_selection_hours_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/features/services/data/task_provider.dart';
import 'package:ezpc_tasks_app/shared/widgets/customcheckbox.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
              onDaysSelected: (updatedDays) {
                ref.read(selectedDaysProvider.notifier).state = updatedDays;
                _initializeDefaultWorkingHours(updatedDays);
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
            /*ElevatedButton(
              onPressed: () async {
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

                // Guardar datos en Firebase
                await _saveScheduleToFirebase(
                    selectedDays: selectedDays, workingHours: workingHours);

                _showSnackBar(context, "Working hours updated successfully!",
                    isError: false);
              },
              child: const Text("Save"),
            ),*/
          ],
        ),
      ),
    );
  }

  void _initializeDefaultWorkingHours(List<String> selectedDays) {
    final currentTask = ref.read(taskProvider).currentTask;

    // Obtén las horas de trabajo actuales o inicializa un mapa vacío
    final Map<String, Map<String, String>> workingHours =
        currentTask?.workingHours.map((key, value) =>
                MapEntry(key, Map<String, String>.from(value))) ??
            {};

    // Itera sobre los días seleccionados y establece valores predeterminados si no existen
    for (var day in selectedDays) {
      workingHours[day] ??= {
        'start': _defaultStartHour,
        'end': _defaultEndHour,
      };
    }

    // Actualiza el task con los nuevos workingHours
    ref.read(taskProvider.notifier).updateTask(workingHours: workingHours);
  }

  Map<String, Map<String, String>> _getWorkingHoursFromProvider(
      List<String> selectedDays) {
    final currentTask = ref.read(taskProvider).currentTask;

    if (currentTask == null) {
      return {};
    }

    final workingHours = currentTask.workingHours;

    // Filtrar las entradas y reconstruir el mapa asegurando el tipo correcto
    return Map.fromEntries(
      workingHours.entries
          .where((entry) => selectedDays.contains(entry.key))
          .map((entry) => MapEntry(
                entry.key,
                Map<String, String>.from(entry.value),
              )),
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
      final timeOfDay = TimeOfDay(
        hour: int.parse(time.split(':')[0]),
        minute: int.parse(time.split(':')[1].split(' ')[0]),
      );
      return DateTime(0, 0, 0, timeOfDay.hour, timeOfDay.minute);
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveScheduleToFirebase({
    required List<String> selectedDays,
    required Map<String, Map<String, String>> workingHours,
  }) async {
    try {
      final taskProviderData = ref.read(taskProvider).currentTask;

      if (taskProviderData == null) {
        _showSnackBar(context, "No task found for updating schedule!");
        return;
      }

      // Actualizar en Firebase
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(taskProviderData.taskId)
          .update({
        'workingDays': selectedDays,
        'workingHours': workingHours,
      });

      _showSnackBar(context, "Schedule saved to Firebase successfully!",
          isError: false);
    } catch (e) {
      _showSnackBar(context, "Failed to save schedule to Firebase.");
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
