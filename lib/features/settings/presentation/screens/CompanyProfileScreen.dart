import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/settings/models/company_models.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';

class CompanyProfileScreen extends StatefulWidget {
  final String companyId;

  const CompanyProfileScreen({super.key, required this.companyId});

  @override
  _CompanyProfileScreenState createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  Company? company; // Hacer nuloable la variable `company`.

  @override
  void initState() {
    super.initState();
    _fetchCompanyData();
  }

  Future<void> _fetchCompanyData() async {
    try {
      print("Fetching provider document for company ID: ${widget.companyId}");

      // Buscar el documento del proveedor en la colección 'providers'
      final providerDoc = await FirebaseFirestore.instance
          .collection('providers')
          .where('companyID', isEqualTo: widget.companyId)
          .limit(1)
          .get();

      if (providerDoc.docs.isEmpty) {
        print('No provider found for the provided company ID');
        return;
      }

      final providerData = providerDoc.docs.first.data();
      print('Provider data: $providerData');

      // Buscar el documento en la colección 'about_me' usando el ID del proveedor
      final aboutMeDoc = await FirebaseFirestore.instance
          .collection('about_me')
          .doc(providerDoc.docs.first.id)
          .get();

      String? profileImage;
      if (aboutMeDoc.exists) {
        final aboutMeData = aboutMeDoc.data();
        print('About Me data: $aboutMeData');

        if (aboutMeData != null) {
          profileImage = aboutMeData['imagen'] ?? '';
          print('Profile image from about_me: $profileImage');
        }
      } else {
        print(
            'No About Me document found for provider ID: ${providerDoc.docs.first.id}');
      }

      // Actualizar el estado con los datos del proveedor y la imagen de perfil
      setState(() {
        company = Company(
          name: providerData['name'],
          image: profileImage ?? providerData['image'],
          fin: providerData['companyID'],
          email: providerData['email'],
          phone: providerData['phoneNumber'],
          address: providerData['address'],
          description: providerData['description'],
        );
      });
      print('Company initialized: $company');
    } catch (e) {
      print('Error fetching company data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: company == null
          ? const Center(
              child:
                  CircularProgressIndicator()) // Muestra un indicador de carga
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomImage(
                      path: company!.image ?? KImages.aboutUs,
                      height: 200.0,
                      url: ''),
                  const SizedBox(height: 16.0),
                  _buildInfoField("Business Name", company!.name),
                  _buildInfoField("Business FIN", company!.fin),
                  _buildInfoField("Email Address", company!.email),
                  _buildInfoField("Phone", company!.phone),
                  _buildInfoField("Address", company!.address),
                  _buildInfoField("Business Description", company!.description),
                  const SizedBox(height: 16.0),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () =>
                        Navigator.pushNamed(context, RouteNames.chatListScreen),
                    icon: const Icon(
                      Icons.chat,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Chat with Company",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
            ),
          ),
          const SizedBox(height: 4.0),
          TextFormField(
            initialValue: value,
            readOnly: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            ),
          ),
        ],
      ),
    );
  }
}
