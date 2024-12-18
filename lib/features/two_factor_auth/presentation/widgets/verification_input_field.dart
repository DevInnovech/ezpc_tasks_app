import 'package:flutter/material.dart';

class VerificationInputField extends StatelessWidget {
  final int index;

  const VerificationInputField({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const TextField(
        textAlign: TextAlign.center,
        maxLength: 1,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(counterText: ''),
      ),
    );
  }
}
