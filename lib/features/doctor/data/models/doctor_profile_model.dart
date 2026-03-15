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
    // Handle both cases: 
    // 1. Data comes from doctor_profiles table (profiles is nested)
    // 2. Data comes from profiles table (doctor_profiles is nested)
    
    String extractedName = json['name'] ?? '';
    Map<String, dynamic>? drProfile;

    if (json['profiles'] != null && json['profiles'] is Map) {
      // Case 1: Query started from doctor_profiles
      extractedName = json['profiles']['name'] ?? '';
      drProfile = json;
    } else if (json['doctor_profiles'] != null) {
      // Case 2: Query started from profiles
      // doctor_profiles might be a list or a single object depending on Supabase version/query
      final dynamic nested = json['doctor_profiles'];
      if (nested is List && nested.isNotEmpty) {
        drProfile = nested[0];
      } else if (nested is Map<String, dynamic>) {
        drProfile = nested;
      }
    } else {
      // Direct query or fallback
      drProfile = json;
    }

    return DoctorProfileModel(
      id: json['id'] ?? drProfile?['id'] ?? '',
      name: extractedName,
      specialization: drProfile?['specialization'] ?? 'General',
      price: (drProfile?['price'] ?? 0).toDouble(),
      bio: drProfile?['bio'] ?? '',
      avatarUrl: drProfile?['avatar_url'] ?? '',
      availableHours: drProfile?['available_hours'] ?? {},
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
