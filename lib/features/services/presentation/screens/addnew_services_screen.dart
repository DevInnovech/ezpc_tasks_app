import 'package:ezpc_tasks_app/features/services/presentation/screens/category_pricing.dart';
import 'package:ezpc_tasks_app/features/services/presentation/screens/questions.dart';
import 'package:ezpc_tasks_app/features/services/presentation/screens/schedulestep.dart';
import 'package:ezpc_tasks_app/features/services/presentation/screens/special_days.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/features/services/data/task_provider.dart'; // Corrección del import
import 'package:ezpc_tasks_app/features/services/data/services_repository.dart'; // Correcto import

class AddNewTaskScreen extends ConsumerStatefulWidget {
  const AddNewTaskScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddNewTaskScreenState createState() => _AddNewTaskScreenState();
}

class _AddNewTaskScreenState extends ConsumerState<AddNewTaskScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    // Refrescamos el provider de categorías para cargar las categorías desde Firebase al iniciar la pantalla
//    ref.refresh(categoryListProvider);
  }

  final List<Widget> _steps = [
    const CategoryPricingStep(),
    const QuestionsStep(),
    const ScheduleStep(),
    const SpecialDaysStep(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
        automaticallyImplyLeading: false,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: _steps.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return _steps[index];
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 30.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_currentStep > 0)
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentStep > 0) {
                      setState(() {
                        _currentStep--;
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      });
                    }
                  },
                  child: const Text('Back'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 16.0),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (_currentStep < _steps.length - 1) {
                    setState(() {
                      _currentStep++;
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    });
                  } else {
                    _saveTask(context);
                  }
                },
                child:
                    Text(_currentStep == _steps.length - 1 ? 'Submit' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTask(BuildContext context) async {
    final task = ref.read(taskProvider);
    if (task != null) {
      try {
        await ref.read(taskProvider.notifier).saveTask(task);

        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Task saved successfully!'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );

        // Restablecer el estado de la tarea y los proveedores de categorías/subcategorías
        ref.read(taskProvider.notifier).resetTask();
        //     ref.read(selectedCategoryProvider.notifier).state = null;
        //     ref.read(selectedSubCategoryProvider.notifier).state = null;
      } catch (e) {
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to save task: ${e.toString()}'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }
}
