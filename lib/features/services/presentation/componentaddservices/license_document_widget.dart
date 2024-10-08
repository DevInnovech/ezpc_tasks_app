import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
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
        TextFormField(
          onChanged: widget.onPhoneChanged,
          decoration: const InputDecoration(
            labelText: 'Phone',
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
            _PhoneNumberInputFormatter(), // Agregar el formateador personalizado
          ],
        ),
        TextField(
          onChanged: widget.onServiceChanged,
          decoration: const InputDecoration(
            labelText: 'Service',
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _selectDate(context, true),
          child: AbsorbPointer(
            child: TextField(
              decoration: InputDecoration(
                labelText: issueDate == null
                    ? 'Issue Date'
                    : 'Issue Date: ${DateFormat('yyyy-MM-dd').format(issueDate!)}',
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _selectDate(context, false),
          child: AbsorbPointer(
            child: TextField(
              decoration: InputDecoration(
                labelText: expirationDate == null
                    ? 'Expiration Date'
                    : 'Expiration Date: ${DateFormat('yyyy-MM-dd').format(expirationDate!)}',
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _pickDocument,
          child: Text(selectedFile == null
              ? 'Upload License Document'
              : 'Selected: $fileName'),
        ),
      ],
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
