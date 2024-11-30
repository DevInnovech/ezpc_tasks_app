import 'package:ezpc_tasks_app/features/payments%20setings/presentation/screen/newpaymentscreen.dart';
import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:intl/intl.dart';
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

  const GeneralInformationScreen({
    Key? key,
    required this.taskId,
    required this.timeSlot,
    required this.date,
    required this.selectedCategory,
    required this.selectedSubCategories,
    required this.serviceSizes,
    required this.totalPrice,
    required this.userId,
  }) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    selectedDate = widget.date;
    fetchClientData();
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
          nameController.text = data['name'] ?? '';
          phoneController.text = data['phoneNumber'] ?? '';
          emailController.text = data['email'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'No se encontró información para este cliente.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar los datos: $e';
        isLoading = false;
      });
    }
  }

  void selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> saveBookingToFirestore() async {
    try {
      if (nameController.text.isEmpty ||
          phoneController.text.isEmpty ||
          emailController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please complete all required fields.')),
        );
        return;
      }

      final bookingData = {
        'taskId': widget.taskId,
        'timeSlot': widget.timeSlot,
        'date': widget.date.toIso8601String(),
        'category': widget.selectedCategory,
        'subCategories': widget.selectedSubCategories,
        'serviceSizes': widget.serviceSizes,
        'totalPrice': widget.totalPrice,
        'clientId': widget.userId,
        'name': nameController.text,
        'phone': phoneController.text,
        'email': emailController.text,
        'address': addressController.text,
        'notes': notesController.text,
        'schedule': selectedDate.toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('bookings').add(bookingData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking saved successfully!')),
      );

      // Navegar a otra pantalla o realizar alguna acción adicional si es necesario
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save booking: $e')),
      );
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isMultiline = false,
    TextInputType keyboardType = TextInputType.text,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              label: "Name",
              controller: nameController,
            ),
            _buildTextField(
              label: "Phone",
              controller: phoneController,
              keyboardType: TextInputType.phone,
            ),
            _buildTextField(
              label: "Email",
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const Text(
              "Address",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
            ),
            const SizedBox(height: 8.0),
            GooglePlaceAutoCompleteTextField(
              textEditingController: addressController,
              googleAPIKey:
                  "AIzaSyDwxlmeFfLFPceI3B4J35xq7UqHan7iA6s", // Reemplaza con tu API Key
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
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Schedule:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                ),
                TextButton(
                  onPressed: () => selectDate(context),
                  child: Text(
                    DateFormat('dd MMM, yyyy').format(selectedDate),
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
              ],
            ),
            _buildTextField(
              label: "Short Notes",
              controller: notesController,
              isMultiline: true,
            ),
            const SizedBox(height: 16.0),
            const Divider(),
            const Text(
              "Task Information",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            Text("Task ID: ${widget.taskId}"),
            Text("Time Slot: ${widget.timeSlot}"),
            Text("Date: ${DateFormat('dd MMM, yyyy').format(widget.date)}"),
            Text("Category: ${widget.selectedCategory}"),
            Text(
              "Subcategories: ${widget.selectedSubCategories.join(', ')}",
            ),
            Text(
              "Service Sizes: ${widget.serviceSizes.entries.where((entry) => entry.value > 0).map((entry) => "${entry.key} (${entry.value})").join(', ')}",
            ),
            Text("Total Price: \$${widget.totalPrice.toStringAsFixed(2)}"),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                await saveBookingToFirestore();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaymentScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text(
                "Proceed to Payment",
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
