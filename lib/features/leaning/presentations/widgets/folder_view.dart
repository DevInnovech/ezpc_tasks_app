import 'package:ezpc_tasks_app/features/leaning/presentations/widgets/video_card.dart';
import 'package:flutter/material.dart';
import '../../models/video_models.dart';

class FolderView extends StatelessWidget {
  final String title;
  final List<VideoModel> videos;

  const FolderView({Key? key, required this.title, required this.videos})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.folder, color: Colors.blue, size: 40),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text('${videos.length} videos'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideosByGuideScreen(
                title: title,
                videos: videos,
              ),
            ),
          );
        },
      ),
    );
  }
}

// Pantalla para mostrar videos de un "Study Guide"
class VideosByGuideScreen extends StatelessWidget {
  final String title;
  final List<VideoModel> videos;

  const VideosByGuideScreen(
      {Key? key, required this.title, required this.videos})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          return VideoCard(
              video: videos[index]); // Usa el widget actualizado de tarjeta
        },
      ),
    );
  }
}
