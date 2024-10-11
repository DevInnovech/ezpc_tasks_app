import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set initial values for testing purposes
    _fullNameController.text = 'Alam Cordero';
    _designationController.text = 'Developer';
    _emailController.text = 'some@gmail.com';
    _phoneController.text = '18497523013';
    _countryController.text = 'Dominican Republic';
    _stateController.text = 'Santiago';
    _addressController.text = 'Jardines Metropolitanos';
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
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage(KImages.pp),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
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
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField('Full Name*', _fullNameController,
                  isRequired: true),
              const SizedBox(height: 20),
              _buildTextField('Designation', _designationController),
              const SizedBox(height: 20),
              _buildTextField('Email Address', _emailController, isEmail: true),
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
                      // Handle profile update
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
      {bool isRequired = false, bool isEmail = false, bool isPhone = false}) {
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
          keyboardType: isEmail
              ? TextInputType.emailAddress
              : (isPhone ? TextInputType.phone : TextInputType.text),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            errorText:
                _validateInput(controller.text, isRequired, isEmail, isPhone),
          ),
        ),
      ],
    );
  }

  String? _validateInput(
      String value, bool isRequired, bool isEmail, bool isPhone) {
    if (isRequired && value.isEmpty) {
      return 'This field is required';
    }
    if (isEmail &&
        value.isNotEmpty &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+\$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    if (isPhone &&
        value.isNotEmpty &&
        !RegExp(r'^\d{10,15}\$').hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }
}
