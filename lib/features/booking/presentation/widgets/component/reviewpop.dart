import 'package:ezpc_tasks_app/features/performance/data/funtions.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';

Future<void> showCompletionReviewPopup(
  BuildContext context1,
  Map<String, dynamic> order, {
  required bool isReviewingProvider,
}) async {
  double currentRating = 0.0;
  final TextEditingController reviewController = TextEditingController();
  String? errorMessage; // Mensaje de error dinámico

  final bookingId = order['bookingId'] ?? '';
  final providerId = order['providerId'] ?? '';
  final clientId = order['customerId'] ?? '';

  String providerName = "";
  String bookingDate = "";
  String taskName = "";

  // Fetch additional booking details from Firestore
  try {
    final bookingSnapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .get();

    if (bookingSnapshot.exists) {
      final bookingData = bookingSnapshot.data();
      providerName = bookingData?['providerName'] ?? 'Unknown Provider';
      bookingDate = bookingData?['date'] ?? 'Unknown Date';
      taskName = bookingData?['selectedTaskName'] ?? 'Unknown Task';
    }
  } catch (e) {
    debugPrint("Error fetching booking details: $e");
  }

  final Size screenSize = MediaQuery.of(context1).size;
  final double dialogWidth = screenSize.width * 0.85;

  return showDialog(
    context: context1,
    barrierDismissible: false, // No se puede cerrar tocando fuera
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0), // Bordes redondeados
            ),
            child: Container(
              width: dialogWidth,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white, // Fondo blanco
                borderRadius: BorderRadius.circular(25.0), // Bordes redondeados
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),

                    // Ícono dentro del cuadro
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check,
                          size: 40,
                          color: primaryColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Título "Great"
                    const Text(
                      'Great',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),

                    const SizedBox(height: 2),

                    // Subtítulo "Task Success"
                    const Text(
                      'Task Success',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    // Información del proveedor y la tarea
                    Text(
                      'Task by $providerName',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: primaryColor,
                      ),
                    ),

                    /*  Text(
                      'Date: $bookingDate',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),*/

                    Text(
                      'Task: $taskName',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Barra de estrellas (rating)
                    RatingBar.builder(
                      initialRating: 0.0,
                      minRating: 1,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 40.0, // Estrellas grandes
                      itemPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: primaryColor,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          currentRating = rating;
                          errorMessage = null; // Limpiar el mensaje de error
                        });
                      },
                    ),
                    // Mensaje de error dinámico
                    if (errorMessage != null)
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Campo de texto para comentario
                    TextField(
                      controller: reviewController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Describe your concerns here...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: primaryColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: primaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: primaryColor),
                        ),
                      ),
                      onChanged: (text) {
                        setState(() {
                          errorMessage = null; // Limpiar el mensaje de error
                        });
                      },
                    ),

                    const SizedBox(height: 8),

                    const SizedBox(height: 16),

                    // Botón personalizado "Submit"
                    GestureDetector(
                      onTap: () async {
                        if (currentRating == 0.0) {
                          setState(() {
                            errorMessage = 'Please select at least 1 star.';
                          });
                          return;
                        }

                        if (currentRating < 5.0 &&
                            reviewController.text.trim().isEmpty) {
                          setState(() {
                            errorMessage =
                                'Please add a comment for ratings below 5 stars.';
                          });
                          return;
                        }

                        Navigator.pop(context); // Cerrar el diálogo

                        // Guardar la reseña en Firestore
                        await _saveReviewToFirestore(
                          bookingId: bookingId,
                          providerId: providerId,
                          clientId: clientId,
                          rating: currentRating,
                          review: reviewController.text.trim(),
                          isReviewingProvider: isReviewingProvider,
                        );

                        onReviewAdded(providerId);

                        ScaffoldMessenger.of(context1).showSnackBar(
                          const SnackBar(content: Text('Review submitted!')),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Submit',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> _saveReviewToFirestore({
  required String bookingId,
  required String providerId,
  required String clientId,
  required double rating,
  required String review,
  required bool isReviewingProvider,
}) async {
  if (bookingId.isEmpty || providerId.isEmpty || clientId.isEmpty) {
    debugPrint("Can't save review: missing bookingId/providerId/clientId");
    return;
  }

  try {
    final targetUserId = isReviewingProvider ? providerId : clientId;
    final targetLabel = isReviewingProvider ? 'provider' : 'customer';

    final reviewDocRef = FirebaseFirestore.instance
        .collection('reviews')
        .doc(targetUserId)
        .collection('reviews')
        .doc(bookingId);

    await reviewDocRef.set({
      'bookingId': bookingId,
      'providerId': providerId,
      'clientId': clientId,
      'rating': rating,
      'review': review,
      'reviewTarget': targetLabel,
      'createdAt': FieldValue.serverTimestamp(),
    });

    debugPrint("Review saved under userId=$targetUserId, bookingId=$bookingId");
  } catch (e) {
    debugPrint("Error saving review: $e");
  }
}
