import 'package:dartz/dartz.dart';
import 'package:innerbalance/core/error/failures.dart';
import 'package:innerbalance/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> loginWithEmailPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> registerWithEmailPassword({
    required String name,
    required String email,
    required String password,
    required String role,
  });

  Future<Either<Failure, UserEntity>> loginAnonymously();
  
  Future<Either<Failure, void>> logout();
  
  Future<Either<Failure, UserEntity>> getCurrentUser();
}
