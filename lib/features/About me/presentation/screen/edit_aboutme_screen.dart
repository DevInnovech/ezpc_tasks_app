import 'dart:io';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ezpc_tasks_app/features/About%20me/data/aboutme_provider.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';

class EditAboutMeScreen extends ConsumerStatefulWidget {
  const EditAboutMeScreen({Key? key}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    final aboutMe = ref.read(aboutMeProvider).asData?.value;
    nameController = TextEditingController(text: aboutMe?.name ?? "");
    descriptionController =
        TextEditingController(text: aboutMe?.description ?? "");
    locationController = TextEditingController(text: aboutMe?.location ?? "");
    contactController =
        TextEditingController(text: aboutMe?.contactNumber ?? "");
    serviceTypeController =
        TextEditingController(text: aboutMe?.serviceType ?? "");
    profileImage = aboutMe?.imagen;
    galleryImages = aboutMe?.gallery ?? [];
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

  void viewGalleryImage(String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: CustomImage(
          path: imagePath,
          height: MediaQuery.of(context).size.height * 0.8,
          width: MediaQuery.of(context).size.width * 0.8,
          fit: BoxFit.cover,
          isFile: imagePath.startsWith('/'),
          url: null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  path: profileImage,
                  height: MediaQuery.of(context).size.width * 0.6,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                  isFile: profileImage != null && profileImage!.startsWith('/'),
                  url: null,
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
                                onTap: () =>
                                    viewGalleryImage(galleryImages[index]),
                                child: CustomImage(
                                  path: galleryImages[index],
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.cover,
                                  isFile: galleryImages[index].startsWith('/'),
                                  url: null,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => removeGalleryImage(index),
                                  child: Container(
                                    decoration: BoxDecoration(
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
                onPressed: () {
                  final updatedAboutMe =
                      ref.read(aboutMeProvider).asData?.value?.copyWith(
                            name: nameController.text,
                            description: descriptionController.text,
                            location: locationController.text,
                            contactNumber: contactController.text,
                            serviceType: serviceTypeController.text,
                            imagen: profileImage,
                            gallery: galleryImages,
                          );
                  if (updatedAboutMe != null) {
                    ref
                        .read(aboutMeEditProvider.notifier)
                        .updateProfile(updatedAboutMe);
                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                text: "Preview",
                onPressed: () {
                  Navigator.pushNamed(context, RouteNames.previewScreen);
                },
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
