import 'package:dartz/dartz.dart';
import 'package:innerbalance/core/error/failures.dart';
import 'package:innerbalance/features/auth/domain/entities/user.dart';

abstract class AdminRepository {
  Future<Either<Failure, List<UserEntity>>> getPendingDoctors();
  Future<Either<Failure, void>> approveDoctor(String userId);
}
