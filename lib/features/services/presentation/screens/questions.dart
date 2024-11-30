import 'package:ezpc_tasks_app/features/services/data/add_repository.dart';
import 'package:ezpc_tasks_app/features/services/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/features/services/data/task_provider.dart';

class QuestionsStep extends ConsumerStatefulWidget {
  final GlobalKey<FormState> formKey;

  const QuestionsStep({super.key, required this.formKey});

  @override
  _QuestionsStepState createState() => _QuestionsStepState();
}

class _QuestionsStepState extends ConsumerState<QuestionsStep> {
  @override
  Widget build(BuildContext context) {
    final questions = ref.watch(questionsProvider);
    final taskState = ref.watch(taskProvider);
    final Task? currentTask = taskState.currentTask;

    return Form(
      key: widget.formKey, // Asignar formKey
      child: SingleChildScrollView(
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
                      decoration: InputDecoration(
                        labelText: question,
                      ),
                      onChanged: (value) {
                        if (currentTask != null) {
                          Map<String, String> questionResponses =
                              currentTask.questionResponses ?? {};
                          questionResponses[question] = value;
                          ref.read(taskProvider.notifier).updateTask(
                                questionResponses: questionResponses,
                              );
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please fill in this field';
                        }
                        return null;
                      },
                      initialValue:
                          currentTask?.questionResponses?[question] ?? '',
                    ),
                  );
                }).toList(),
              )
            else
              const Center(child: Text('No additional questions.')),

            const SizedBox(height: 16),

            // Campo para agregar detalles adicionales
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Additional Details',
                  hintText: 'Enter any additional details here...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  if (currentTask != null) {
                    ref.read(taskProvider.notifier).updateTask(
                          details: value,
                        );
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide some details';
                  }
                  return null;
                },
                maxLines: 4, // Permitir varias líneas
                initialValue: currentTask?.details ?? '',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
