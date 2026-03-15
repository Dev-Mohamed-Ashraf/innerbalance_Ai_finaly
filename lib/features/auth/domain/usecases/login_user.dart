import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:innerbalancee/core/error/failures.dart';
import 'package:innerbalancee/core/usecases/usecase.dart';
import 'package:innerbalancee/features/auth/domain/entities/user.dart';
import 'package:innerbalancee/features/auth/domain/repositories/auth_repository.dart';

class LoginUser implements UseCase<UserEntity, LoginUserParams> {
  final AuthRepository repository;

  LoginUser(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginUserParams params) async {
    return await repository.loginWithEmailPassword(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginUserParams extends Equatable {
  final String email;
  final String password;

  const LoginUserParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}
