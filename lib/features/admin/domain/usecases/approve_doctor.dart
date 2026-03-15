import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:innerbalancee/core/error/failures.dart';
import 'package:innerbalancee/core/usecases/usecase.dart';
import 'package:innerbalancee/features/admin/domain/repositories/admin_repository.dart';

class ApproveDoctor implements UseCase<void, ApproveDoctorParams> {
  final AdminRepository repository;

  ApproveDoctor(this.repository);

  @override
  Future<Either<Failure, void>> call(ApproveDoctorParams params) async {
    return await repository.approveDoctor(params.userId);
  }
}

class ApproveDoctorParams extends Equatable {
  final String userId;

  const ApproveDoctorParams(this.userId);

  @override
  List<Object> get props => [userId];
}
