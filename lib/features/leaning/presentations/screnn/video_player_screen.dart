import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VideoPlayerScreen extends StatelessWidget {
  final String videoUrl;

  const VideoPlayerScreen({Key? key, required this.videoUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String embedUrl = _convertToEmbedUrl(videoUrl);

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..loadRequest(Uri.parse(embedUrl));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }

  /// Convertir URL normal de YouTube a la URL de embed
  String _convertToEmbedUrl(String url) {
    final Uri uri = Uri.parse(url);
    if (uri.host.contains('youtube.com') || uri.host.contains('youtu.be')) {
      final videoId = uri.queryParameters['v'] ?? uri.pathSegments.last;
      return 'https://www.youtube.com/embed/$videoId?autoplay=1&controls=0&modestbranding=1&rel=0';
    }
    return url; // Retorna la URL original si no es válida
  }
}
