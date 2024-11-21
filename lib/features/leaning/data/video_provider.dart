import 'package:ezpc_tasks_app/features/leaning/models/video_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VideoNotifier extends StateNotifier<List<VideoModel>> {
  VideoNotifier() : super([]) {
    _loadFakeVideos(); // Cargar datos falsos al inicializar
  }
  // Método para cargar datos falsos
  void _loadFakeVideos() {
    state = [
      VideoModel(
        id: "video1",
        title: "Flutter Tutorial for Beginners #1 - Intro & Setup",
        studyGuide: "Flutter Basics",
        url: "https://www.youtube.com/watch?v=1ukSR1GRtMU",
        date: DateTime.now().subtract(const Duration(days: 2)),
        status: "active",
      ),
      VideoModel(
        id: "video2",
        title: "Color Your Night - Persona 3 Reload",
        studyGuide: "Advanced Flutter",
        url: "https://www.youtube.com/watch?v=6Zc_yaxlui0",
        date: DateTime.now().add(const Duration(days: 3)),
        status: "coming_soon",
      ),
      VideoModel(
        id: "video3",
        title: "Dart Programming Tutorial - Full Course",
        studyGuide: "Programming",
        url: "https://www.youtube.com/watch?v=Ej_Pcr4uC2Q",
        date: DateTime.now().subtract(const Duration(days: 5)),
        status: "completed",
      ),
      VideoModel(
        id: "video4",
        title: "Phonics Song | k, l, m, n, o | ABC with Hands",
        studyGuide: "Flutter Basics",
        url: "https://www.youtube.com/watch?v=2AcIQ-eKfDk",
        date: DateTime.now(),
        status: "active",
      ),
      VideoModel(
        id: "video5",
        title:
            "Kylie Cantrall, Alex Boniello - Red (From 'Descendants: The Rise of Red')",
        studyGuide: "Flutter Basics",
        url: "https://www.youtube.com/watch?v=mIuiMgefKBk",
        date: DateTime.now().add(const Duration(days: 5)),
        status: "coming_soon",
      ),
      VideoModel(
        id: "video6",
        title: "Auli'i Cravalho - How Far I'll Go (from Moana/Official Video)",
        studyGuide: "Programming",
        url: "https://www.youtube.com/watch?v=cPAbx5kgCJo",
        date: DateTime.now().subtract(const Duration(days: 10)),
        status: "completed",
      ),
      VideoModel(
        id: "video7",
        title: "Ed Sheeran - Thinking Out Loud (Official Music Video)",
        studyGuide: "Advanced Flutter",
        url: "https://www.youtube.com/watch?v=lp-EO5I60KA",
        date: DateTime.now().subtract(const Duration(days: 1)),
        status: "active",
      ),
      VideoModel(
        id: "video8",
        title: "Learn Numbers, Colors, Counting and Shapes with Ms Rachel",
        studyGuide: "Flutter Basics",
        url: "https://www.youtube.com/watch?v=hOHrqPI9bVk",
        date: DateTime.now().add(const Duration(days: 8)),
        status: "coming_soon",
      ),
      VideoModel(
        id: "video9",
        title:
            "JUST STAND STILL PLEASE | Pico Park 2 (Feat. Skip The Tutorial and Dillongoo)",
        studyGuide: "Advanced Flutter",
        url: "https://www.youtube.com/watch?v=Ej2fBcq7jmM",
        date: DateTime.now().subtract(const Duration(days: 7)),
        status: "completed",
      ),
      VideoModel(
        id: "video10",
        title: "Can YOU Fix Climate Change?",
        studyGuide: "Programming",
        url: "https://www.youtube.com/watch?v=yiw6_JakZFc",
        date: DateTime.now(),
        status: "active",
      ),
    ];
  }

  // Método futuro para cargar datos desde Firebase
  Future<void> loadVideosFromFirebase() async {
    // Ejemplo de cómo cargar datos desde Firebase
    // final querySnapshot = await FirebaseFirestore.instance.collection('videos').get();
    // final videos = querySnapshot.docs.map((doc) => VideoModel.fromJson(doc.data())).toList();
    // state = videos;

    throw UnimplementedError("Integrar con Firebase aquí");
  }

  // Filtrar videos por estado
  List<VideoModel> filterByStatus(String status) {
    return state.where((video) => video.status == status).toList();
  }
}

// Proveedor del VideoNotifier
final videoProvider =
    StateNotifierProvider<VideoNotifier, List<VideoModel>>((ref) {
  return VideoNotifier();
});
