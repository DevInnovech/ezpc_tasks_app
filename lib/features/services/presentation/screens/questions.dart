import 'package:ezpc_tasks_app/features/services/data/add_repository.dart';
import 'package:ezpc_tasks_app/features/services/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/features/services/data/task_provider.dart';

class QuestionsStep extends ConsumerWidget {
  const QuestionsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questions = ref.watch(questionsProvider);
    final taskState = ref.watch(taskProvider);
    final Task? currentTask = taskState.currentTask;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Añadimos un título para las preguntas
          const Text(
            "Additional Information",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16), // Espacio entre el título y las preguntas

          // Mostramos las preguntas si hay alguna disponible
          if (questions.isNotEmpty)
            Column(
              children: questions.map((question) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    decoration: InputDecoration(labelText: question),
                    onChanged: (value) {
                      // Validar que `currentTask` no sea null antes de actualizar
                      if (currentTask != null) {
                        // Actualizar el campo `name` de la `currentTask`
                        String updatedName = currentTask.name;

                        // Añadir la pregunta y su respuesta al `name`
                        updatedName += '$question: $value\n';

                        // Usar `updateTask` para actualizar el campo `name`
                        ref.read(taskProvider.notifier).updateTask(
                              name: updatedName,
                            );
                      }
                    },
                    initialValue:
                        '', // No podemos obtener valores iniciales ya que no hay un campo específico para preguntas
                  ),
                );
              }).toList(),
            )
          else
            const Center(child: Text('No additional questions.')),
        ],
      ),
    );
  }
}
