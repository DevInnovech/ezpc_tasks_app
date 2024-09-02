import 'package:ezpc_tasks_app/features/services/data/add_repositoey.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuestionsStep extends ConsumerWidget {
  const QuestionsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questions = ref.watch(questionsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: questions.isNotEmpty
          ? Column(
              children: questions.map((question) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    decoration: InputDecoration(labelText: question),
                  ),
                );
              }).toList(),
            )
          : const Center(child: Text('No additional questions.')),
    );
  }
}
