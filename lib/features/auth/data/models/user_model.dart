import 'package:innerbalance/features/auth/domain/entities/user.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.role,
    super.isApproved,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['user_metadata']?['name'] ?? 'Unknown',
      role: json['user_metadata']?['role'] ?? 'patient',
      isApproved: json['user_metadata']?['is_approved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'user_metadata': {
        'name': name,
        'role': role,
        'is_approved': isApproved,
      },
    };
  }
  
  factory UserModel.fromSupabaseUser(dynamic user) {
     // This handles the Supabase User object mapping
     final metadata = user.userMetadata ?? {};
     return UserModel(
       id: user.id,
       email: user.email ?? '',
       name: metadata['name'] ?? 'Guest',
       role: metadata['role'] ?? 'patient',
       isApproved: metadata['is_approved'] ?? true, // Guests are auto-approved
     );
  }
}
