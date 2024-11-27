import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class LicenseDocumentInput extends StatefulWidget {
  final void Function(String licenseType) onLicenseTypeChanged;
  final void Function(String licenseNumber) onLicenseNumberChanged;
  final void Function(String phone) onPhoneChanged;
  final void Function(String issueDate) onIssueDateChanged;
  final void Function(String expirationDate) onLicenseExpirationDateChanged;
  final void Function(File file) onDocumentSelected;

  const LicenseDocumentInput({
    super.key,
    required this.onLicenseTypeChanged,
    required this.onLicenseNumberChanged,
    required this.onPhoneChanged,
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
  final _formKey = GlobalKey<FormState>();

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

    setState(() {
      if (isIssueDate) {
        issueDate = selectedDate;
        widget
            .onIssueDateChanged(DateFormat('yyyy-MM-dd').format(selectedDate!));
      } else {
        expirationDate = selectedDate;
        widget.onLicenseExpirationDateChanged(
            DateFormat('yyyy-MM-dd').format(selectedDate!));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey, // Formulario para validaciones
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            onChanged: widget.onLicenseTypeChanged,
            decoration: const InputDecoration(
              labelText: 'License Type',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter license type';
              }
              return null;
            },
          ),
          TextFormField(
            onChanged: widget.onLicenseNumberChanged,
            decoration: const InputDecoration(
              labelText: 'License Number',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter license number';
              }
              if (value.length < 6) {
                return 'License number must be at least 6 digits';
              }
              return null;
            },
          ),
          TextFormField(
            onChanged: widget.onPhoneChanged,
            decoration: const InputDecoration(
              labelText: 'Phone',
            ),
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
              _PhoneNumberInputFormatter(), // Formateador personalizado para el teléfono
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter phone number';
              }
              if (value.length != 10) {
                return 'Phone number must be exactly 10 digits';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _selectDate(context, true),
            child: AbsorbPointer(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: issueDate == null
                      ? 'Issue Date'
                      : 'Issue Date: ${DateFormat('yyyy-MM-dd').format(issueDate!)}',
                ),
                validator: (value) {
                  if (issueDate == null) {
                    return 'Please select issue date';
                  }
                  return null;
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _selectDate(context, false),
            child: AbsorbPointer(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: expirationDate == null
                      ? 'Expiration Date'
                      : 'Expiration Date: ${DateFormat('yyyy-MM-dd').format(expirationDate!)}',
                ),
                validator: (value) {
                  if (expirationDate == null) {
                    return 'Please select expiration date';
                  }
                  if (issueDate != null && expirationDate != null) {
                    if (expirationDate!.isBefore(issueDate!)) {
                      return 'Expiration date must be after issue date';
                    }
                  }
                  return null;
                },
              ),
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
              selectedFile == null ? 'No file uploaded' : 'File: $fileName',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (selectedFile == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please upload a document')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Form submitted successfully')),
                  );
                }
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

// Formateador personalizado para el campo Phone
class _PhoneNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Elimina todos los caracteres no numéricos
    String cleaned = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Formatear el número según el formato XXX-XXX-XXXX
    if (cleaned.length >= 6) {
      final part1 = cleaned.substring(0, 3);
      final part2 = cleaned.substring(3, 6);
      final part3 =
          cleaned.substring(6, cleaned.length > 10 ? 10 : cleaned.length);
      cleaned = '$part1-$part2-$part3';
    } else if (cleaned.length >= 3) {
      final part1 = cleaned.substring(0, 3);
      final part2 = cleaned.substring(3, cleaned.length);
      cleaned = '$part1-$part2';
    }

    return TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: cleaned.length),
    );
  }
}
