import 'package:cloud_firestore/cloud_firestore.dart';
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
  List<Map<String, dynamic>> questions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions(); // Cargar preguntas al inicializar el widget
  }

  Future<void> _loadQuestions() async {
    final taskState = ref.read(taskProvider);
    final Task? currentTask = taskState.currentTask;

    if (currentTask == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      currentTask.questions!.forEach((question, response) {
        questions.add({
          'text': question, // Pregunta
          'type': response, // Respuesta asociada
        });
      });

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error loading questions: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskProvider);
    final Task? currentTask = taskState.currentTask;
    // Agrupar preguntas por tipo
    final Map<String, List<Map<String, dynamic>>> groupedQuestions = {};
    for (final question in questions) {
      final type = question['type'] as String;
      if (!groupedQuestions.containsKey(type)) {
        groupedQuestions[type] = [];
      }
      groupedQuestions[type]!.add(question);
    }

    return Form(
      key: widget.formKey, // Asignar formKey
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: groupedQuestions.entries.map((entry) {
                        final String type = entry.key;
                        final List<Map<String, dynamic>> questionsForType =
                            entry.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título del grupo (type)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                type,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            // Lista de preguntas del grupo
                            ...questionsForType.map((question) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: question['text'],
                                  ),
                                  onChanged: (value) {
                                    if (currentTask != null) {
                                      Map<String, String> questionResponses =
                                          currentTask.questionResponses ?? {};
                                      questionResponses[question['text']] =
                                          value;
                                      ref
                                          .read(taskProvider.notifier)
                                          .updateTask(
                                            questionResponses:
                                                questionResponses,
                                          );
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please fill in this field';
                                    }
                                    return null;
                                  },
                                  initialValue: currentTask?.questionResponses?[
                                          question['text']] ??
                                      '',
                                ),
                              );
                            }),
                          ],
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
