import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentMethodSelection extends ConsumerStatefulWidget {
  const PaymentMethodSelection({super.key});

  @override
  _PaymentMethodSelectionState createState() => _PaymentMethodSelectionState();
}

class _PaymentMethodSelectionState
    extends ConsumerState<PaymentMethodSelection> {
  String selectedMethod = 'visa'; // Default to Visa option

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Selected credit card option (Visa)
        GestureDetector(
          onTap: () {
            setState(() {
              selectedMethod = 'visa'; // Visa selected
            });
          },
          child: ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text("Visa •••• 1111"),
            trailing: Icon(
              selectedMethod == 'visa'
                  ? Icons.check_circle
                  : Icons.check_circle_outline,
              color: selectedMethod == 'visa' ? Colors.blue : Colors.grey,
            ),
          ),
        ),
        // Affirm payment option
        GestureDetector(
          onTap: () {
            setState(() {
              selectedMethod = 'affirm'; // Affirm selected
            });
          },
          child: ListTile(
            leading: const Icon(Icons.email),
            title: const Text("Affirm •••• 2@gmail.com"),
            trailing: Icon(
              selectedMethod == 'affirm'
                  ? Icons.check_circle
                  : Icons.check_circle_outline,
              color: selectedMethod == 'affirm' ? Colors.blue : Colors.grey,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Change payment method option
        GestureDetector(
          onTap: () {
            // Handle the logic to change the payment method
          },
          child: const ListTile(
            leading: Icon(Icons.payment),
            title: Text("Change method of payment"),
          ),
        ),
      ],
    );
  }
}
