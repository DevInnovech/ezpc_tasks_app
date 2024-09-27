import 'package:ezpc_tasks_app/features/services/data/add_repository.dart';
import 'package:ezpc_tasks_app/features/services/data/task_provider.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/widgets/customcheckbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DaysSelector extends ConsumerStatefulWidget {
  final List<String> initialSelection;
  final void Function(List<String> selectedDays) onDaysSelected;

  const DaysSelector({
    super.key,
    required this.initialSelection,
    required this.onDaysSelected,
  });

  @override
  _DaysSelectorState createState() => _DaysSelectorState();
}

class _DaysSelectorState extends ConsumerState<DaysSelector> {
  @override
  void initState() {
    super.initState();
    // Inicializa el estado con una lista vacía al iniciar
    Future.microtask(() {
      ref.read(selectedDaysProvider.notifier).state = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos la lista de días seleccionados del estado.
    final selectedDays = ref.watch(selectedDaysProvider);

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
            'Days',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          childrenPadding: EdgeInsets.zero,
          tilePadding: EdgeInsets.zero,
          collapsedIconColor: primaryColor,
          iconColor: primaryColor,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomCheckboxListTile(
                        title: 'Monday',
                        value: selectedDays.contains('Monday'),
                        onChanged: (bool? value) {
                          _toggleDaySelection(ref, 'Monday', value);
                        },
                        activeColor: primaryColor,
                        checkColor: Colors.white,
                        titleColor: Colors.grey,
                      ),
                      CustomCheckboxListTile(
                        title: 'Tuesday',
                        value: selectedDays.contains('Tuesday'),
                        onChanged: (bool? value) {
                          _toggleDaySelection(ref, 'Tuesday', value);
                        },
                        activeColor: primaryColor,
                        checkColor: Colors.white,
                        titleColor: Colors.grey,
                      ),
                      CustomCheckboxListTile(
                        title: 'Wednesday',
                        value: selectedDays.contains('Wednesday'),
                        onChanged: (bool? value) {
                          _toggleDaySelection(ref, 'Wednesday', value);
                        },
                        activeColor: primaryColor,
                        checkColor: Colors.white,
                        titleColor: Colors.grey,
                      ),
                      CustomCheckboxListTile(
                        title: 'Thursday',
                        value: selectedDays.contains('Thursday'),
                        onChanged: (bool? value) {
                          _toggleDaySelection(ref, 'Thursday', value);
                        },
                        activeColor: primaryColor,
                        checkColor: Colors.white,
                        titleColor: Colors.grey,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomCheckboxListTile(
                        title: 'Friday',
                        value: selectedDays.contains('Friday'),
                        onChanged: (bool? value) {
                          _toggleDaySelection(ref, 'Friday', value);
                        },
                        activeColor: primaryColor,
                        checkColor: Colors.white,
                        titleColor: Colors.grey,
                      ),
                      CustomCheckboxListTile(
                        title: 'Saturday',
                        value: selectedDays.contains('Saturday'),
                        onChanged: (bool? value) {
                          _toggleDaySelection(ref, 'Saturday', value);
                        },
                        activeColor: primaryColor,
                        checkColor: Colors.white,
                        titleColor: Colors.grey,
                      ),
                      CustomCheckboxListTile(
                        title: 'Sunday',
                        value: selectedDays.contains('Sunday'),
                        onChanged: (bool? value) {
                          _toggleDaySelection(ref, 'Sunday', value);
                        },
                        activeColor: primaryColor,
                        checkColor: Colors.white,
                        titleColor: Colors.grey,
                      ),
                      CustomCheckboxListTile(
                        title: 'All days',
                        value: selectedDays.length ==
                            7, // Si los 7 días están seleccionados, marcamos "All days"
                        onChanged: (bool? value) {
                          _toggleDaySelection(ref, 'All days', value);
                        },
                        activeColor: primaryColor,
                        checkColor: Colors.white,
                        titleColor: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Método único para manejar la selección de días individuales y de todos los días
  void _toggleDaySelection(WidgetRef ref, String day, bool? isSelected) {
    final selectedDays = ref.read(selectedDaysProvider.notifier).state;

    if (day == 'All days') {
      // Si el día es "All days", seleccionamos o deseleccionamos todos los días
      if (isSelected == true) {
        ref.read(selectedDaysProvider.notifier).state = [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday'
        ];
      } else {
        ref.read(selectedDaysProvider.notifier).state = [];
      }
    } else {
      // Si no es "All days", actualizamos los días individuales
      if (isSelected == true) {
        ref.read(selectedDaysProvider.notifier).state = [...selectedDays, day];
      } else {
        ref.read(selectedDaysProvider.notifier).state =
            selectedDays.where((d) => d != day).toList();
      }
    }

    // Actualizamos el taskProvider para reflejar los cambios
    Future.microtask(() {
      ref.read(taskProvider.notifier).updateTask((currentTask) {
        return currentTask!.copyWith(
          workingDays: ref.read(selectedDaysProvider.notifier).state,
        );
      });
    });
  }
}
