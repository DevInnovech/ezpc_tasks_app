import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import 'package:ezpc_tasks_app/features/services/data/task_provider.dart';
import 'package:ezpc_tasks_app/features/services/models/task_model.dart';

class SpecialDaysStep extends ConsumerWidget {
  final GlobalKey<FormState> formKey; // Añadimos el formKey

  const SpecialDaysStep(
      {super.key, required this.formKey}); // Recibimos formKey

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskProvider);
    final Task? currentTask = taskState.currentTask;
    final specialDays = currentTask?.specialDays ?? [];

    return Form(
      // Usamos el formKey en un Form
      key: formKey, // Añadimos formKey aquí
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Special Days',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
            const SizedBox(height: 10),
            ...specialDays.map((day) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              day['date'] ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              '${day['startTime']} To ${day['endTime']}',
                              style: const TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          if (currentTask != null) {
                            final updatedSpecialDays =
                                List<Map<String, String>>.from(
                                    currentTask.specialDays);
                            updatedSpecialDays.remove(day);

                            ref.read(taskProvider.notifier).updateTask(
                                  specialDays: updatedSpecialDays,
                                );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
            ListTile(
              leading: const Icon(Icons.add, color: Colors.deepPurple),
              title: const Text(
                'Add New Special Day',
                style: TextStyle(color: Colors.deepPurple),
              ),
              onTap: () {
                _showAddSpecialDayDialog(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSpecialDayDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController dateController = TextEditingController();
    final TextEditingController startTimeController = TextEditingController();
    final TextEditingController endTimeController = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Add New Special Day'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDatePicker(context, dateController),
                  const SizedBox(height: 10),
                  _buildTimePicker(context, startTimeController, "Start Time"),
                  const SizedBox(height: 10),
                  _buildTimePicker(context, endTimeController, "End Time"),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text("Add"),
                  onPressed: () {
                    final date = dateController.text;
                    final startTime = startTimeController.text;
                    final endTime = endTimeController.text;

                    if (date.isEmpty || startTime.isEmpty || endTime.isEmpty) {
                      setState(() {
                        errorMessage = 'Please fill all fields';
                      });
                    } else {
                      final startTimeParsed =
                          _parseTimeOfDay(startTime, context);
                      final endTimeParsed = _parseTimeOfDay(endTime, context);

                      if (startTimeParsed != null &&
                          endTimeParsed != null &&
                          _compareTimeOfDay(startTimeParsed, endTimeParsed) >=
                              0) {
                        setState(() {
                          errorMessage = 'Start time must be before end time';
                        });
                      } else {
                        final newDay = {
                          'date': date,
                          'startTime': startTime,
                          'endTime': endTime,
                        };

                        final taskState = ref.read(taskProvider);
                        final Task? currentTask = taskState.currentTask;

                        if (currentTask != null) {
                          final updatedSpecialDays =
                              List<Map<String, String>>.from(
                                  currentTask.specialDays);
                          updatedSpecialDays.add(newDay);

                          ref.read(taskProvider.notifier).updateTask(
                                specialDays: updatedSpecialDays,
                              );
                        }
                        Navigator.of(context).pop();
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDatePicker(
      BuildContext context, TextEditingController controller) {
    return Platform.isIOS
        ? CupertinoButton(
            child:
                Text(controller.text.isEmpty ? "Select Date" : controller.text),
            onPressed: () async {
              showCupertinoModalPopup(
                context: context,
                builder: (context) {
                  return Container(
                    height: 216,
                    padding: const EdgeInsets.only(top: 6.0),
                    margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    color:
                        CupertinoColors.systemBackground.resolveFrom(context),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: DateTime.now(),
                      onDateTimeChanged: (DateTime newDateTime) {
                        controller.text =
                            "${newDateTime.toLocal()}".split(' ')[0];
                      },
                    ),
                  );
                },
              );
            },
          )
        : TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: "Date"),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                controller.text = "${pickedDate.toLocal()}".split(' ')[0];
              }
            },
          );
  }

  Widget _buildTimePicker(
      BuildContext context, TextEditingController controller, String label) {
    return Platform.isIOS
        ? CupertinoButton(
            child: Text(controller.text.isEmpty ? label : controller.text),
            onPressed: () async {
              showCupertinoModalPopup(
                context: context,
                builder: (context) {
                  return Container(
                    height: 216,
                    padding: const EdgeInsets.only(top: 6.0),
                    margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    color:
                        CupertinoColors.systemBackground.resolveFrom(context),
                    child: CupertinoTimerPicker(
                      mode: CupertinoTimerPickerMode.hm,
                      onTimerDurationChanged: (Duration duration) {
                        final time = TimeOfDay(
                            hour: duration.inHours,
                            minute: duration.inMinutes % 60);
                        controller.text = time.format(context);
                      },
                    ),
                  );
                },
              );
            },
          )
        : TextField(
            controller: controller,
            decoration: InputDecoration(labelText: label),
            onTap: () async {
              TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime != null) {
                controller.text = pickedTime.format(context);
              }
            },
          );
  }

  TimeOfDay? _parseTimeOfDay(String time, BuildContext context) {
    try {
      final split = time.split(":");
      final hour = int.parse(split[0]);
      final minute = int.parse(split[1]);
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }

  int _compareTimeOfDay(TimeOfDay t1, TimeOfDay t2) {
    return (t1.hour * 60 + t1.minute) - (t2.hour * 60 + t2.minute);
  }
}
