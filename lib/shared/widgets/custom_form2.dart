import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'custom_text.dart';
import 'error_text.dart';

class CustomForm2 extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType inputType;
  final Function(String)? onChanged;
  final String? errorText;
  final bool isMandatory;
  final bool isDateField; // Nuevo campo para manejar fechas
  final String? Function(String?)? textValidator; // Validador para texto
  final String? Function(DateTime?)? dateValidator; // Validador para fecha

  const CustomForm2({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.inputType = TextInputType.text,
    this.onChanged,
    this.errorText,
    this.isMandatory = false,
    this.isDateField = false, // Nuevo
    this.textValidator, // Nuevo
    this.dateValidator, // Nuevo
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: label,
          color: Colors.black.withOpacity(0.9),
        ),
        const SizedBox(height: 10.0),
        if (isDateField)
          FormBuilderDateTimePicker(
            name: label,
            initialValue: DateTime.now(),
            inputType: InputType.date,
            format: DateFormat("yyyy-MM-dd"),
            decoration: InputDecoration(
              hintText: hintText,
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Colors.blue, width: 2.0),
              ),
              suffixIcon: suffixIcon,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 12.0,
              ),
            ),
            validator: dateValidator, // Usa el validador de fecha
          )
        else
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: inputType,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText,
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Colors.blue, width: 2.0),
              ),
              suffixIcon: suffixIcon,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 12.0,
              ),
            ),
            validator: textValidator, // Usa el validador de texto
          ),
        if (errorText != null) ErrorText(text: errorText!),
        const SizedBox(height: 20.0),
      ],
    );
  }
}
