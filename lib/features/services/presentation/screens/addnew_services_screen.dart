import 'package:ezpc_tasks_app/features/services/data/add_repository.dart';
import 'package:ezpc_tasks_app/features/services/presentation/screens/category_pricing.dart';
import 'package:ezpc_tasks_app/features/services/presentation/screens/questions.dart';
import 'package:ezpc_tasks_app/features/services/presentation/screens/schedulestep.dart';
import 'package:ezpc_tasks_app/features/services/presentation/screens/special_days.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/features/services/data/task_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddNewTaskScreen extends ConsumerStatefulWidget {
  const AddNewTaskScreen({super.key});

  @override
  _AddNewTaskScreenState createState() => _AddNewTaskScreenState();
}

class _AddNewTaskScreenState extends ConsumerState<AddNewTaskScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final _formKeys = List.generate(4, (_) => GlobalKey<FormState>());

  @override
  void initState() {
    super.initState();

    // Initialize task with provider ID
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final providerId = user.uid;
        await ref.read(taskProvider.notifier).initializeNewTask(providerId);
        debugPrint('Task initialized successfully.');
      } else {
        debugPrint('No authenticated user.');
      }
    });
  }

  final List<Widget> _steps = [
    CategoryPricingStep(formKey: GlobalKey<FormState>()),
    QuestionsStep(formKey: GlobalKey<FormState>()),
    ScheduleStep(formKey: GlobalKey<FormState>()),
    SpecialDaysStep(formKey: GlobalKey<FormState>()),
  ];

  @override
  Widget build(BuildContext context) {
    bool special = ref.watch(specialDaysEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: ElevatedButton(
                  onPressed: _handlePrevious,
                  child: const Text('Back'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 16.0),
            Expanded(
              child: ElevatedButton(
                onPressed: _handleNext,
                child: Text(
                  _currentStep == _steps.length - 1 ||
                          (_currentStep == 2 && !special)
                      ? 'Finish'
                      : 'Next',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNext() {
    final currentTask = ref.read(taskProvider).currentTask;
    bool specialDaysEnabled = ref.watch(specialDaysEnabledProvider);

    if (currentTask == null) {
      _showDialog(context, 'Error', 'No task data available.');
      return;
    }

    if (_currentStep == 0) {
      if (currentTask.imageUrl.isEmpty) {
        _showDialog(context, 'Error', 'Please upload an image.');
        return;
      }

      if (currentTask.category.isEmpty) {
        _showDialog(context, 'Error', 'Please select a category and service.');
        return;
      }

      if (currentTask.selectedTasks.isEmpty) {
        _showDialog(context, 'Error', 'Please select at least one service.');
        return;
      }

      final allPricesProvided =
          currentTask.selectedTasks.entries.every((service) {
        return service.value > 0;
      });

      if (!allPricesProvided) {
        _showDialog(context, 'Error',
            'Ensure all selected services have valid prices.');
        return;
      }
    }
    if (_currentStep == 1) {
      if (currentTask.questions == null || currentTask.questions!.isEmpty) {
        // Rellenar información en blanco y avanzar automáticamente

        setState(() {
          _currentStep++;
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
        return;
      }
    }
    if (_currentStep == 2) {
      if (currentTask.workingHours.isEmpty) {
        _showDialog(
            context, 'Error', 'Please select at least one date or day.');
        return;
      }
    }

    if (_currentStep == 3) {
      // Paso 4 - Special Days
      if (currentTask.specialDays.isEmpty) {
        _showDialog(context, 'Error', 'Please add at least one special day.');
        return;
      }
    }
    if (!specialDaysEnabled && _currentStep == 2) {
      // Si no se habilitaron días especiales, finalizar directamente
      // _saveTask(context);
      print("object");
    } else {
      // Validación general y pasos siguientes
      if (_formKeys[_currentStep].currentState!.validate()) {
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
      }
    }
  }

  void _handlePrevious() {
    final currentTask = ref.read(taskProvider).currentTask;

    if (_currentStep == 2) {
      ref.read(specialDaysEnabledProvider.notifier).state = false;
    }
    setState(() {
      _currentStep--;
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _saveTask(BuildContext context) async {
    final currentTask = ref.read(taskProvider).currentTask;

    if (currentTask == null) {
      _showDialog(context, 'Error', 'No task available to save.');
      return;
    }

    if (currentTask.imageUrl.isEmpty) {
      _showDialog(
          context, 'Error', 'No image URL provided. Please upload an image.');
      return;
    }

    try {
      await ref.read(taskProvider.notifier).uploadImageFromLocalUrl(
            currentTask.imageUrl,
            currentTask,
          );

      _showDialog(context, 'Success', 'Task saved successfully.',
          onDismiss: () {
        Navigator.pop(context); // Close AddNewTaskScreen
      });

      ref.read(taskProvider.notifier).initializeNewTask(currentTask.providerId);
      setState(() {
        _currentStep = 0;
        _pageController.jumpToPage(0);
      });
    } catch (e) {
      _showDialog(context, 'Error', 'Failed to save task: ${e.toString()}');
    }
  }

  void _showDialog(BuildContext context, String title, String message,
      {VoidCallback? onDismiss}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(context);
              if (onDismiss != null) onDismiss();
            },
          ),
        ],
      ),
    );
  }
}
