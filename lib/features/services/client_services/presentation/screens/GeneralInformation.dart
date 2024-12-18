import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'ConfirmationScreen.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GeneralInformationScreen extends StatefulWidget {
  final String taskId;
  final String timeSlot;
  final DateTime date;
  final String selectedCategory;
  final List<String> selectedSubCategories;
  final Map<String, int> serviceSizes;
  final double totalPrice;
  final String userId;
  final String selectedTaskName;
  final double categoryPrice;
  final double taskPrice;
  final String providerId;

  const GeneralInformationScreen({
    super.key,
    required this.taskId,
    required this.timeSlot,
    required this.date,
    required this.selectedCategory,
    required this.selectedSubCategories,
    required this.serviceSizes,
    required this.totalPrice,
    required this.userId,
    required this.selectedTaskName,
    required this.categoryPrice,
    required this.taskPrice,
    required this.providerId,
  });

  @override
  _GeneralInformationScreenState createState() =>
      _GeneralInformationScreenState();
}

class _GeneralInformationScreenState extends State<GeneralInformationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  late DateTime selectedDate;
  bool isLoading = true;
  String? errorMessage;
  bool applyForAnotherPerson = false;

  // Información del proveedor
  String providerName = "";
  String providerEmail = "";
  String providerPhone = "";
  String providerId = "";

  @override
  void initState() {
    super.initState();
    selectedDate = widget.date;
    providerId = widget.providerId; // Inicializamos el providerId
    fetchClientData();
    fetchProviderData(); // Obtener información del proveedor
  }

  Future<void> fetchClientData() async {
    try {
      final clientDoc = await FirebaseFirestore.instance
          .collection('clients')
          .doc(widget.userId)
          .get();

      if (clientDoc.exists) {
        final data = clientDoc.data()!;
        setState(() {
          if (!applyForAnotherPerson) {
            nameController.text = data['name'] ?? '';
            phoneController.text = data['phoneNumber'] ?? '';
            emailController.text = data['email'] ?? '';
            addressController.text = data['address'] ?? '';
          }
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'No client information found.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading client data: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchProviderData() async {
    try {
      final providerDoc = await FirebaseFirestore.instance
          .collection('providers')
          .doc(widget.providerId)
          .get();

      if (providerDoc.exists) {
        final providerData = providerDoc.data()!;
        setState(() {
          providerName =
              "${providerData['name'] ?? ''} ${providerData['lastName'] ?? ''}";
          providerEmail = providerData['email'] ?? '';
          providerPhone = providerData['phoneNumber'] ?? '';
        });
      } else {
        debugPrint(
            "No provider information found for ID: ${widget.providerId}");
      }
    } catch (e) {
      debugPrint('Error fetching provider data: $e');
    }
  }

  Widget _buildProviderInfoCard() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 4,
      margin: const EdgeInsets.only(top: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Provider Details",
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildInfoRow("Provider ID", providerId),
            _buildInfoRow("Name", providerName),
            _buildInfoRow("Email", providerEmail),
            _buildInfoRow("Phone", providerPhone),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : "Not available",
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildProgressStep("Task", isCompleted: true),
        _buildProgressStep("Information", isCompleted: true),
        _buildProgressStep("Confirm", isCompleted: false),
      ],
    );
  }

  Widget _buildProgressStep(String title, {required bool isCompleted}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: isCompleted ? const Color(0xFF404C8C) : Colors.grey,
          child: Icon(
            isCompleted ? Icons.check : Icons.circle_outlined,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
            color: isCompleted ? const Color(0xFF404C8C) : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildClientInfoCard() {
    var children = [
      const Text(
        "Client Details",
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      const Divider(),
      _buildTextField(
        label: "Name",
        controller: nameController,
        isEnabled: applyForAnotherPerson,
      ),
      _buildTextField(
        label: "Phone",
        controller: phoneController,
        keyboardType: TextInputType.phone,
        isEnabled: applyForAnotherPerson,
      ),
      _buildTextField(
        label: "Email",
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        isEnabled: applyForAnotherPerson,
      ),
      const SizedBox(height: 8.0),

      // Si applyForAnotherPerson es true, añade el textField, si no, añade el Text
      if (!applyForAnotherPerson)
        _buildTextField(
          label: "Address",
          controller: addressController,
          keyboardType: TextInputType.streetAddress,
          isEnabled: applyForAnotherPerson,
        )
      else
        const Text(
          "Address",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
        ),

      if (applyForAnotherPerson) const SizedBox(height: 8.0),
      if (applyForAnotherPerson)
        GooglePlaceAutoCompleteTextField(
          textEditingController: addressController,
          googleAPIKey: "AIzaSyAniwsNy7RlHjkeU8x_k44dPsw4isyK-d0",
          inputDecoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            hintText: "Enter Address",
          ),
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
      if (applyForAnotherPerson) const SizedBox(height: 16.0),
    ];
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 4,
      margin: const EdgeInsets.only(top: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isMultiline = false,
    TextInputType keyboardType = TextInputType.text,
    bool isEnabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: controller,
          maxLines: isMultiline ? 5 : 1,
          keyboardType: keyboardType,
          enabled: isEnabled,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            hintText: label,
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildApplyForAnotherPersonCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: applyForAnotherPerson,
          onChanged: (value) {
            setState(() {
              applyForAnotherPerson = value ?? false;
              if (!applyForAnotherPerson) {
                fetchClientData(); // Reload client data when unchecking
              }
            });
          },
        ),
        const Text(
          "Apply for another person",
          style: TextStyle(fontSize: 14.0),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("General Information"),
          centerTitle: true,
        ),
        body: Center(
          child: Text(
            errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 16.0),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("General Information"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Indicator
                _buildProgressIndicator(),
                const SizedBox(height: 16.0),

                // Client Information Card
                _buildClientInfoCard(),
                const SizedBox(height: 16.0),

                // Provider Information Card
                _buildProviderInfoCard(),
                const SizedBox(height: 16.0),

                // Apply for Another Person Checkbox
                _buildApplyForAnotherPersonCheckbox(),
                const SizedBox(height: 16.0),

                // Notes Section
                _buildTextField(
                  label: "Short Notes",
                  controller: notesController,
                  isMultiline: true,
                ),
                const SizedBox(height: 80.0), // Espacio para el botón fijo
              ],
            ),
          ),

          // Botón Fijo
          Positioned(
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfirmationScreen(
                      bookingData: {
                        'taskId': widget.taskId,
                        'timeSlot': widget.timeSlot,
                        'date': DateFormat('yyyy-MM-dd')
                            .format(widget.date), // Solo la fecha
                        'selectedCategory': widget.selectedCategory,
                        'selectedSubCategories': widget.selectedSubCategories,
                        'serviceSizes': widget.serviceSizes,
                        'totalPrice': widget.totalPrice,
                        'clientName': nameController.text,
                        'clientPhone': phoneController.text,
                        'clientEmail': emailController.text,
                        'clientAddress': addressController.text,
                        'shortNotes': notesController.text,
                        'selectedTaskName': widget.selectedTaskName,
                        'categoryPrice': widget.categoryPrice,
                        'taskPrice': widget.taskPrice,
                        'providerId': providerId,
                        'providerName': providerName,
                        'providerEmail': providerEmail,
                        'providerPhone': providerPhone,
                        'createdAt': DateTime.now().toIso8601String(),
                        'paymentStatus': "", // Inicializamos como vacío
                      },
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF404C8C),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                "Proceed to Confirmation",
                style: TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
