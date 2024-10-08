import 'package:ezpc_tasks_app/features/services/data/add_repository.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/widgets/customcheckbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkingHoursSelector extends ConsumerWidget {
  const WorkingHoursSelector({
    super.key,
    Map<String, Map<String, String>>? initialHours,
    required Null Function(Map<String, Map<String, String>> workingHours)
        onHoursSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtenemos el estado de las horas de trabajo y los días seleccionados
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
                  // Seleccionar "All Days" y actualizar los días seleccionados
                  ref.read(selectedDaysProvider.notifier).state = [
                    'Monday',
                    'Tuesday',
                    'Wednesday',
                    'Thursday',
                    'Friday',
                    'Saturday',
                    'Sunday',
                    'All days'
                  ];
                } else {
                  // Deseleccionar "All days" sin modificar los días ya seleccionados
                  ref.read(selectedDaysProvider.notifier).state =
                      selectedDays.where((d) => d != 'All days').toList();
                }
              },
            ),
            if (allDaysSelected)
              // Si se selecciona "All Days", mostrar solo un formulario
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
              // Si no se selecciona "All Days", mostrar solo los días seleccionados
              ...selectedDays
                  .where((day) => day != 'All days')
                  .map((day) => ListTile(
                        title: Text(
                          day,
                          style: const TextStyle(color: Colors.black),
                        ),
                        subtitle: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: workingHours[day]?['start'],
                                decoration: const InputDecoration(
                                  labelText: "Start",
                                ),
                                onChanged: (value) {
                                  ref
                                      .read(workingHoursProvider.notifier)
                                      .update((state) {
                                    state[day]?['start'] = value;
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
                                initialValue: workingHours[day]?['end'],
                                decoration: const InputDecoration(
                                  labelText: "End",
                                ),
                                onChanged: (value) {
                                  ref
                                      .read(workingHoursProvider.notifier)
                                      .update((state) {
                                    state[day]?['end'] = value;
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
                            _editWorkingHours(
                                context, ref, day, workingHours[day] ?? {});
                          },
                        ),
                      ))
                  .toList(),
          ],
        ),
      ),
    );
  }

  // Función para editar las horas de trabajo.
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

                  // Si se actualiza "All days", se reflejan los cambios en todos los días
                  if (day == 'All days') {
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
