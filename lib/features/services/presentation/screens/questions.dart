import 'package:ezpc_tasks_app/features/services/data/add_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/features/services/data/task_provider.dart';
import 'package:ezpc_tasks_app/features/services/models/task_model.dart';
import 'package:uuid/uuid.dart';

class QuestionsStep extends ConsumerWidget {
  const QuestionsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questions = ref.watch(questionsProvider);
    final task = ref.watch(taskProvider);

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
                      ref.read(taskProvider.notifier).updateTask((currentTask) {
                        // Nota: Como no hay un campo específico para preguntas en el modelo Task,
                        // podrías almacenar las respuestas en un campo dedicado en el futuro.
                        String updatedName = currentTask?.name ?? '';
                        updatedName += '$question: $value\n';

                        return Task(
                          id: currentTask?.id ?? const Uuid().v4(),
                          name: updatedName,
                          category: currentTask?.category ?? '',
                          subCategory: currentTask?.subCategory ?? '',
                          price: currentTask?.price ?? 0.0,
                          imageUrl: currentTask?.imageUrl ?? '',
                          requiresLicense:
                              currentTask?.requiresLicense ?? false,
                          workingDays: currentTask?.workingDays ?? [],
                          workingHours: currentTask?.workingHours ?? {},
                          specialDays: currentTask?.specialDays ?? [],
                          licenseType: currentTask?.licenseType ?? '',
                          licenseNumber: currentTask?.licenseNumber ?? '',
                          licenseExpirationDate:
                              currentTask?.licenseExpirationDate ?? '',
                          phone: currentTask?.phone ?? '',
                          service: currentTask?.service ?? '',
                          issueDate: currentTask?.issueDate ?? '',
                          documentUrl: currentTask?.documentUrl ?? '',
                        );
                      });
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
