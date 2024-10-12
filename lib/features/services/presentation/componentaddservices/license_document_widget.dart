import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class LicenseDocumentInput extends StatefulWidget {
  final void Function(String licenseType) onLicenseTypeChanged;
  final void Function(String licenseNumber) onLicenseNumberChanged;
  final void Function(String phone) onPhoneChanged;
  final void Function(String service) onServiceChanged;
  final void Function(String issueDate) onIssueDateChanged;
  final void Function(String expirationDate) onLicenseExpirationDateChanged;
  final void Function(File file) onDocumentSelected;

  const LicenseDocumentInput({
    super.key,
    required this.onLicenseTypeChanged,
    required this.onLicenseNumberChanged,
    required this.onPhoneChanged,
    required this.onServiceChanged,
    required this.onIssueDateChanged,
    required this.onLicenseExpirationDateChanged,
    required this.onDocumentSelected,
  });

  @override
  _LicenseDocumentInputState createState() => _LicenseDocumentInputState();
}

class _LicenseDocumentInputState extends State<LicenseDocumentInput> {
  File? selectedFile;
  String fileName = "";
  DateTime? issueDate;
  DateTime? expirationDate;

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
        fileName = result.files.single.name;
      });

      widget.onDocumentSelected(selectedFile!);
    }
  }

  Future<void> _selectDate(BuildContext context, bool isIssueDate) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        if (isIssueDate) {
          issueDate = selectedDate;
          widget.onIssueDateChanged(
              DateFormat('yyyy-MM-dd').format(selectedDate));
        } else {
          expirationDate = selectedDate;
          widget.onLicenseExpirationDateChanged(
              DateFormat('yyyy-MM-dd').format(selectedDate));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: widget.onLicenseTypeChanged,
          decoration: const InputDecoration(
            labelText: 'License Type',
          ),
        ),
        TextField(
          onChanged: widget.onLicenseNumberChanged,
          decoration: const InputDecoration(
            labelText: 'License Number',
          ),
        ),
        TextField(
          onChanged: widget.onPhoneChanged,
          decoration: const InputDecoration(
            labelText: 'Phone',
          ),
        ),
        TextField(
          onChanged: widget.onServiceChanged,
          decoration: const InputDecoration(
            labelText: 'Service',
          ),
        ),
        TextField(
          onChanged: widget.onIssueDateChanged,
          decoration: const InputDecoration(
            labelText: 'Issue Date',
          ),
        ),
        TextField(
          onChanged: widget.onLicenseExpirationDateChanged,
          decoration: const InputDecoration(
            labelText: 'Expiration Date',
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _pickDocument,
          child: const Text('Upload License Document'),
        ),
        // Mostrar el nombre del archivo si se ha cargado uno
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'File: $fileName', // Mostrar el nombre del archivo
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
