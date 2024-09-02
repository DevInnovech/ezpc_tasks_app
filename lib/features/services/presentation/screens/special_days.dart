import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';

// Modelo para SpecialDay
class SpecialDay {
  final String date;
  final String startTime;
  final String endTime;
  bool isActive;

  SpecialDay({
    required this.date,
    required this.startTime,
    required this.endTime,
    this.isActive = true,
  });
}

// Proveedor para la lista de días especiales
final specialDaysProvider = StateProvider<List<SpecialDay>>((ref) {
  return [
    SpecialDay(
        date: "Day", startTime: "0:00 am", endTime: "0:00 pm", isActive: false)
  ];
});

class SpecialDaysStep extends ConsumerWidget {
  const SpecialDaysStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final specialDays = ref.watch(specialDaysProvider.state).state;

    return Container(
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
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
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
                    Checkbox(
                      value: day.isActive,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      onChanged: (value) {
                        ref.read(specialDaysProvider.state).state =
                            specialDays.map((d) {
                          if (d == day) {
                            return SpecialDay(
                              date: d.date,
                              startTime: d.startTime,
                              endTime: d.endTime,
                              isActive: value ?? false,
                            );
                          }
                          return d;
                        }).toList();
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            day.date,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          Text(
                            '${day.startTime} To ${day.endTime}',
                            style: TextStyle(
                              color: day.isActive ? Colors.black : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (day.isActive)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          ref.read(specialDaysProvider.state).state =
                              specialDays.where((d) => d != day).toList();
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
    );
  }

  void _showAddSpecialDayDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController dateController = TextEditingController();
    final TextEditingController startTimeController = TextEditingController();
    final TextEditingController endTimeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                final newDay = SpecialDay(
                  date: dateController.text,
                  startTime: startTimeController.text,
                  endTime: endTimeController.text,
                );
                ref.read(specialDaysProvider.state).state = [
                  ...ref.read(specialDaysProvider.state).state,
                  newDay
                ];
                Navigator.of(context).pop();
              },
            ),
          ],
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
                        final now = DateTime.now();
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
}
