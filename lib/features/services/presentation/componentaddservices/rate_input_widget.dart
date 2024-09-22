import 'package:flutter/material.dart';

class RateInputWidget extends StatelessWidget {
  final void Function(double) onRateChanged;

  const RateInputWidget({Key? key, required this.onRateChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rate',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter rate',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            final rate = double.tryParse(value);
            if (rate != null) {
              onRateChanged(rate);
            }
          },
        ),
      ],
    );
  }
}
