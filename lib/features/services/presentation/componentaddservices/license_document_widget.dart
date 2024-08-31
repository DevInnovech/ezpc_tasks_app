import 'package:flutter/material.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_text.dart';

class LicenseDocumentInput extends StatelessWidget {
  const LicenseDocumentInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const CustomText(text: 'License Document'),
      initiallyExpanded: false,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomText(text: "License Type:"),
              TextFormField(
                initialValue: "#plumber",
                decoration: const InputDecoration(
                  hintText: 'Enter License Type',
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              const CustomText(text: "License Number:"),
              TextFormField(
                initialValue: "1452746232",
                decoration: const InputDecoration(
                  hintText: 'Enter License Number',
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              const CustomText(text: "Phone:"),
              TextFormField(
                initialValue: "978-504-1010",
                decoration: const InputDecoration(
                  hintText: 'Enter Phone Number',
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              const CustomText(text: "Service:"),
              TextFormField(
                initialValue: "Cleaning",
                decoration: const InputDecoration(
                  hintText: 'Enter Service',
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              const CustomText(text: "Issue Date:"),
              TextFormField(
                initialValue: "11 May, 2024",
                decoration: const InputDecoration(
                  hintText: 'Enter Issue Date',
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              const CustomText(text: "Expiration Date:"),
              TextFormField(
                initialValue: "11 May, 2028",
                decoration: const InputDecoration(
                  hintText: 'Enter Expiration Date',
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  // Lógica para cargar el documento de licencia
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload License Document'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
