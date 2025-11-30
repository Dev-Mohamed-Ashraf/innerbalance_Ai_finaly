import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthLogin extends AuthEvent {
  final String email;
  final String password;

  const AuthLogin({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthRegister extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String role;

  const AuthRegister({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object> get props => [name, email, password, role];
}

class AuthLoginAnonymous extends AuthEvent {}

class AuthCheckStatus extends AuthEvent {}

class AuthLogout extends AuthEvent {}
