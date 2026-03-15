import 'package:dartz/dartz.dart';
import 'package:innerbalancee/core/error/failures.dart';
import 'package:innerbalancee/core/usecases/usecase.dart';
import 'package:innerbalancee/features/admin/domain/repositories/admin_repository.dart';
import 'package:innerbalancee/features/auth/domain/entities/user.dart';

class GetPendingDoctors implements UseCase<List<UserEntity>, NoParams> {
  final AdminRepository repository;

  GetPendingDoctors(this.repository);

  @override
  Future<Either<Failure, List<UserEntity>>> call(NoParams params) async {
    return await repository.getPendingDoctors();
  }
}
