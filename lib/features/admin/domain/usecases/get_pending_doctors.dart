import 'package:dartz/dartz.dart';
import 'package:innerbalance/core/error/failures.dart';
import 'package:innerbalance/core/usecases/usecase.dart';
import 'package:innerbalance/features/admin/domain/repositories/admin_repository.dart';
import 'package:innerbalance/features/auth/domain/entities/user.dart';

class GetPendingDoctors implements UseCase<List<UserEntity>, NoParams> {
  final AdminRepository repository;

  GetPendingDoctors(this.repository);

  @override
  Future<Either<Failure, List<UserEntity>>> call(NoParams params) async {
    return await repository.getPendingDoctors();
  }
}
