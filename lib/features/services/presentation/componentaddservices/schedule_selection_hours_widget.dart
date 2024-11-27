import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkingHoursSelector extends ConsumerStatefulWidget {
  final void Function(Map<String, Map<String, String>> workingHours)
      onHoursSelected;
  final List<String> selectedDays; // Días seleccionados

  const WorkingHoursSelector({
    super.key,
    required this.onHoursSelected,
    required this.selectedDays,
  });

  @override
  _WorkingHoursSelectorState createState() => _WorkingHoursSelectorState();
}

class _WorkingHoursSelectorState extends ConsumerState<WorkingHoursSelector> {
  // Mapa para mantener el estado de las horas de trabajo en tiempo real
  final Map<String, Map<String, String>> _workingHours = {};

  // Valor por defecto para las horas de trabajo
  final String _defaultStartHour = '8:00 AM';
  final String _defaultEndHour = '8:00 PM';

  @override
  void initState() {
    super.initState();
    _initializeWorkingHours();
  }

  @override
  void didUpdateWidget(WorkingHoursSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si los días seleccionados cambian, actualizar las horas correspondientes
    if (widget.selectedDays != oldWidget.selectedDays) {
      _initializeWorkingHours();
    }
  }

  void _initializeWorkingHours() {
    // Actualizar el estado de `workingHours` basado en los días seleccionados
    setState(() {
      for (var day in widget.selectedDays) {
        if (!_workingHours.containsKey(day)) {
          _workingHours[day] = {
            'start': _defaultStartHour,
            'end': _defaultEndHour,
          };
        }
      }
      // Eliminar días que ya no están seleccionados
      _workingHours.removeWhere((day, _) => !widget.selectedDays.contains(day));
    });
  }

  @override
  Widget build(BuildContext context) {
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
            'Working Hours',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          childrenPadding: EdgeInsets.zero,
          tilePadding: EdgeInsets.zero,
          collapsedIconColor: Colors.blue,
          iconColor: Colors.blue,
          children:
              widget.selectedDays.map((day) => _buildHourRow(day)).toList(),
        ),
      ),
    );
  }

  Widget _buildHourRow(String day) {
    return ListTile(
      title: Text(
        day,
        style: const TextStyle(color: Colors.black),
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: _workingHours[day]?['start'],
              decoration: const InputDecoration(
                labelText: "Start",
              ),
              onChanged: (value) {
                setState(() {
                  _workingHours[day]?['start'] =
                      value.isEmpty ? _defaultStartHour : value;
                });
                _notifyHoursUpdated();
              },
            ),
          ),
          const SizedBox(width: 10),
          const Text("To"),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              initialValue: _workingHours[day]?['end'],
              decoration: const InputDecoration(
                labelText: "End",
              ),
              onChanged: (value) {
                setState(() {
                  _workingHours[day]?['end'] =
                      value.isEmpty ? _defaultEndHour : value;
                });
                _notifyHoursUpdated();
              },
            ),
          ),
        ],
      ),
    );
  }

  // Notificar cuando las horas han sido actualizadas
  void _notifyHoursUpdated() {
    widget.onHoursSelected(_workingHours);
  }
}
