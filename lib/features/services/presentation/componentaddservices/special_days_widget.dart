import 'package:ezpc_tasks_app/features/services/data/add_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';

class SpecialDaysWidget extends ConsumerWidget {
  const SpecialDaysWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final specialDays = ref.watch(specialDaysProvider);

    return Column(
      children: [
        ExpansionTile(
          title: const CustomText(text: 'Special Days'),
          children: specialDays.map((day) {
            return ListTile(
              title: Text(day.date),
              subtitle: Text('${day.startTime} - ${day.endTime}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  // Lógica para eliminar el día especial
                },
              ),
            );
          }).toList(),
        ),
        ElevatedButton.icon(
          onPressed: () {
            // Lógica para añadir un nuevo día especial
          },
          icon: const Icon(Icons.add),
          label: const Text('Add New Special Day'),
        ),
      ],
    );
  }
}

class SpecialDay {
  final String date;
  final String startTime;
  final String endTime;

  SpecialDay(
      {required this.date, required this.startTime, required this.endTime});
}
