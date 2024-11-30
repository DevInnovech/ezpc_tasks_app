import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart'; // Asegúrate de agregar esta dependencia en pubspec.yaml

class GooglePlacesService {
  static Future<String?> getAddressPrediction(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      builder: (context) => const GooglePlacesAutocomplete(),
    );
  }
}

class GooglePlacesAutocomplete extends StatefulWidget {
  const GooglePlacesAutocomplete({super.key});

  @override
  _GooglePlacesAutocompleteState createState() =>
      _GooglePlacesAutocompleteState();
}

class _GooglePlacesAutocompleteState extends State<GooglePlacesAutocomplete> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Search Address'),
      content: SizedBox(
        height: 300,
        child: GooglePlaceAutoCompleteTextField(
          textEditingController: _searchController,
          googleAPIKey:
              "AIzaSyDwxlmeFfLFPceI3B4J35xq7UqHan7iA6s", // Reemplaza con tu API Key
          inputDecoration: const InputDecoration(
            hintText: 'Enter address',
            border: OutlineInputBorder(),
          ),
          debounceTime:
              800, // Retraso de debounce para optimizar llamadas a la API
          countries: const [
            "US",
            "MX",
            "CA"
          ], // Opcional: restringir por países
          getPlaceDetailWithLatLng: (prediction) {
            Navigator.of(context).pop(prediction.description);
          },
          itemClick: (prediction) {
            _searchController.text = prediction.description!;
            Navigator.of(context).pop(prediction.description);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
