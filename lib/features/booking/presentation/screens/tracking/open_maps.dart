import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

Future<void> launchMaps(BuildContext context, String address) async {
  final encodedAddress = Uri.encodeComponent(address);
  final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encodedAddress');
  final appleMapsUrl = Uri.parse('https://maps.apple.com/?q=$encodedAddress');
  final fallbackMapUrl =
      Uri.parse('https://maps.google.com/?q=$encodedAddress');

  try {
    // Primero intentamos abrir Google Maps
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    }
    // Luego intentamos abrir Apple Maps en iOS
    else if (await canLaunchUrl(appleMapsUrl)) {
      await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
    }
    // Finalmente, intentamos abrir el mapa en un navegador web
    else if (await canLaunchUrl(fallbackMapUrl)) {
      await launchUrl(fallbackMapUrl, mode: LaunchMode.externalApplication);
    }
    // Si todo falla, mostramos un error
    else {
      throw 'Could not launch map URL';
    }
  } catch (e) {
    // Mostrar error si no se puede abrir ninguna URL
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open map application')),
    );
  }
}
