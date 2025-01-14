import 'package:cloud_functions/cloud_functions.dart';

Future<void> callCalculateAndUpdateProviderRating(String providerId) async {
  try {
    // Inicializar Firebase Functions
    final functions = FirebaseFunctions.instance;

    // Llamar a la función
    final callable =
        functions.httpsCallable('calculateAndUpdateProviderRating');
    await callable.call({'providerId': providerId});

    // Puedes agregar un log adicional si lo deseas
    print('Cloud Function executed successfully.');
  } catch (error) {
    print('Error calling Cloud Function: $error');
  }
}

void onReviewAdded(String providerId) async {
  await callCalculateAndUpdateProviderRating(providerId);
  print('Provider rating calculation triggered.');
}
