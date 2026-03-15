class ArticleModel {
  final String id;
  final String doctorId;
  final String title;
  final String content;
  final DateTime createdAt;
  final String? imageUrl;
  final String? doctorName;
  final String? doctorAvatarUrl;

  ArticleModel({
    required this.id,
    required this.doctorId,
    required this.title,
    required this.content,
    required this.createdAt,
    this.imageUrl,
    this.doctorName,
    this.doctorAvatarUrl,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    // Check for nested profile data if from join query
    String? name;
    String? avatar;
    if (json['profiles'] != null && json['profiles'] is Map) {
      name = json['profiles']['name'];
    }
    if (json['doctor_profiles'] != null) {
      final dp = json['doctor_profiles'];
      if (dp is List && dp.isNotEmpty) {
        avatar = dp[0]['avatar_url'];
      } else if (dp is Map) {
        avatar = dp['avatar_url'];
      }
    }

    return ArticleModel(
      id: json['id'],
      doctorId: json['doctor_id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      imageUrl: json['image_url'],
      doctorName: name ?? json['doctor_name'],
      doctorAvatarUrl: avatar ?? json['doctor_avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctor_id': doctorId,
      'title': title,
      'content': content,
      'image_url': imageUrl,
      // 'created_at' is handled by Supabase default
    };
  }
}
