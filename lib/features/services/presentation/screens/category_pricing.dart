import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/services/data/task_provider.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ezpc_tasks_app/features/services/presentation/componentaddservices/license_document_widget.dart';
import 'package:ezpc_tasks_app/features/services/presentation/componentaddservices/service_image.dart';

class CategoryPricingStep extends ConsumerStatefulWidget {
  final GlobalKey<FormState> formKey;
  final ValueChanged<List<Map<String, dynamic>>> onCollaboratorsChanged;

  const CategoryPricingStep({
    super.key,
    required this.formKey,
    required this.onCollaboratorsChanged,
  });
  @override
  _CategoryPricingStepState createState() => _CategoryPricingStepState();
}

class _CategoryPricingStepState extends ConsumerState<CategoryPricingStep> {
  String? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _services = [];
  final List<String> _selectedServices = [];
  List<Map<String, dynamic>> collaborators = [];
  final TextEditingController _collaboratorController = TextEditingController();

  bool _isLoadingCategories = true;

  bool _applyGeneralPrice = false;
  double? _generalPrice;
  final Map<String, double> _servicePrices = {};

  bool _showProfessionalLicense = false;
  bool _showassistants = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _collaboratorController.dispose();
    super.dispose();
  }

  Stream<List<Map<String, dynamic>>> _getCollaboratorStream(String? taskId) {
    if (taskId == null) {
      return const Stream
          .empty(); // Devuelve un stream vacío si no hay tarea actual.
    }

    return FirebaseFirestore.instance
        .collection('notifications')
        .where('taskId', isEqualTo: taskId)
        .snapshots()
        .map((snapshot) {
      final updatedCollaborators = snapshot.docs.map((doc) {
        return {
          'id': doc.data()["providerId"],
          ...doc.data(),
        };
      }).toList();

      // Actualizar la lista local de colaboradores
      for (var updated in updatedCollaborators) {
        final existingIndex =
            collaborators.indexWhere((collab) => collab['id'] == updated['id']);

        if (existingIndex != -1) {
          // Actualiza solo los datos del colaborador que cambió
          collaborators[existingIndex] = {
            ...collaborators[existingIndex],
            ...updated,
          };
        } else {
          // Si es un colaborador nuevo, agrégalo a la lista
          collaborators.add(updated);
        }
      }

      // Llamar a _updateCollaborators con la lista actualizada
      widget.onCollaboratorsChanged(collaborators);

      // Devolver la lista actualizada como parte del stream
      return updatedCollaborators;
    });
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('categories').get();
      final categories =
          snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();

      setState(() {
        _categories = categories;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load categories: $e")),
      );
    } finally {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  void _loadServices(String categoryId) {
    final category = _categories.firstWhere((cat) => cat['id'] == categoryId);
    final services =
        List<Map<String, dynamic>>.from(category['services'] ?? []);

    setState(() {
      _services = services;
      _selectedServices.clear();
      _servicePrices.clear();
      _generalPrice = null;
      _applyGeneralPrice = false;
    });
  }

  Widget _buildCollaboratorsSection(BuildContext context) {
    if (!_showassistants)
      return const SizedBox.shrink(); // Ocultar si no está activado.

    final currentTask = ref.read(taskProvider).currentTask;

    if (currentTask == null) {
      return const Center(child: Text("No task available."));
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 8.0),
          title: const Text(
            "Collaborators",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
          ),
          children: [
            // Agregar sección para enviar nuevas solicitudes
            Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 6.0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _collaboratorController,
                      decoration: const InputDecoration(
                        labelText: "Enter collaborator code",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.green),
                    onPressed: () => _addCollaborator(context),
                  ),
                ],
              ),
            ),

            // Mostrar lista de colaboradores en tiempo real
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _getCollaboratorStream(currentTask.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text("Error loading collaborators: ${snapshot.error}");
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text(
                    "No collaborators found.",
                    style: TextStyle(fontSize: 14.0, color: Colors.black54),
                  );
                }

                final collaborators = snapshot.data!;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: collaborators.length,
                  itemBuilder: (context, index) {
                    final collaborator = collaborators[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 6.0,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    collaborator['imagecollaborators'] !=
                                                null &&
                                            collaborator['imagecollaborators']
                                                .isNotEmpty
                                        ? NetworkImage(
                                            collaborator['imagecollaborators'])
                                        : null,
                                backgroundColor: Colors.grey.shade300,
                                child: collaborator['imagecollaborators'] ==
                                            null ||
                                        collaborator['imagecollaborators']
                                            .isEmpty
                                    ? const Icon(Icons.person,
                                        color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Text(
                                  collaborator['collaborators'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _removeCollaborator(index, context),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            "Status: ${collaborator['status'] ?? 'Unknown'}",
                            style: TextStyle(
                              fontSize: 14.0,
                              color: collaborator['status'] == 'Accepted'
                                  ? Colors.green
                                  : collaborator['status'] == 'Pending'
                                      ? Colors.orange
                                      : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeCollaborator(int index, BuildContext context1) async {
    final collaborator = collaborators[index];
    final currentTask = ref.read(taskProvider).currentTask;

    if (currentTask == null) {
      ScaffoldMessenger.of(context1).showSnackBar(
        const SnackBar(content: Text("No task available.")),
      );
      return;
    }

    try {
      if (collaborator['status'] == 'Pending') {
        // Remove the notification from Firestore
        final notifications = await FirebaseFirestore.instance
            .collection('notifications')
            .where('providerId', isEqualTo: collaborator['id'])
            .where('taskId', isEqualTo: currentTask.id)
            .limit(1)
            .get();

        for (var doc in notifications.docs) {
          await doc.reference.delete();
        }
      }

      // Remove the collaborator from the list
      setState(() {
        collaborators.removeAt(index);
      });

      // Sync the updated collaborators list with Firestore
      await _syncCollaboratorsToFirestore();

      widget.onCollaboratorsChanged(collaborators);

      ScaffoldMessenger.of(context1).showSnackBar(
        SnackBar(content: Text("Collaborator removed successfully.")),
      );
    } catch (e) {
      debugPrint("Error removing collaborator: $e");
      ScaffoldMessenger.of(context1).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Widget _buildServiceDropdown() {
    return DropdownButtonFormField<String>(
      hint: const Text("Select Services"),
      value: null,
      items: _services.map((service) {
        return DropdownMenuItem<String>(
          value: service['name'],
          child: StatefulBuilder(
            builder: (context, setStateCheckbox) {
              return CheckboxListTile(
                title: Text(service['name']),
                value: _selectedServices.contains(service['name']),
                onChanged: (bool? isChecked) {
                  setState(() {
                    if (isChecked == true) {
                      _selectedServices.add(service['name']);
                    } else {
                      _selectedServices.remove(service['name']);
                      _servicePrices.remove(service['name']);
                    }
                    _applyGeneralPrice = false;
                  });
                  setStateCheckbox(() {});
                },
                controlAffinity: ListTileControlAffinity.leading,
              );
            },
          ),
        );
      }).toList(),
      onChanged: (_) {},
      isExpanded: true,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Upload Service Image'),
            const SizedBox(height: 8),
            ServiceImage(
              onImageSelected: (String imageUrl) {
                ref.read(taskProvider.notifier).updateTask(imageUrl: imageUrl);
              },
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Choose Category'),
            _isLoadingCategories
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    hint: const Text('Select a category'),
                    items: _categories
                        .map((category) => DropdownMenuItem<String>(
                              value: category['id'],
                              child: Text(category['name']),
                            ))
                        .toList(),
                    onChanged: (String? categoryId) {
                      setState(() {
                        _selectedCategoryId = categoryId;
                      });

                      if (categoryId != null) {
                        _loadServices(categoryId);
                      }
                    },
                  ),
            const SizedBox(height: 16),
            if (_services.isNotEmpty) ...[
              _buildSectionTitle(context, 'Select Services'),
              _buildServiceDropdown(),
            ],
            if (_selectedServices.length > 1)
              _buildRadioButton(
                "Apply General Price for All Services",
                _applyGeneralPrice,
                (value) {
                  setState(() {
                    _applyGeneralPrice = value ?? false;
                    if (_applyGeneralPrice) _servicePrices.clear();
                  });
                },
              ),
            if (_applyGeneralPrice)
              TextFormField(
                initialValue: _generalPrice?.toStringAsFixed(2),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter General Price',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _generalPrice = double.tryParse(value) ?? 0.0;
                  });
                },
              ),
            if (!_applyGeneralPrice)
              ..._selectedServices.map((service) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    initialValue:
                        _servicePrices[service]?.toStringAsFixed(2) ?? '',
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Price for $service',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _servicePrices[service] = double.tryParse(value) ?? 0.0;

                        // Filtrar preguntas solo de los servicios seleccionados
                        Map<String, String> questionR = {};
                        for (final selectedService in _selectedServices) {
                          final serviceData = _services.firstWhere(
                            (s) => s['name'] == selectedService,
                            orElse: () => {},
                          );

                          if (serviceData.isNotEmpty &&
                              serviceData.containsKey('questions')) {
                            final questions = List<dynamic>.from(
                                serviceData['questions'] ?? []);
                            for (final question in questions) {
                              questionR[question] =
                                  selectedService; // Respuesta inicial
                            }
                          }
                        }
                        ref.read(taskProvider.notifier).updateTask(
                            category: _categories.firstWhere((category) =>
                                category['id'] == _selectedCategoryId)['name'],
                            categoryId: _selectedCategoryId,
                            selectedTasks: _servicePrices,
                            questions: questionR);
                      });
                    },
                  ),
                );
              }),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Professional License'),
            _buildProfessionalLicenseToggle(),
            if (_showProfessionalLicense)
              LicenseDocumentInput(
                onLicenseTypeChanged: (String licenseType) {},
                onLicenseNumberChanged: (String licenseNumber) {},
                onPhoneChanged: (String phone) {},
                onIssueDateChanged: (String issueDate) {},
                onLicenseExpirationDateChanged: (String expirationDate) {},
                onDocumentSelected: (File file) {},
              ),
            _buildSectionTitle(context, 'Collaborators'),
            _buildAssistantsToggle(),
            const SizedBox(height: 8),
            if (_showassistants) _buildCollaboratorsSection(context)
          ],
        ),
      ),
    );
  }

  void _addCollaborator(BuildContext context1) async {
    final currentTask = ref.read(taskProvider).currentTask;
    final code = _collaboratorController.text.trim();

    if (currentTask == null ||
        _selectedCategoryId == null ||
        _selectedServices.isEmpty) {
      ScaffoldMessenger.of(context1).showSnackBar(
        const SnackBar(
          content: Text(
              "Please select a category and services before adding collaborators."),
        ),
      );
      return;
    }

    if (code.isEmpty) {
      ScaffoldMessenger.of(context1).showSnackBar(
        const SnackBar(content: Text("Please enter a valid code.")),
      );
      return;
    }

    try {
      // Busca el colaborador en Firestore
      final collaboratorDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('referralCode', isEqualTo: code)
          .where('role', whereIn: [
            "Independent Provider",
            "Employee Provider"
          ]) // Filtro para roles
          .limit(1)
          .get();

      if (collaboratorDoc.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Collaborator not found.")),
        );
        return;
      }

      final collaborator = collaboratorDoc.docs.first.data();

      if ( // Add collaborator only if it's not already in the list
          _addCollaboratorhome({
        'id': collaboratorDoc.docs.first.id,
        'name': collaborator['name'],
        'status': 'Pending',
      })) {
        // Enviar notificación
        await _sendNotification(
          collaboratorDoc.docs.first.id,
          currentTask?.id ?? '',
          currentTask?.category ?? '',
          collaborator['name'],
          collaborator['profileImageUrl'],
        );
      }

      _collaboratorController.clear();
    } catch (e) {
      debugPrint("Error adding collaborator: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _sendNotification(String providerId, String taskId,
      String taskName, String panername, String urlpaner) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception("User not authenticated.");
      }

      // Buscar el nombre del usuario en la colección 'users'
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception("User document not found in 'users' collection.");
      }

      // Obtener el nombre del usuario desde Firestore
      final senderName = userDoc.data()?['name'] ?? 'Unknown';

      // Crear la notificación
      await FirebaseFirestore.instance.collection('notifications').add({
        'providerId': providerId, // ID del colaborador destinatario
        'taskId': taskId, // ID de la tarea relacionada
        'taskName': taskName, // Nombre de la tarea
        'sendId': currentUser.uid, // ID del remitente
        'collaborators': panername,
        'imagecollaborators': urlpaner,
        'senderName': senderName, // Nombre del remitente obtenido de Firestore
        'status': 'Pending', // Estado inicial
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error sending notification: $e");
    }
  }

  Future<void> _syncCollaboratorsToFirestore() async {
    final currentTask = ref.read(taskProvider).currentTask;
    if (currentTask == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(currentTask.id)
          .update({
        'collaborators':
            collaborators.map((collab) => collab['providerId']).toList(),
      });
    } catch (e) {
      debugPrint("Error syncing collaborators to Firestore: $e");
    }
  }

  bool _addCollaboratorhome(Map<String, dynamic> collaborator) {
    if (collaborators
        .any((collab) => collab['providerId'] == collaborator['id'])) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Collaborator already added.")),
      );
      return false;
    }

    setState(() {
      collaborators.add(collaborator);
    });

    widget.onCollaboratorsChanged(collaborators);

    _syncCollaboratorsToFirestore();
    return true;
  }

  // Cambios en la implementación de los Radio Buttons y Switches.
  Widget _buildRadioButton(
      String title, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Switch(
          value: value,
          onChanged: (bool newValue) {
            setState(() {
              onChanged(newValue);
            });
          },
        ),
        Text(title),
      ],
    );
  }

// Usar esta implementación en lugar de los RadioButtons para opciones de licencia y colaboradores.
  _buildProfessionalLicenseToggle() {
    return _customToggleButton(
      title: "I hold a professional license",
      isSelected: _showProfessionalLicense,
      onTap: (value) {
        setState(() {
          _showProfessionalLicense = value;
        });
      },
    );
  }

  _buildAssistantsToggle() {
    return _customToggleButton(
      title: "I need assistants for the service",
      isSelected: _showassistants,
      onTap: (value) {
        setState(() {
          _showassistants = value;
          if (!_showassistants) {
            collaborators.clear(); // Limpia los datos si se desactiva
          }
        });
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

Widget _customToggleButton({
  required String title,
  required bool isSelected,
  required ValueChanged<bool> onTap,
}) {
  return GestureDetector(
    onTap: () => onTap(!isSelected),
    child: Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? primaryColor : primaryColor,
              width: 2,
            ),
            color: isSelected ? primaryColor : Colors.transparent,
          ),
          child: isSelected
              ? const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                )
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: isSelected ? primaryColor : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
