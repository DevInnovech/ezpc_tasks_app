import 'package:ezpc_tasks_app/features/leaning/models/video_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/video_provider.dart';
import '../widgets/folder_view.dart';

class CompletedTab extends ConsumerWidget {
  const CompletedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videos = ref.watch(videoProvider);

    // Agrupar videos por "Study Guide", excluyendo los de estado "inactive"
    final groupedVideos = <String, List<VideoModel>>{};
    for (var video in videos) {
      if (video.status != 'inactive') {
        groupedVideos.putIfAbsent(video.studyGuide, () => []).add(video);
      }
    }

    if (groupedVideos.isEmpty) {
      return const Center(
        child: Text(
          'No videos available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: groupedVideos.entries.length,
      itemBuilder: (context, index) {
        final entry = groupedVideos.entries.elementAt(index);
        return FolderView(
          title: entry.key,
          videos: entry.value,
        );
      },
    );
  }
}
