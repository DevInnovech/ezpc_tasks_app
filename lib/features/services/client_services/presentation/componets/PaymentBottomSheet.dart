import 'package:ezpc_tasks_app/features/services/client_services/presentation/componets/PaymentMethodSelection.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class PaymentBottomSheet extends StatefulWidget {
  final VoidCallback onPaymentConfirmed;
  final VoidCallback onSheetClosed;

  const PaymentBottomSheet({
    Key? key,
    required this.onPaymentConfirmed,
    required this.onSheetClosed,
  }) : super(key: key);

  @override
  _PaymentBottomSheetState createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  bool showPaymentDetails =
      true; // Toggle between service details and payment method

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.onSheetClosed();
        return true;
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            showPaymentDetails ? _buildServiceDetails() : _buildPaymentMethod(),
          ],
        ),
      ),
    );
  }

  // Service details (Part 1)
  Widget _buildServiceDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Reliable Pipe and Drain Experts",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Utils.verticalSpace(16),
        _buildDetailRow("Hourly Rate", "\$25.00"),
        _buildDetailRow("Services Size", "+4hr"),
        _buildDetailRow("Services", "\$100.00"),
        _buildDetailRow("Package Fee", "\$15.00"),
        _buildDetailRow("Extra Service", "\$15.00"),
        const Divider(),
        _buildDetailRow("Total", "\$130.00", isTotal: true),
        Utils.verticalSpace(24),
        PrimaryButton(
          text: "Proceed to Payment",
          onPressed: () {
            setState(() {
              showPaymentDetails = false; // Proceed to the payment method part
            });
          },
        ),
      ],
    );
  }

  // Payment method selection (Part 2)
  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Payment Method Selection",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Utils.verticalSpace(16),
        const PaymentMethodSelection(), // Reusing the PaymentMethodSelection widget
        Utils.verticalSpace(24),
        PrimaryButton(
          text: "Proceed to Payment",
          onPressed: widget.onPaymentConfirmed, // Finalize the payment
        ),
        const SizedBox(height: 8),
        PrimaryButton(
          text: "Pay over time with Affirm",
          onPressed: widget.onPaymentConfirmed, // Handle Affirm payment
        ),
        Utils.verticalSpace(16),
        const Text(
          textAlign: TextAlign.center,
          "Make 4 interest-free payments with zero fees.\nJust select affirm at checkout",
          style: TextStyle(
            fontSize: 12,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  // Helper for service details rows
  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
