import 'package:dartz/dartz.dart';
import 'package:innerbalancee/core/error/failures.dart';
import 'package:innerbalancee/features/admin/data/datasources/admin_remote_data_source.dart';
import 'package:innerbalancee/features/admin/domain/repositories/admin_repository.dart';
import 'package:innerbalancee/features/auth/domain/entities/user.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<UserEntity>>> getPendingDoctors() async {
    try {
      final doctors = await remoteDataSource.getPendingDoctors();
      return Right(doctors);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> approveDoctor(String userId) async {
    try {
      await remoteDataSource.approveDoctor(userId);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
