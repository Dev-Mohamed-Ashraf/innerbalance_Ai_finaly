import 'package:dartz/dartz.dart';
import 'package:innerbalancee/core/error/failures.dart';
import 'package:innerbalancee/features/auth/domain/entities/user.dart';

abstract class AdminRepository {
  Future<Either<Failure, List<UserEntity>>> getPendingDoctors();
  Future<Either<Failure, void>> approveDoctor(String userId);
}
