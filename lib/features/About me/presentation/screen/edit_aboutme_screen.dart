import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';

class EditAboutMeScreen extends ConsumerStatefulWidget {
  const EditAboutMeScreen({super.key});

  @override
  _EditAboutMeScreenState createState() => _EditAboutMeScreenState();
}

class _EditAboutMeScreenState extends ConsumerState<EditAboutMeScreen> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController locationController;
  late TextEditingController contactController;
  late TextEditingController serviceTypeController;
  String? profileImage;
  List<String> galleryImages = [];
  bool isLoading = true; // Indicador de carga

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    locationController = TextEditingController();
    contactController = TextEditingController();
    serviceTypeController = TextEditingController();

    _loadAboutMeData(); // Cargar datos existentes
  }

  Future<void> _loadAboutMeData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      // Recuperar datos desde Firestore
      final doc = await FirebaseFirestore.instance
          .collection('about_me')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          setState(() {
            nameController.text = data['name'] ?? '';
            descriptionController.text = data['description'] ?? '';
            locationController.text = data['location'] ?? '';
            contactController.text = data['contactNumber'] ?? '';
            serviceTypeController.text = data['serviceType'] ?? '';
            profileImage = data['imagen'] ?? '';
            galleryImages = List<String>.from(data['gallery'] ?? []);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load data: $e")),
      );
    } finally {
      setState(() {
        isLoading = false; // Finalizar la carga
      });
    }
  }

  Future<void> pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImage = pickedFile.path;
      });
    }
  }

  Future<void> addGalleryImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        galleryImages.add(pickedFile.path);
      });
    }
  }

  void removeGalleryImage(int index) {
    setState(() {
      galleryImages.removeAt(index);
    });
  }

  Future<String> uploadImageToFirebase(
      String filePath, String storagePath) async {
    final file = File(filePath);
    final ref = FirebaseStorage.instance.ref().child(storagePath);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> saveAboutMeToFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      // Upload profile image
      String? profileImageUrl;
      if (profileImage != null && profileImage!.startsWith('/')) {
        profileImageUrl = await uploadImageToFirebase(
            profileImage!, 'profile_images/${user.uid}');
      }

      // Upload gallery images
      List<String> galleryUrls = [];
      for (String imagePath in galleryImages) {
        if (imagePath.startsWith('/')) {
          String url = await uploadImageToFirebase(imagePath,
              'gallery/${user.uid}/${DateTime.now().millisecondsSinceEpoch}');
          galleryUrls.add(url);
        } else {
          galleryUrls.add(imagePath); // If already a URL
        }
      }

      // Save to Firestore
      final aboutMeData = {
        "name": nameController.text,
        "description": descriptionController.text,
        "location": locationController.text,
        "contactNumber": contactController.text,
        "serviceType": serviceTypeController.text,
        "imagen": profileImageUrl ?? profileImage,
        "gallery": galleryUrls,
        "userId": user.uid,
        "createdAt": FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('about_me')
          .doc(user.uid)
          .set(aboutMeData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("About Me saved successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save About Me: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Edit About Me")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: pickProfileImage,
                child: CustomImage(
                  path: profileImage?.startsWith('/') == true
                      ? null
                      : profileImage == '' || profileImage!.isEmpty
                          ? null
                          : profileImage,
                  height: MediaQuery.of(context).size.width * 0.6,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                  isFile: profileImage != null && profileImage!.startsWith('/'),
                  url: profileImage?.startsWith('/') == true
                      ? null
                      : profileImage == '' || profileImage!.isEmpty
                          ? null
                          : profileImage,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: serviceTypeController,
                decoration: const InputDecoration(labelText: "Service Type"),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(labelText: "Location"),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: contactController,
                decoration: const InputDecoration(labelText: "Contact Number"),
              ),
              const SizedBox(height: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Gallery",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: galleryImages.length + 1,
                      itemBuilder: (context, index) {
                        if (index == galleryImages.length) {
                          return GestureDetector(
                            onTap: addGalleryImage,
                            child: Container(
                              width: 120,
                              height: 120,
                              color: Colors.grey[300],
                              child: const Icon(Icons.add_a_photo),
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: () => {},
                                child: CustomImage(
                                  path: galleryImages[index],
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.cover,
                                  isFile: galleryImages[index].startsWith('/'),
                                  url: galleryImages[index].startsWith('/')
                                      ? null
                                      : galleryImages[index],
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => removeGalleryImage(index),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: "Save Changes",
                onPressed: saveAboutMeToFirebase,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    contactController.dispose();
    serviceTypeController.dispose();
    super.dispose();
  }
}
