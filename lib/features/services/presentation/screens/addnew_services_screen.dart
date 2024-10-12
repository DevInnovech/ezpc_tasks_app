import 'package:ezpc_tasks_app/features/services/presentation/screens/category_pricing.dart';
import 'package:ezpc_tasks_app/features/services/presentation/screens/questions.dart';
import 'package:ezpc_tasks_app/features/services/presentation/screens/schedulestep.dart';
import 'package:ezpc_tasks_app/features/services/presentation/screens/special_days.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/features/services/data/task_provider.dart';
import 'package:flutter/scheduler.dart'; // Importar para usar SchedulerBinding

class AddNewTaskScreen extends ConsumerStatefulWidget {
  const AddNewTaskScreen({super.key});

  @override
  _AddNewTaskScreenState createState() => _AddNewTaskScreenState();
}

class _AddNewTaskScreenState extends ConsumerState<AddNewTaskScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Añadimos un GlobalKey para manejar las validaciones en cada step.
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  @override
  void initState() {
    super.initState();

    // Reiniciar el estado del task cuando se abra la pantalla
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Inicializamos la tarea fuera del ciclo de construcción
      ref.read(taskProvider.notifier).initializeNewTask();

      // Forzamos la reconstrucción del estado al abrir la pantalla
      setState(() {
        _currentStep = 0; // Reiniciamos el paso actual
        _pageController.jumpToPage(0); // Volvemos a la primera página
      });
    });
  }

  final List<Widget> _steps = [
    CategoryPricingStep(
        formKey: GlobalKey<FormState>()), // Añadir formKey en cada Step
    QuestionsStep(formKey: GlobalKey<FormState>()),
    ScheduleStep(formKey: GlobalKey<FormState>()),
    SpecialDaysStep(formKey: GlobalKey<FormState>()),
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
          return Form(
            key: _formKeys[index],
            child: _steps[index],
          );
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
                  // Validar el formulario actual antes de avanzar
                  if (_formKeys[_currentStep].currentState!.validate()) {
                    // Si no es el último paso, pasar al siguiente paso
                    if (_currentStep < _steps.length - 1) {
                      setState(() {
                        _currentStep++;
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      });
                    } else {
                      // Si es el último paso, guardar la tarea
                      _saveTask(context);
                    }
                  }
                },
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para guardar la tarea en Firebase sin actualizar valores incorrectos
  void _saveTask(BuildContext context) async {
    // Obtener la tarea actual del estado
    final currentTask = ref.read(taskProvider).currentTask;
    String image = currentTask!.imageUrl;

    try {
      // Guardar la tarea usando el método saveTask del taskProvider
      await ref
          .read(taskProvider.notifier)
          .uploadImageFromLocalUrl(image, currentTask);

      // Mostrar un diálogo de éxito al guardar la tarea
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Task saved successfully!'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar el diálogo
                  Navigator.of(context).pop(); // Cerrar la pantalla actual
                },
              ),
            ],
          );
        },
      );

      // Restablecer el estado de la tarea para que no afecte nuevas creaciones
      ref.read(taskProvider.notifier).initializeNewTask();

      // Reiniciar las páginas y el estado del formulario
      setState(() {
        _currentStep = 0; // Volver al primer paso
        _pageController.jumpToPage(0); // Volver a la primera página
        for (var key in _formKeys) {
          key.currentState?.reset(); // Resetear todos los formularios
        }
      });
    } catch (e) {
      showDialog(
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
