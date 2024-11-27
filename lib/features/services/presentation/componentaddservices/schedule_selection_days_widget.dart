import 'package:ezpc_tasks_app/features/services/data/add_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/shared/widgets/customcheckbox.dart';

// Definición del widget `DaysSelector`
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
    // Inicializar el estado de los días seleccionados con `initialSelection`
    Future.microtask(() {
      ref.read(selectedDaysProvider.notifier).state = widget.initialSelection;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtener la lista de días seleccionados del estado
    final selectedDays = ref.watch(selectedDaysProvider);

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
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
          collapsedIconColor: Colors.blue,
          iconColor: Colors.blue,
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
                          _toggleDaySelection('Monday', value);
                        },
                        activeColor: Colors.blue,
                        checkColor: Colors.white,
                      ),
                      CustomCheckboxListTile(
                        title: 'Tuesday',
                        value: selectedDays.contains('Tuesday'),
                        onChanged: (bool? value) {
                          _toggleDaySelection('Tuesday', value);
                        },
                        activeColor: Colors.blue,
                        checkColor: Colors.white,
                      ),
                      CustomCheckboxListTile(
                        title: 'Wednesday',
                        value: selectedDays.contains('Wednesday'),
                        onChanged: (bool? value) {
                          _toggleDaySelection('Wednesday', value);
                        },
                        activeColor: Colors.blue,
                        checkColor: Colors.white,
                      ),
                      CustomCheckboxListTile(
                        title: 'Thursday',
                        value: selectedDays.contains('Thursday'),
                        onChanged: (bool? value) {
                          _toggleDaySelection('Thursday', value);
                        },
                        activeColor: Colors.blue,
                        checkColor: Colors.white,
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
                          _toggleDaySelection('Friday', value);
                        },
                        activeColor: Colors.blue,
                        checkColor: Colors.white,
                      ),
                      CustomCheckboxListTile(
                        title: 'Saturday',
                        value: selectedDays.contains('Saturday'),
                        onChanged: (bool? value) {
                          _toggleDaySelection('Saturday', value);
                        },
                        activeColor: Colors.blue,
                        checkColor: Colors.white,
                      ),
                      CustomCheckboxListTile(
                        title: 'Sunday',
                        value: selectedDays.contains('Sunday'),
                        onChanged: (bool? value) {
                          _toggleDaySelection('Sunday', value);
                        },
                        activeColor: Colors.blue,
                        checkColor: Colors.white,
                      ),
                      CustomCheckboxListTile(
                        title: 'All days',
                        value: selectedDays.length == 7,
                        onChanged: (bool? value) {
                          _toggleDaySelection('All days', value);
                        },
                        activeColor: Colors.blue,
                        checkColor: Colors.white,
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

  // Método para manejar la selección de días
  void _toggleDaySelection(String day, bool? isSelected) {
    // Obtener la lista actual de `selectedDays`
    final selectedDays = ref.read(selectedDaysProvider.notifier).state;

    if (day == 'All days') {
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
      if (isSelected == true) {
        ref.read(selectedDaysProvider.notifier).state = [...selectedDays, day];
      } else {
        ref.read(selectedDaysProvider.notifier).state =
            selectedDays.where((d) => d != day).toList();
      }
    }

    // Notificar los días seleccionados para el `WorkingHoursSelector`
    widget.onDaysSelected(ref.read(selectedDaysProvider.notifier).state);
  }
}
