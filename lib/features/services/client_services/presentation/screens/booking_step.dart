import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/features/services/client_services/data/booking_provider.dart';
import 'package:ezpc_tasks_app/features/services/client_services/model/service_model.dart';
import 'package:ezpc_tasks_app/features/services/client_services/presentation/componets/PaymentBottomSheet.dart';
import 'package:ezpc_tasks_app/features/services/client_services/presentation/componets/PaymentSuccessDialog.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BookingStepScreen extends ConsumerStatefulWidget {
  const BookingStepScreen({super.key});

  @override
  _BookingStepScreenState createState() => _BookingStepScreenState();
}

class _BookingStepScreenState extends ConsumerState<BookingStepScreen> {
  final PageController _controller =
      PageController(initialPage: 0, keepPage: true); // Start from Task step
  int _pageIndex = 0; // Starting step: Task
  bool _isBottomSheetVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Book Now"),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading tasks."));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No tasks available."));
          }

          final tasks = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ServiceModel.fromMap(
                data); // Aquí usamos el método `fromMap`
          }).toList();

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                leading: Image.network(task.image,
                    width: 50, height: 50, fit: BoxFit.cover),
                title: Text(task.name),
                subtitle: Text(task.details),
                trailing: Text("\$${task.price}"),
                onTap: () {
                  // Lógica para seleccionar el servicio
                },
              );
            },
          );
        },
      ),
    );
  }

  bool _validateClientInfo(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);

    if (bookingState.isForAnotherPerson) {
      return bookingState.name.isNotEmpty &&
          bookingState.email.isNotEmpty &&
          bookingState.phone.isNotEmpty &&
          bookingState.address.isNotEmpty;
    }
    return true;
  }

  void _onStepTapped(int index) {
    setState(() {
      _pageIndex = index;
      _controller.jumpToPage(index);
    });
  }

  void _showBottomSheet(BuildContext context) {
    setState(() {
      _isBottomSheetVisible = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return PaymentBottomSheet(
          onPaymentConfirmed: _onPaymentConfirmed,
          onSheetClosed: _onPaymentSheetClosed,
        );
      },
    );
  }

  void _onPaymentConfirmed() {
    setState(() {
      _isBottomSheetVisible = false;
    });

    Navigator.pop(context);

    Future.delayed(const Duration(milliseconds: 300), () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const PaymentSuccessDialog(
            serviceName: 'Fixing',
            hourlyRate: '\$25.00',
            serviceDuration: '4hrs',
            totalAmount: '\$130.00',
          );
        },
      );
    });
  }

  void _onPaymentSheetClosed() {
    setState(() {
      _isBottomSheetVisible = false;
      _pageIndex = 1;
    });
  }
}

class TaskList extends StatelessWidget {
  final List<ServiceModel> tasks;

  const TaskList({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return ListTile(
          title: Text(task.categoryId as String),
          subtitle: Text("Provider: ${task.name}"),
          trailing: Text("\$${task.price.toString()}"),
          onTap: () {
            // Handle task selection or navigate to details
          },
        );
      },
    );
  }
}

class BookingStepper extends StatelessWidget {
  final int pageIndex;
  final ValueChanged<int> onStepTapped;

  const BookingStepper(
      {super.key, required this.pageIndex, required this.onStepTapped});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        BookingStepButton(
            stepIndex: 0,
            currentStep: pageIndex,
            label: 'Task',
            onTap: onStepTapped),
        BookingStepButton(
            stepIndex: 1,
            currentStep: pageIndex,
            label: 'Information',
            onTap: onStepTapped),
        BookingStepButton(
            stepIndex: 2,
            currentStep: pageIndex,
            label: 'Confirm',
            onTap: onStepTapped),
      ],
    );
  }
}

class BookingStepButton extends StatelessWidget {
  final int stepIndex;
  final int currentStep;
  final String label;
  final ValueChanged<int> onTap;

  const BookingStepButton(
      {super.key,
      required this.stepIndex,
      required this.currentStep,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isActive = currentStep >= stepIndex;
    return GestureDetector(
      onTap: () => onTap(stepIndex),
      child: Container(
        width: 100.w,
        height: 40.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(color: isActive ? Colors.white : Colors.black)),
      ),
    );
  }
}
