import 'package:ezpc_tasks_app/shared/widgets/copy_text.dart';
import 'package:flutter/material.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_app_bar.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_form2.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:google_places_flutter/google_places_flutter.dart';

class BusinessAccountScreen extends StatefulWidget {
  const BusinessAccountScreen({super.key});

  @override
  _BusinessAccountScreenState createState() => _BusinessAccountScreenState();
}

class _BusinessAccountScreenState extends State<BusinessAccountScreen> {
  final _formKey =
      GlobalKey<FormState>(); // Usando el GlobalKey para el formulario
  final TextEditingController emailController = TextEditingController();
  final TextEditingController finController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController addressController = TextEditingController();

  DateTime? dob; // Ahora es un DateTime? para manejar la fecha seleccionada
  final TextEditingController phoneController = TextEditingController();

  String? validateRequiredField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName cannot be empty';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    }
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regExp = RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone Number cannot be empty';
    }
    if (value.length < 10) {
      return 'Phone Number must be at least 10 digits';
    }
    return null;
  }

  String? validateDateOfBirth(DateTime? value) {
    if (value == null) {
      return 'Date of Birth is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: ""),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Asignamos la clave al formulario
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText(
                  text: 'Sign up to your\nBusiness Account',
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                Utils.verticalSpace(10),
                CustomForm2(
                  label: "Email Address",
                  hintText: "Enter your Email",
                  controller: emailController,
                  textValidator: validateEmail,
                ),
                CustomForm2(
                  label: "Business FIN",
                  hintText: "Enter your Business FIN",
                  controller: finController,
                  textValidator: (value) =>
                      validateRequiredField(value, 'Business FIN'),
                ),
                CustomForm2(
                  label: "Business Name",
                  hintText: "Enter your Business Name",
                  controller: businessNameController,
                  textValidator: (value) =>
                      validateRequiredField(value, 'Business Name'),
                ),
                CustomForm2(
                  label: "Business Description",
                  hintText: "Enter your Business Description",
                  controller: descriptionController,
                  textValidator: (value) =>
                      validateRequiredField(value, 'Business Description'),
                ),
                const EmployeeCodeField(employeeCode: "BSC76823"),
                Utils.verticalSpace(15),
                Row(
                  children: [
                    Expanded(
                      child: CustomForm2(
                        label: "Date of Creation",
                        hintText: "Select your Creation Date",
                        controller:
                            TextEditingController(), // No se necesita controlador aquí
                        isDateField: true, // Indica que este campo es una fecha
                        dateValidator:
                            validateDateOfBirth, // Usa el validador de fecha
                        onChangeddate: (DateTime? newDate) {
                          setState(() {
                            dob = newDate; // Actualiza la fecha seleccionada
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomForm2(
                        label: 'Phone Number',
                        controller: phoneController,
                        hintText: 'Phone Number',
                        textValidator: validatePhoneNumber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                GooglePlaceAutoCompleteTextField(
                  //          useModernStyle: true,
                  textEditingController: addressController,
                  googleAPIKey:
                      "AIzaSyDwxlmeFfLFPceI3B4J35xq7UqHan7iA6s", // Reemplaza con tu API Key

                  debounceTime: 800,
                  isLatLngRequired: true,
                  getPlaceDetailWithLatLng: (prediction) {
                    debugPrint("Place Details: $prediction");
                  },
                  itemClick: (prediction) {
                    addressController.text = prediction.description!;
                    addressController.selection = TextSelection.fromPosition(
                        TextPosition(offset: prediction.description!.length));
                  },
                ),
                const SizedBox(height: 16.0),
                PrimaryButton(
                  text: "Continue",
                  onPressed: () {
                    // Validar si el formulario es correcto
                    if (_formKey.currentState!.validate()) {
                      // Recopilar datos de los controladores
                      final email = emailController.text;
                      final fin = finController.text;
                      final businessName = businessNameController.text;
                      final description = descriptionController.text;
                      final phoneNumber = phoneController.text;

                      String address = addressController.text;

                      String missingFields = "";

                      // Verificar qué campos faltan
                      if (email.isEmpty) missingFields += "Email, ";
                      if (fin.isEmpty) missingFields += "Business FIN, ";
                      if (businessName.isEmpty)
                        missingFields += "Business Name, ";
                      if (description.isEmpty)
                        missingFields += "Business Description, ";
                      if (dob == null) missingFields += "Date of Birth, ";
                      if (phoneNumber.isEmpty)
                        missingFields += "Phone Number, ";

                      // Eliminar la última coma
                      if (missingFields.isNotEmpty) {
                        missingFields = missingFields.substring(
                            0, missingFields.length - 2);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "Please fill in the following fields: $missingFields"),
                          ),
                        );
                      } else {
                        // Navegar a la siguiente página con los argumentos
                        Navigator.pushNamed(
                          context,
                          RouteNames.passwordAccountpage,
                          arguments: {
                            'email': email,
                            'companyID': fin,
                            'businessName': businessName,
                            'description': description,
                            'dob': dob, // Nuevo argumento agregado
                            'phoneNumber': phoneNumber,
                            'employercode': "BSC76823",
                            'address': address,
                          },
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
