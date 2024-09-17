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
      child: questions.isNotEmpty
          ? Column(
              children: questions.map((question) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    decoration: InputDecoration(labelText: question),
                    onChanged: (value) {
                      ref.read(taskProvider.notifier).updateTask((currentTask) {
                        // Nota: Como no hay un campo específico para preguntas en el modelo Task,
                        // podríamos almacenar las respuestas en un mapa en el campo 'name' por ahora.
                        // En una implementación real, deberías considerar añadir un campo adecuado al modelo Task.
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
                          licenseType: '',
                          licenseNumber: '',
                          licenseExpirationDate: '',
                          phone: '',
                          service: '',
                          issueDate: '',
                          documentUrl: '',
                        );
                      });
                    },
                    initialValue:
                        '', // No podemos obtener valores iniciales ya que no hay un campo específico para preguntas
                  ),
                );
              }).toList(),
            )
          : const Center(child: Text('No additional questions.')),
    );
  }
}
