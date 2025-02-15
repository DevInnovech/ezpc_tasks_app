import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:ezpc_tasks_app/features/settings/models/company_models.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/utils/constans/k_images.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  String _generateChatRoomId(String userId, String providerId) {
    return userId.compareTo(providerId) < 0
        ? '${userId}_$providerId'
        : '${providerId}_$userId';
  }

  void _openChatWithProvider(String businessName) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to chat.')),
      );
      return;
    }

    try {
      // 1️⃣ Buscar el ID del usuario cuyo "name" coincida con el Business Name en "users"
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: businessName)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No provider found with name: $businessName')),
        );
        return;
      }

      final providerId = userSnapshot.docs.first.id; // ID del usuario/proveedor

      // 2️⃣ Generar el chatRoomId entre el usuario y el proveedor
      final chatRoomId = _generateChatRoomId(currentUserId, providerId);

      // 3️⃣ Verificar si la sala de chat ya existe o crearla
      final chatRoomRef =
          FirebaseFirestore.instance.collection('chats').doc(chatRoomId);
      final chatRoomSnapshot = await chatRoomRef.get();

      if (!chatRoomSnapshot.exists) {
        await chatRoomRef.set({
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'customerId': currentUserId,
          'providerId': providerId,
          'unreadCounts': {},
          'onlineUsers': [],
        });
      }

      // 4️⃣ Abrir la pantalla del chat con el proveedor
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerChatScreen(
            chatRoomId: chatRoomId,
            customerId: currentUserId,
            providerId: providerId,
            orderId: "", // No hay orderId en este caso
            isFakeData: false,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening chat: $e')),
      );
      print('Error opening chat: $e');
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
                    onPressed: () {
                      if (company != null) {
                        _openChatWithProvider(
                            company!.name); // Buscar por Business Name
                      }
                    },
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
