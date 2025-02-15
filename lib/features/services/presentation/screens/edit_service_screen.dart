import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/services/models/task_model.dart';

class EditServiceScreen extends StatefulWidget {
  final Task task;

  const EditServiceScreen({super.key, required this.task});

  @override
  _EditServiceScreenState createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late Map<String, TextEditingController> _workingHoursControllers;
  late Map<String, TextEditingController> _questionControllers;
  late Map<String, TextEditingController> _selectedTasksControllers;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Inicializar controladores básicos
    _nameController = TextEditingController(text: widget.task.taskName);
    _priceController =
        TextEditingController(text: widget.task.price.toString());
    _descriptionController =
        TextEditingController(text: widget.task.description);

    // Inicializar controladores para horas de trabajo
    _workingHoursControllers = widget.task.workingHours.map((key, value) {
      return MapEntry(
        key,
        TextEditingController(
          text: "${value['start']} - ${value['end']}",
        ),
      );
    });

    // Inicializar controladores para preguntas/respuestas
    _questionControllers = widget.task.questionResponses?.map((key, value) {
          return MapEntry(key, TextEditingController(text: value));
        }) ??
        {};

    // Inicializar controladores para las tareas seleccionadas y sus precios
    _selectedTasksControllers = widget.task.selectedTasks.map((key, value) {
      return MapEntry(key, TextEditingController(text: value.toString()));
    });
  }

  Future<void> _updateService() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Convertir horas de trabajo editadas
      final updatedWorkingHours =
          _workingHoursControllers.map((key, controller) {
        final times = controller.text.split('-').map((e) => e.trim()).toList();
        if (times.length == 2) {
          return MapEntry(key, {'start': times[0], 'end': times[1]});
        }
        return MapEntry(key, {'start': '', 'end': ''});
      });

      // Convertir preguntas/respuestas editadas
      final updatedQuestionResponses =
          _questionControllers.map((key, controller) {
        return MapEntry(key, controller.text.trim());
      });

      // Convertir tareas seleccionadas editadas
      final updatedSelectedTasks =
          _selectedTasksControllers.map((key, controller) {
        return MapEntry(key, double.tryParse(controller.text.trim()) ?? 0.0);
      });

      // Actualizar la tarea en Firestore
      await FirebaseFirestore.instance
          .collection('tasks') // Asegúrate de que la colección sea correcta
          .doc(widget.task.taskId) // taskId es el ID del documento
          .update({
        'taskName': _nameController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'details': _descriptionController.text.trim(),
        'workingHours': updatedWorkingHours,
        'questionResponses': updatedQuestionResponses,
        'selectedTasks': updatedSelectedTasks,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service updated successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context); // Volver a la pantalla anterior
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update service: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Service'),
        backgroundColor: const Color(0xFF404C8C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo para editar el nombre del servicio
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Service Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a service name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Campo para editar el precio del servicio
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Campo para editar la descripción del servicio
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Sección para las horas de trabajo
              const Text(
                'Working Hours',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ..._workingHoursControllers.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: entry.value,
                    decoration: InputDecoration(
                      labelText: entry.key,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter working hours for ${entry.key}';
                      }
                      if (!value.contains('-')) {
                        return 'Please use the format "start - end"';
                      }
                      return null;
                    },
                  ),
                );
              }),
              const SizedBox(height: 16.0),

              // Sección para las preguntas y respuestas
              const Text(
                'FAQs',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ..._questionControllers.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: entry.value,
                    decoration: InputDecoration(
                      labelText: entry.key,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an answer for "${entry.key}"';
                      }
                      return null;
                    },
                  ),
                );
              }),
              const SizedBox(height: 16.0),

              // Sección para editar tareas seleccionadas y precios
              const Text(
                'Selected Tasks',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ..._selectedTasksControllers.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: entry.value,
                    decoration: InputDecoration(
                      labelText: 'Price for ${entry.key}',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a price for ${entry.key}';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                );
              }),
              const SizedBox(height: 16.0),

              // Botón para guardar los cambios
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateService,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    backgroundColor: const Color(0xFF404C8C),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 16.0),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Limpiar controladores
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    for (var controller in _workingHoursControllers.values) {
      controller.dispose();
    }
    for (var controller in _questionControllers.values) {
      controller.dispose();
    }
    for (var controller in _selectedTasksControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
