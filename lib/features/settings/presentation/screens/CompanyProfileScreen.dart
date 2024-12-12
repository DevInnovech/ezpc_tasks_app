import 'package:ezpc_tasks_app/features/settings/models/company_models.dart';
import 'package:ezpc_tasks_app/routes/routes.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';

class CompanyProfileScreen extends StatelessWidget {
  final Company company;

  const CompanyProfileScreen({super.key, required this.company});

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomImage(path: company.image, height: 200.0, url: ''),
            const SizedBox(height: 16.0),
            _buildInfoField("Business Name", company.name),
            _buildInfoField("Business FIN", company.fin),
            _buildInfoField("Email Address", company.email),
            _buildInfoField("Phone", company.phone),
            _buildInfoField("Address", company.address),
            _buildInfoField("Business Description", company.description),
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
