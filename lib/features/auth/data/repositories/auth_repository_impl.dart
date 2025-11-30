import 'package:dartz/dartz.dart';
import 'package:innerbalance/core/error/failures.dart';
import 'package:innerbalance/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:innerbalance/features/auth/domain/entities/user.dart';
import 'package:innerbalance/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, UserEntity>> loginWithEmailPassword({required String email, required String password}) async {
    try {
      final user = await remoteDataSource.loginWithEmailPassword(email, password);
      return Right(user);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerWithEmailPassword({required String name, required String email, required String password, required String role}) async {
    try {
      final user = await remoteDataSource.registerWithEmailPassword(name, email, password, role);
      return Right(user);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginAnonymously() async {
    try {
      final user = await remoteDataSource.loginAnonymously();
      return Right(user);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      if (user != null) {
        return Right(user);
      }
      return const Left(ServerFailure('No user logged in'));
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
