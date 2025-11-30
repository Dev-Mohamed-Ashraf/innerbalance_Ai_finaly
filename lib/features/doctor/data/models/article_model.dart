class ArticleModel {
  final String id;
  final String doctorId;
  final String title;
  final String content;
  final DateTime createdAt;

  ArticleModel({
    required this.id,
    required this.doctorId,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'],
      doctorId: json['doctor_id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctor_id': doctorId,
      'title': title,
      'content': content,
      // 'created_at' is handled by Supabase default
    };
  }
}
