class VideoModel {
  final String id;
  final String title;
  final String studyGuide;
  final String url;
  final DateTime date;
  final String status; // "coming_soon", "active", "completed"

  VideoModel({
    required this.id,
    required this.title,
    required this.studyGuide,
    required this.url,
    required this.date,
    required this.status,
  });

  // Convertir desde JSON (Firebase)
  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      studyGuide: json['studyGuide'] as String,
      url: json['url'] as String,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
    );
  }

  // Convertir a JSON (para enviar a Firebase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'studyGuide': studyGuide,
      'url': url,
      'date': date.toIso8601String(),
      'status': status,
    };
  }
}
