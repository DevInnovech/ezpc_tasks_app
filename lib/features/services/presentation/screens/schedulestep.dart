import 'package:ezpc_tasks_app/features/services/data/add_repository.dart';
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
  final Map<String, Map<String, String>> _workingHours = {};
  final List<String> _selectedDays = [];

  @override
  void initState() {
    super.initState();
    final currentTask = ref.read(taskProvider).currentTask;

    if (currentTask != null) {
      // Inicializar los días y horas del estado actual
      setState(() {
        _selectedDays.addAll(currentTask.workingDays ?? []);
        _workingHours.addAll(currentTask.workingHours ?? {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final specialDaysEnabled = ref.watch(specialDaysEnabledProvider);

    final List<String> daysOfWeek = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];

    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Working Days & Hours",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Selección de días y horas
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: daysOfWeek.length,
              itemBuilder: (context, index) {
                final day = daysOfWeek[index];
                final hours = _workingHours[day] ?? {"start": "", "end": ""};

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(day, style: const TextStyle(fontSize: 16)),
                            Switch(
                              value: _selectedDays.contains(day),
                              onChanged: (bool value) {
                                setState(() {
                                  if (value) {
                                    _selectedDays.add(day);
                                    _workingHours[day] = {
                                      "start": "",
                                      "end": ""
                                    };
                                  } else {
                                    _selectedDays.remove(day);
                                    _workingHours.remove(day);
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        if (_selectedDays.contains(day))
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    final TimeOfDay? pickedTime =
                                        await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    if (pickedTime != null) {
                                      setState(() {
                                        _workingHours[day]!["start"] =
                                            pickedTime.format(context);
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _workingHours[day]!["start"]!.isEmpty
                                          ? "Start Time"
                                          : _workingHours[day]!["start"]!,
                                      style: const TextStyle(
                                          color: Colors.black54),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    final TimeOfDay? pickedTime =
                                        await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    if (pickedTime != null) {
                                      setState(() {
                                        _workingHours[day]!["end"] =
                                            pickedTime.format(context);
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _workingHours[day]!["end"]!.isEmpty
                                          ? "End Time"
                                          : _workingHours[day]!["end"]!,
                                      style: const TextStyle(
                                          color: Colors.black54),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Habilitar días especiales
            CustomCheckboxListTile(
              title: 'Enable Special Days',
              value: specialDaysEnabled,
              onChanged: (bool? value) {
                ref.read(specialDaysEnabledProvider.notifier).state =
                    value ?? false;
              },
            ),

            const SizedBox(height: 16),

            // Botón guardar
            ElevatedButton(
              onPressed: () {
                if (_selectedDays.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please select at least one working day."),
                    ),
                  );
                  return;
                }

                // Actualizar estado del taskProvider
                ref.read(taskProvider.notifier).updateTask(
                      workingDays: _selectedDays,
                      workingHours: _workingHours,
                    );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Working hours updated successfully!"),
                  ),
                );
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
