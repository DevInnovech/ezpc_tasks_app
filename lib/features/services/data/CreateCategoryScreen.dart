import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class CreateCategoryScreen extends StatefulWidget {
  const CreateCategoryScreen({super.key});

  @override
  State<CreateCategoryScreen> createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
  final _categoryNameController = TextEditingController();
  final _serviceNameController = TextEditingController();
  final _questionController = TextEditingController();

  final List<Map<String, dynamic>> _services = [];
  File? _selectedImage;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();
  String? _selectedService; // Para seleccionar servicio al añadir preguntas

  @override
  void dispose() {
    _categoryNameController.dispose();
    _serviceNameController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToFirebase(String categoryId) async {
    if (_selectedImage == null) return null;

    try {
      final storageRef = FirebaseStorage.instance.ref().child(
          'categories/$categoryId/${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = storageRef.putFile(_selectedImage!);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  void _addService() {
    if (_serviceNameController.text.isNotEmpty) {
      setState(() {
        _services.add({
          'name': _serviceNameController.text,
          'questions': <String>[],
        });
        _serviceNameController.clear();
      });
    }
  }

  void _addQuestion() {
    if (_questionController.text.isNotEmpty && _selectedService != null) {
      setState(() {
        final service = _services
            .firstWhere((service) => service['name'] == _selectedService);
        (service['questions'] as List<String>).add(_questionController.text);
        _questionController.clear();
      });
    }
  }

  Future<void> _saveCategory() async {
    if (_categoryNameController.text.isEmpty || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category name and image are required.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final categoryId = const Uuid().v4();
    final imageUrl = await _uploadImageToFirebase(categoryId);

    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image.')),
      );
      setState(() {
        _isUploading = false;
      });
      return;
    }

    final category = {
      'id': categoryId,
      'name': _categoryNameController.text,
      'imageUrl': imageUrl,
      'services': _services,
    };

    await FirebaseFirestore.instance
        .collection('categories')
        .doc(categoryId)
        .set(category);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Category added successfully!')),
    );

    setState(() {
      _isUploading = false;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Category'),
      ),
      body: _isUploading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campo de Nombre de Categoría
                  TextField(
                    controller: _categoryNameController,
                    decoration:
                        const InputDecoration(labelText: 'Category Name'),
                  ),
                  const SizedBox(height: 10.0),

                  // Botón para seleccionar imagen
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Pick Category Image'),
                  ),
                  if (_selectedImage != null)
                    Image.file(
                      _selectedImage!,
                      height: 150,
                      fit: BoxFit.cover,
                    ),

                  const SizedBox(height: 20.0),

                  // Campo para agregar servicios
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _serviceNameController,
                          decoration:
                              const InputDecoration(labelText: 'Service Name'),
                        ),
                      ),
                      IconButton(
                        onPressed: _addService,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),

                  // Lista de servicios
                  if (_services.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _services.map((service) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(service['name']),
                            subtitle: Text(
                                'Questions: ${(service['questions'] as List<String>).join(", ")}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => setState(() {
                                _services.remove(service);
                              }),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 20.0),

                  // Selección de servicio para añadir preguntas
                  DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Select Service to Add Questions'),
                    value: _selectedService,
                    items: _services
                        .map((service) => DropdownMenuItem<String>(
                              value: service['name'],
                              child: Text(service['name']),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedService = value;
                      });
                    },
                  ),

                  // Campo para añadir preguntas
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _questionController,
                          decoration:
                              const InputDecoration(labelText: 'Add Question'),
                        ),
                      ),
                      IconButton(
                        onPressed: _addQuestion,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20.0),

                  // Botón para guardar la categoría
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveCategory,
                      child: const Text('Save Category'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
