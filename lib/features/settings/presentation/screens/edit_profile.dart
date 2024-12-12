import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isNameModified = false;
  bool _isLastNameModified = false;
  String _profileImageUrl = '';
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(currentUser.uid).get();

        if (userDoc.exists) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          String name = data['name'] ?? '';
          String lastName = data['lastName'] ?? '';

          setState(() {
            _nameController.text = name;
            _lastNameController.text = lastName;
            _fullNameController.text = '$name $lastName';
            _designationController.text = data['role'] ?? '';
            _emailController.text = data['email'] ?? '';
            _phoneController.text = data['phoneNumber'] ?? '';
            _countryController.text = data['country'] ?? '';
            _stateController.text = data['state'] ?? '';
            _addressController.text = data['address'] ?? '';
            _profileImageUrl = data['profileImageUrl'] ?? ''; // Set image URL
          });
        }
      } catch (e) {
        print('Error al cargar los datos del usuario: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load user data')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profileImages')
            .child('${currentUser.uid}.jpg');

        await storageRef.putFile(_imageFile!);
        String downloadUrl = await storageRef.getDownloadURL();

        await _firestore.collection('users').doc(currentUser.uid).update({
          'profileImageUrl': downloadUrl,
        });

        setState(() {
          _profileImageUrl = downloadUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully')),
        );
      }
    } catch (e) {
      print('Error uploading profile picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile picture')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: transparent,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
          ),
        ),
        title: const Text('Edit Profile',
            style: TextStyle(fontSize: 24, color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (_profileImageUrl.isNotEmpty
                              ? NetworkImage(_profileImageUrl)
                              : const AssetImage(KImages.pp)) as ImageProvider,
                      onBackgroundImageError: (exception, stackTrace) {
                        print('Error loading profile image: $exception');
                      },
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField('Full Name', _fullNameController,
                  isReadOnly: true),
              const SizedBox(height: 20),
              _buildTextField(
                'Name',
                _nameController,
                isRequired: true,
                onChanged: (value) => setState(() => _isNameModified = true),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'Last Name',
                _lastNameController,
                isRequired: true,
                onChanged: (value) =>
                    setState(() => _isLastNameModified = true),
              ),
              const SizedBox(height: 20),
              _buildTextField('Designation', _designationController,
                  isReadOnly: true),
              const SizedBox(height: 20),
              _buildTextField('Email Address', _emailController,
                  isReadOnly: true, isEmail: true),
              const SizedBox(height: 20),
              _buildTextField('Phone', _phoneController, isPhone: true),
              const SizedBox(height: 20),
              _buildTextField('Country', _countryController),
              const SizedBox(height: 20),
              _buildTextField('State', _stateController),
              const SizedBox(height: 20),
              _buildTextField('Address', _addressController),
              const SizedBox(height: 30),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ElevatedButton(
                    onPressed: () {
                      _showConfirmationDialog();
                      if (_imageFile != null) {
                        _uploadImage(); // Upload image if selected
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Update Profile',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isRequired = false,
      bool isEmail = false,
      bool isPhone = false,
      bool isReadOnly = false,
      Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: isReadOnly,
          keyboardType: isEmail
              ? TextInputType.emailAddress
              : (isPhone ? TextInputType.phone : TextInputType.text),
          decoration: InputDecoration(
            filled: true,
            fillColor: isReadOnly ? Colors.grey[300] : Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            errorText: _validateInput(controller.text, isRequired),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  String? _validateInput(String value, bool isRequired) {
    if (isRequired &&
        value.isEmpty &&
        (_isNameModified || _isLastNameModified)) {
      return 'This field is required';
    }
    return null;
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Do you want to save the changes?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateUserProfile();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUserProfile() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        await _firestore.collection('users').doc(currentUser.uid).update({
          'name': _nameController.text,
          'lastName': _lastNameController.text,
          'phoneNumber': _phoneController.text,
          'country': _countryController.text,
          'state': _stateController.text,
          'address': _addressController.text,
        });

        await _loadUserData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } catch (e) {
        print('Error al actualizar el perfil: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    }
  }
}
