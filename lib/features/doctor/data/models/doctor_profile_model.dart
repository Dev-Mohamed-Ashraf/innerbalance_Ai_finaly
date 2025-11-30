class DoctorProfileModel {
  final String id;
  final String name;
  final String specialization;
  final double price;
  final String bio;
  final String avatarUrl;
  final Map<String, dynamic> availableHours;

  DoctorProfileModel({
    required this.id,
    required this.name,
    required this.specialization,
    required this.price,
    required this.bio,
    required this.avatarUrl,
    required this.availableHours,
  });

  factory DoctorProfileModel.fromJson(Map<String, dynamic> json) {
    String extractedName = '';
    if (json['profiles'] != null && json['profiles'] is Map) {
      extractedName = json['profiles']['name'] ?? '';
    } else if (json['name'] != null) {
      extractedName = json['name'];
    }

    return DoctorProfileModel(
      id: json['id'],
      name: extractedName,
      specialization: json['specialization'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      bio: json['bio'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      availableHours: json['available_hours'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // 'name' is in profiles table, not doctor_profiles, so we don't send it back usually
      'specialization': specialization,
      'price': price,
      'bio': bio,
      'avatar_url': avatarUrl,
      'available_hours': availableHours,
    };
  }
}
