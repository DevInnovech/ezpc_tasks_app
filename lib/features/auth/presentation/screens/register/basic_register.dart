import 'package:ezpc_tasks_app/features/auth/data/auth_service.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_app_bar.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_socialbutton.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_form2.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GooglePlaceApiHelper {
  static Future<Map<String, double>> getPlaceDetails(String placeId) async {
    const String apiKey =
        "AIzaSyDwxlmeFfLFPceI3B4J35xq7UqHan7iA6s"; // Reemplaza con tu API Key
    final String url =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final location = jsonData['result']['geometry']['location'];
      return {
        'lat': location['lat'].toDouble(),
        'lng': location['lng'].toDouble(),
      };
    } else {
      throw Exception("Failed to load place details");
    }
  }
}

class CreateAccountPage1 extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final MaskedTextController phoneController =
      MaskedTextController(mask: '(000) 000-0000');

  CreateAccountPage1({super.key});
  bool _isLocationInPennsylvania(double lat, double lng) {
    // Coordenadas aproximadas de los límites de Pensilvania
    const double minLat = 39.7198;
    const double maxLat = 42.2698;
    const double minLng = -80.5199;
    const double maxLng = -74.6895;

    return (lat >= minLat && lat <= maxLat) && (lng >= minLng && lng <= maxLng);
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController dobController = TextEditingController();
    final TextEditingController addressController = TextEditingController();

    return Scaffold(
      appBar: const CustomAppBar(title: ""),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText(
                  text: 'Sign up to your\nAccount',
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                Utils.verticalSpace(10),
                CustomForm2(
                  label: 'Email Address',
                  controller: emailController,
                  hintText: 'Enter your Email',
                  textValidator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email cannot be empty';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomForm2(
                        label: 'Name',
                        controller: nameController,
                        hintText: 'Enter your Name',
                        textValidator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Name cannot be empty';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomForm2(
                        label: 'Last Name',
                        controller: lastNameController,
                        hintText: 'Enter your Last Name',
                        textValidator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Last Name cannot be empty';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomForm2(
                        label: "Date of Birth",
                        hintText: "Select your Birth Date",
                        controller: dobController,
                        isDateField: true, // Indica que este campo es una fecha
                        dateValidator: (value) {
                          if (value == null) {
                            return "Date of Birth is required";
                          }

                          try {
                            DateTime dob = DateTime.parse(value.toString());
                            DateTime today = DateTime.now();
                            int age = today.year - dob.year;

                            if (dob.month > today.month ||
                                (dob.month == today.month &&
                                    dob.day > today.day)) {
                              age--;
                            }

                            if (age < 18) {
                              return "You must be at least 18 years old";
                            }
                          } catch (e) {
                            return "Invalid date format";
                          }

                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomForm2(
                        label: 'Phone Number',
                        controller: phoneController,
                        hintText: '(123) 456-7890',
                        textValidator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone Number cannot be empty';
                          }

                          // Extract only numeric values
                          final String numericValue =
                              value.replaceAll(RegExp(r'\D'), '');

                          if (numericValue.length != 10) {
                            return 'Enter a valid phone number (10 digits required)';
                          }

                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                const Text(
                  "Location",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GooglePlaceAutoCompleteTextField(
                  textEditingController: addressController,
                  googleAPIKey:
                      "AIzaSyDwxlmeFfLFPceI3B4J35xq7UqHan7iA6s", // Reemplaza con tu API Key
                  debounceTime: 800,
                  isLatLngRequired: true,
                  countries: ["us"], // Solo EE.UU.
                  getPlaceDetailWithLatLng: (prediction) async {
                    debugPrint("Place Details: $prediction");

                    // Verificar si prediction es nulo
                    if (prediction == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                "Error: No location selected. Please try again.")),
                      );
                      return;
                    }

                    double? lat;
                    double? lng;

                    // Verificar si prediction tiene lat/lng directamente
                    if (prediction.lat != null && prediction.lng != null) {
                      lat = double.tryParse(prediction.lat.toString());
                      lng = double.tryParse(prediction.lng.toString());
                    }

                    // Si no hay lat/lng, intentar obtenerlas con placeId
                    if ((lat == null || lng == null) &&
                        prediction.placeId != null) {
                      try {
                        final placeDetails =
                            await GooglePlaceApiHelper.getPlaceDetails(
                                prediction.placeId!);
                        lat = placeDetails['lat'];
                        lng = placeDetails['lng'];
                      } catch (e) {
                        debugPrint("Error getting place details: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "Could not get location details. Try another place.")),
                        );
                        return;
                      }
                    }

                    // Si sigue sin lat/lng, mostrar error
                    if (lat == null || lng == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                "Invalid location data. Please try again.")),
                      );
                      return;
                    }

                    // Verificar si está en Pensilvania
                    bool isInPennsylvania = _isLocationInPennsylvania(lat, lng);

                    if (isInPennsylvania) {
                      addressController.text =
                          prediction.description ?? "Unknown Location";
                      addressController.selection = TextSelection.fromPosition(
                        TextPosition(offset: addressController.text.length),
                      );
                    } else {
                      addressController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                "Please select a location within Pennsylvania.")),
                      );
                    }
                  },
                  itemClick: (prediction) async {
                    if (prediction.placeId != null) {
                      try {
                        final placeDetails =
                            await GooglePlaceApiHelper.getPlaceDetails(
                                prediction.placeId!);
                        final lat = placeDetails['lat'];
                        final lng = placeDetails['lng'];

                        if (lat != null &&
                            lng != null &&
                            _isLocationInPennsylvania(lat, lng)) {
                          addressController.text = prediction.description!;
                          addressController.selection =
                              TextSelection.fromPosition(TextPosition(
                                  offset: prediction.description!.length));
                        } else {
                          addressController.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Please select a location within Pennsylvania.")),
                          );
                        }
                      } catch (e) {
                        debugPrint("Error getting place details: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "Could not get location details. Try another place.")),
                        );
                      }
                    } else {
                      addressController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                "Invalid location data. Please try again.")),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16.0),
                loginextras(context),
                const SizedBox(height: 16.0),
                PrimaryButton(
                  text: 'Continue',
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Llamar a la función de registro con los datos ingresados
                      // Obtener los datos ingresados
                      String email = emailController.text;
                      String name = nameController.text;
                      String lastName = lastNameController.text;
                      //              DateTime dob = DateTime.parse(dobController.text); // Asegúrate de que este formato sea correcto
                      String phoneNumber = phoneController.text;
                      String address = addressController.text;

                      // Proceed to next page
                      Navigator.pushNamed(
                        context,
                        RouteNames.passwordAccountpage,
                        arguments: {
                          'email': email,
                          'name': name,
                          'lastName': lastName,
                          //     'dob': dob,
                          'phoneNumber': phoneNumber,
                          'address': address,
                        },
                      );
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

Widget loginextras(BuildContext context) {
  final authService = AuthService(); // Instancia del servicio de autenticación

  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SocialButton(
        imagePath: KImages.googleIcon,
        color: Colors.black,
        onTap: () async {
          var user = await authService.signInWithGoogle();
          if (user != null) {
            // Verificar si falta información
            if (user.displayName != null && user.email != null) {
              Navigator.pushNamed(
                context,
                RouteNames.registrationScreengoogle,
                arguments: {
                  'email': user.email,
                  'name': user.displayName!.split(' ').first,
                  'lastName': user.displayName!.split(' ').length > 1
                      ? user.displayName!.split(' ').last
                      : '',
                  'user_special': user
                },
              );
            }
          }
        },
      ),
      Utils.horizontalSpace(6.0),
      SocialButton(
        imagePath: KImages.facebookIcon,
        color: Colors.black,
        onTap: () async {
          /*     // Manejar el inicio de sesión con Facebook
          var user = await authService.signInWithFacebook();
          if (user != null) {
            Navigator.pushNamed(context, RouteNames.passwordAccountpage,
                arguments: {
                  'email': user.email,
                  'name': user.displayName,
                });
          }*/
        },
      ),
      Utils.horizontalSpace(6.0),
      SocialButton(
        imagePath: KImages.applelogo,
        color: Colors.black,
        onTap: () async {
          /*   // Manejar el inicio de sesión con Apple
          var user = await authService.signInWithApple();
          if (user != null) {
            Navigator.pushNamed(context, RouteNames.passwordAccountpage,
                arguments: {
                  'email': user.email,
                  'name': user.displayName,
                });
          }*/
        },
      ),
    ],
  );
}
