import 'package:dartz/dartz.dart';
import 'package:innerbalancee/core/error/failures.dart';
import 'package:innerbalancee/core/usecases/usecase.dart';
import 'package:innerbalancee/features/auth/domain/entities/user.dart';
import 'package:innerbalancee/features/auth/domain/repositories/auth_repository.dart';

class LoginAnonymous implements UseCase<UserEntity, NoParams> {
  final AuthRepository repository;

  LoginAnonymous(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) async {
    return await repository.loginAnonymously();
  }
}
