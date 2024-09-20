import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para manejar las máscaras y el formateo de entradas
import 'package:file_picker/file_picker.dart';
import 'dart:io';

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

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
        fileName = result.files.single.name; // Almacenar el nombre del archivo
      });

      widget.onDocumentSelected(selectedFile!);
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
        TextFormField(
          onChanged: widget.onPhoneChanged,
          decoration: const InputDecoration(
            labelText: 'Phone',
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _PhoneNumberFormatter(), // Formato para xxx-xxx-xxxx
          ],
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
          onPressed: _pickDocument, // Método para seleccionar documento
          child: Text(selectedFile == null
              ? 'Upload License Document'
              : 'Selected: $fileName'), // Mostrar nombre del archivo
        ),
      ],
    );
  }
}

// Formateador de número de teléfono
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.length > 12) {
      return oldValue; // Limitar a 12 caracteres
    }

    StringBuffer buffer = StringBuffer();
    int selectionIndex = newValue.selection.end;

    int offset = 0;
    for (int i = 0; i < text.length; i++) {
      if (i == 3 || i == 6) {
        buffer.write('-');
        offset++;
      }
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex + offset),
    );
  }
}
