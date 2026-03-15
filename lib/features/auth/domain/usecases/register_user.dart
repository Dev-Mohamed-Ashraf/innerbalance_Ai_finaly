import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:innerbalancee/core/error/failures.dart';
import 'package:innerbalancee/core/usecases/usecase.dart';
import 'package:innerbalancee/features/auth/domain/entities/user.dart';
import 'package:innerbalancee/features/auth/domain/repositories/auth_repository.dart';

class RegisterUser implements UseCase<UserEntity, RegisterUserParams> {
  final AuthRepository repository;

  RegisterUser(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(RegisterUserParams params) async {
    return await repository.registerWithEmailPassword(
      name: params.name,
      email: params.email,
      password: params.password,
      role: params.role,
    );
  }
}

class RegisterUserParams extends Equatable {
  final String name;
  final String email;
  final String password;
  final String role;

  const RegisterUserParams({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object> get props => [name, email, password, role];
}
