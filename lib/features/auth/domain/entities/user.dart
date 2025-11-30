import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role; // 'patient', 'doctor', 'admin'
  final bool isApproved;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.isApproved = false,
  });

  @override
  List<Object?> get props => [id, email, name, role, isApproved];
}
