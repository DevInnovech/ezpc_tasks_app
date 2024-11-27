import 'dart:io'; // Necesario para manejar archivos locales
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart'; // Para seleccionar imágenes

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Método para subir una imagen a Firebase Storage y obtener la URL
  Future<String> uploadImage(File imageFile, String filePath) async {
    try {
      // Crear una referencia a la ubicación en Firebase Storage
      Reference ref = _storage.ref().child(filePath);

      // Subir la imagen al Storage
      await ref.putFile(imageFile);

      // Obtener la URL pública de la imagen subida
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error subiendo imagen: $e');
      rethrow;
    }
  }

  // Método para seleccionar una imagen usando ImagePicker (opcional)
  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return File(pickedFile.path); // Convertir a File
    } else {
      return null; // No se seleccionó ninguna imagen
    }
  }
}
