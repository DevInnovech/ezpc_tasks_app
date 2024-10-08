import 'package:ezpc_tasks_app/features/services/client_services/data/booking_provider.dart';
import 'package:ezpc_tasks_app/features/services/client_services/model/service_model.dart';
import 'package:ezpc_tasks_app/features/services/client_services/presentation/componets/PaymentBottomSheet.dart';
import 'package:ezpc_tasks_app/features/services/client_services/presentation/componets/PaymentSuccessDialog.dart';
import 'package:ezpc_tasks_app/features/services/client_services/presentation/componets/information.dart';
import 'package:ezpc_tasks_app/shared/utils/utils/utils.dart';
import 'package:ezpc_tasks_app/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BookingStepScreen extends ConsumerStatefulWidget {
  final ServiceModel selectedService;
  final String selectedSize;
  final String hours;
  final int quantity;
  final String time;

  const BookingStepScreen({
    Key? key,
    required this.selectedService,
    required this.selectedSize,
    required this.hours,
    required this.quantity,
    required this.time,
  }) : super(key: key);

  @override
  _BookingStepScreenState createState() => _BookingStepScreenState();
}

class _BookingStepScreenState extends ConsumerState<BookingStepScreen> {
  final PageController _controller =
      PageController(initialPage: 1, keepPage: true); // Start from Information
  int _pageIndex = 1; // Information as the starting step
  bool _isBottomSheetVisible = false;

  @override
  void initState() {
    super.initState();
    // Marcar ambos pasos "Task" y "Information" como completados al iniciar
    _pageIndex = 2; // Mover directamente al paso de confirmación
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Book Now"),
      body: Column(
        children: [
          Utils.verticalSpace(16),
          BookingStepper(pageIndex: _pageIndex, onStepTapped: _onStepTapped),
          Utils.verticalSpace(16),
          Expanded(
            child: PageView(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _pageIndex = index;
                });
              },
              children: [
                InformationStep(
                  onConfirm: () {
                    // Validar solo si "Apply for another person" está marcada
                    if (_validateClientInfo(context)) {
                      _showBottomSheet(context); // Proceder a la confirmación
                    } else {
                      // Mostrar mensaje de error si no se han llenado los campos requeridos
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Please complete the form before proceeding.')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
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
          onSheetClosed:
              _onPaymentSheetClosed, // Add a handler for closing the sheet
        );
      },
    );
  }

  void _onPaymentConfirmed() {
    setState(() {
      _isBottomSheetVisible = false;
    });

    // Cerrar el BottomSheet antes de mostrar el dialog
    Navigator.pop(context);

    // Mostrar el diálogo de éxito de pago
    Future.delayed(Duration(milliseconds: 300), () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return PaymentSuccessDialog(
            serviceName: 'Fixing', // Example
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
      _pageIndex =
          1; // Volver al paso de "Information" si se cierra sin confirmar
    });
  }
}

class BookingStepper extends StatelessWidget {
  final int pageIndex;
  final ValueChanged<int> onStepTapped;

  const BookingStepper({
    Key? key,
    required this.pageIndex,
    required this.onStepTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // "Task" step always completed
        BookingStepButton(
          stepIndex: 0,
          currentStep: pageIndex,
          label: 'Task',
          onTap: onStepTapped,
        ),
        // "Information" step always completed
        BookingStepButton(
          stepIndex: 1,
          currentStep: pageIndex,
          label: 'Information',
          onTap: onStepTapped,
        ),
        // "Confirm" step only active when the bottom sheet is open
        BookingStepButton(
          stepIndex: 2,
          currentStep: pageIndex,
          label: 'Confirm',
          onTap: onStepTapped,
        ),
      ],
    );
  }
}

class BookingStepButton extends StatelessWidget {
  final int stepIndex;
  final int currentStep;
  final String label;
  final ValueChanged<int> onTap;

  const BookingStepButton({
    Key? key,
    required this.stepIndex,
    required this.currentStep,
    required this.label,
    required this.onTap,
  }) : super(key: key);

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
