import 'package:ezpc_tasks_app/features/leaning/presentations/screnn/video_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:ezpc_tasks_app/features/leaning/models/video_models.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoCard extends StatelessWidget {
  final VideoModel video;

  const VideoCard({Key? key, required this.video}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      shadowColor: Colors.grey.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              // Imagen del video (miniatura de YouTube)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Image.network(
                    "https://img.youtube.com/vi/${video.url.split('v=').last}/hqdefault.jpg",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.error, size: 50),
                    ),
                  ),
                ),
              ),
              // Botón de YouTube en la esquina superior derecha
              Positioned(
                top: 8,
                right: 8,
                child: InkWell(
                  onTap: () => _openInYouTube(video.url),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_circle_fill,
                      color: Colors.red,
                      size: 30,
                    ),
                  ),
                ),
              ),
              // Botón de reproducción en el centro de la imagen
              Positioned.fill(
                child: Center(
                  child: InkWell(
                    onTap: () => _viewInApp(context, video.url),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.play_arrow,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Estado y fecha
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Etiqueta de estado
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: video.status == 'active'
                            ? Colors.green
                            : Colors.orangeAccent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        video.status.toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Fecha
                    Text(
                      "${video.date.day} ${_getMonth(video.date.month)}, ${video.date.year}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Título del video
                Text(
                  video.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                // Información de la guía de estudio
                Text(
                  'Study Guide: ${video.studyGuide}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _openInYouTube(String videoUrl) async {
    // Abrir el video en YouTube
    final uri = Uri.parse(videoUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint("Could not launch $videoUrl");
    }
  }

  void _viewInApp(BuildContext context, String videoUrl) {
    // Navegar al reproductor de video dentro de la app
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoUrl: videoUrl),
      ),
    );
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
