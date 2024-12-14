import 'package:ezpc_tasks_app/features/leaning/presentations/screnn/completed.dart';
import 'package:ezpc_tasks_app/shared/utils/theme/constraints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/video_provider.dart';
import '../widgets/video_card.dart';

class LearningScreen extends ConsumerWidget {
  const LearningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoNotifier = ref.watch(videoProvider.notifier);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor:
            const Color(0xFFF5F5F5), // Color de fondo personalizado
        appBar: AppBar(
          title: const Text('Learning'),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor:
                primaryColor, // Color de la línea debajo del tab activo
            indicatorWeight: 6, // Grosor de la línea
            labelColor: primaryColor, // Color del texto del tab activo
            unselectedLabelColor:
                Colors.grey, // Color del texto de los tabs inactivos
            labelStyle: TextStyle(
              fontSize: 16, // Tamaño del texto del tab activo
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 16, // Tamaño del texto de los tabs inactivos
            ),
            tabs: [
              Tab(text: 'Coming Soon'),
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Pestaña para "Coming Soon"
            VideoList(status: 'coming_soon', videoNotifier: videoNotifier),
            // Pestaña para "Active"
            VideoList(status: 'active', videoNotifier: videoNotifier),
            // Pestaña para "Completed" usando el CompletedTab
            const CompletedTab(),
          ],
        ),
      ),
    );
  }
}

class VideoList extends StatelessWidget {
  final String status;
  final VideoNotifier videoNotifier;

  const VideoList(
      {super.key, required this.status, required this.videoNotifier});

  @override
  Widget build(BuildContext context) {
    final filteredVideos = videoNotifier.filterByStatus(status);

    if (filteredVideos.isEmpty) {
      return const Center(
        child: Text(
          'No videos available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredVideos.length,
      itemBuilder: (context, index) {
        final video = filteredVideos[index];
        return VideoCard(video: video);
      },
    );
  }
}
