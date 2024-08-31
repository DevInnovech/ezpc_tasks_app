import 'package:ezpc_tasks_app/features/services/data/add_repositoey.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/widgets/customcheckbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkingHoursSelector extends ConsumerWidget {
  const WorkingHoursSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workingHours = ref.watch(workingHoursProvider);
    final selectedDays = ref.watch(selectedDaysProvider);
    final allDaysSelected = selectedDays.contains('All days');

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: scaffoldBgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          title: const Text(
            'Working Hours',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          childrenPadding: EdgeInsets.zero,
          tilePadding: EdgeInsets.zero,
          collapsedIconColor: primaryColor,
          iconColor: primaryColor,
          children: [
            // Checkbox para aplicar el mismo horario a todos los días
            CustomCheckboxListTile(
              title: "Apply to All Days",
              value: allDaysSelected,
              onChanged: (bool? value) {
                if (value == true) {
                  // Seleccionar todos los días y aplicar el horario de "All days"
                  ref.read(selectedDaysProvider.notifier).update((state) {
                    return [
                      'Monday',
                      'Tuesday',
                      'Wednesday',
                      'Thursday',
                      'Friday',
                      'Saturday',
                      'Sunday',
                      'All days'
                    ];
                  });
                } else {
                  // Deseleccionar "All days"
                  ref.read(selectedDaysProvider.notifier).update((state) {
                    return state.where((d) => d != 'All days').toList();
                  });
                }
              },
            ),

            if (allDaysSelected)
              // Mostrar solo el formulario para "All days"
              ListTile(
                title: const Text(
                  "All days",
                  style: TextStyle(color: Colors.black),
                ),
                subtitle: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: workingHours["All days"]?['start'],
                        decoration: const InputDecoration(
                          labelText: "Start",
                        ),
                        onChanged: (value) {
                          ref
                              .read(workingHoursProvider.notifier)
                              .update((state) {
                            for (var key in state.keys) {
                              state[key]?['start'] = value;
                            }
                            return state;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text("To"),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        initialValue: workingHours["All days"]?['end'],
                        decoration: const InputDecoration(
                          labelText: "End",
                        ),
                        onChanged: (value) {
                          ref
                              .read(workingHoursProvider.notifier)
                              .update((state) {
                            for (var key in state.keys) {
                              state[key]?['end'] = value;
                            }
                            return state;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _editWorkingHours(context, ref, "All days",
                        workingHours["All days"] ?? {});
                  },
                ),
              )
            else
              ...workingHours.entries.map((entry) {
                final isEnabled = selectedDays.contains(entry.key);

                return Opacity(
                  opacity: isEnabled ? 1.0 : 0.5,
                  child: ListTile(
                    title: Text(
                      entry.key,
                      style: const TextStyle(color: Colors.black),
                    ),
                    subtitle: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: entry.value['start'],
                            decoration: const InputDecoration(
                              labelText: "Start",
                            ),
                            enabled: isEnabled,
                            onChanged: (value) {
                              if (isEnabled) {
                                ref
                                    .read(workingHoursProvider.notifier)
                                    .update((state) {
                                  state[entry.key]?['start'] = value;
                                  return state;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text("To"),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            initialValue: entry.value['end'],
                            decoration: const InputDecoration(
                              labelText: "End",
                            ),
                            enabled: isEnabled,
                            onChanged: (value) {
                              if (isEnabled) {
                                ref
                                    .read(workingHoursProvider.notifier)
                                    .update((state) {
                                  state[entry.key]?['end'] = value;
                                  return state;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    trailing: isEnabled
                        ? IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _editWorkingHours(
                                  context, ref, entry.key, entry.value);
                            },
                          )
                        : null,
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  void _editWorkingHours(BuildContext context, WidgetRef ref, String day,
      Map<String, String> times) {
    TextEditingController startController =
        TextEditingController(text: times['start']);
    TextEditingController endController =
        TextEditingController(text: times['end']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Working Hours for $day'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: startController,
                decoration: const InputDecoration(
                  labelText: "Start Time",
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: endController,
                decoration: const InputDecoration(
                  labelText: "End Time",
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
              child: const Text("Save"),
              onPressed: () {
                ref.read(workingHoursProvider.notifier).update((state) {
                  state[day]?['start'] = startController.text;
                  state[day]?['end'] = endController.text;

                  if (day == 'All days') {
                    // Actualiza todos los días con el mismo horario
                    for (var key in state.keys) {
                      state[key]?['start'] = startController.text;
                      state[key]?['end'] = endController.text;
                    }
                  }

                  return state;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
