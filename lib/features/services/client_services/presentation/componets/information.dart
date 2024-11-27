import 'package:ezpc_tasks_app/features/services/client_services/data/booking_provider.dart';
import 'package:ezpc_tasks_app/features/services/client_services/data/client_repository.dart';
import 'package:ezpc_tasks_app/features/services/client_services/model/client_model.dart';
import 'package:ezpc_tasks_app/shared/widgets/customcheckbox.dart';
import 'package:ezpc_tasks_app/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InformationStep extends ConsumerStatefulWidget {
  final VoidCallback onConfirm;

  const InformationStep({super.key, required this.onConfirm});

  @override
  _InformationStepState createState() => _InformationStepState();
}

class _InformationStepState extends ConsumerState<InformationStep> {
  bool applyForAnotherPerson = false;

  @override
  Widget build(BuildContext context) {
    final bookingClient = ref.watch(clientProvider);
    final bookingNotifier = ref.read(bookingProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!applyForAnotherPerson) _buildClientInfo(bookingClient),
          if (applyForAnotherPerson) _buildCustomForm(bookingNotifier),
          CustomCheckboxListTile(
            title: "Apply for another person",
            value: applyForAnotherPerson,
            onChanged: (value) {
              setState(() {
                applyForAnotherPerson = value!;
                bookingNotifier.setForAnotherPerson(applyForAnotherPerson);
              });
            },
          ),
          const SizedBox(height: 16),
          _buildNotesField(bookingNotifier),
          const SizedBox(height: 16),
          PrimaryButton(
            text: "Next",
            onPressed: () {
              if (!applyForAnotherPerson) {
                bookingNotifier.proceedWithClientDetails();
              } else {
                bookingNotifier.proceedWithCustomDetails();
              }

              widget.onConfirm();
            },
          ),
        ],
      ),
    );
  }

  // Client details section
  Widget _buildClientInfo(ClientModel client) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8.0,
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildClientDetailRow("Booking ID:", "#1210185746"),
          _buildClientDetailRow("Name:", client.name),
          _buildClientDetailRow("Phone:", client.phone),
          _buildClientDetailRow("Email:", client.email),
          _buildClientDetailRow("Address:", client.address),
          _buildClientDetailRow("Schedule:", "16 Feb, 2024"), // Example
        ],
      ),
    );
  }

  Widget _buildClientDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  // Form for entering information of another person
  Widget _buildCustomForm(BookingNotifier bookingNotifier) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(labelText: "Full Name"),
          onChanged: (value) {
            bookingNotifier.updateCustomName(value);
          },
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(labelText: "Email"),
          onChanged: (value) {
            bookingNotifier.updateCustomEmail(value);
          },
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(labelText: "Phone Number"),
          onChanged: (value) {
            bookingNotifier.updateCustomPhone(value);
          },
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(labelText: "Address"),
          onChanged: (value) {
            bookingNotifier.updateCustomAddress(value);
          },
        ),
      ],
    );
  }

  // Notes field
  Widget _buildNotesField(BookingNotifier bookingNotifier) {
    return TextField(
      decoration: const InputDecoration(
        labelText: "Short Notes",
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      onChanged: (value) {
        bookingNotifier.updateNotes(value);
      },
    );
  }
}
