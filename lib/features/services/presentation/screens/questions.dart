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
          const Text(
            "Additional Information",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
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
                        // Obtener el mapa de respuestas actual
                        Map<String, String> questionResponses =
                            currentTask.questionResponses ?? {};

                        // Actualizar la respuesta a la pregunta
                        questionResponses[question] = value;

                        // Usar `updateTask` para actualizar el campo `questionResponses`
                        ref.read(taskProvider.notifier).updateTask(
                              questionResponses: questionResponses,
                            );
                      }
                    },
                    initialValue:
                        currentTask?.questionResponses?[question] ?? '',
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
