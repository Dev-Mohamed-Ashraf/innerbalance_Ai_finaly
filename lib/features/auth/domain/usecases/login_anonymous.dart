import 'package:dartz/dartz.dart';
import 'package:innerbalance/core/error/failures.dart';
import 'package:innerbalance/core/usecases/usecase.dart';
import 'package:innerbalance/features/auth/domain/entities/user.dart';
import 'package:innerbalance/features/auth/domain/repositories/auth_repository.dart';

class LoginAnonymous implements UseCase<UserEntity, NoParams> {
  final AuthRepository repository;

  LoginAnonymous(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) async {
    return await repository.loginAnonymously();
  }
}
