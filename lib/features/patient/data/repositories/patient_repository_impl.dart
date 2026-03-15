import 'package:dartz/dartz.dart';
import 'package:innerbalancee/core/error/failures.dart';
import 'package:innerbalancee/features/doctor/data/models/article_model.dart';
import 'package:innerbalancee/features/doctor/data/models/doctor_profile_model.dart';
import 'package:innerbalancee/features/patient/data/datasources/patient_remote_data_source.dart';

abstract class PatientRepository {
  Future<Either<Failure, List<ArticleModel>>> getFeedArticles();
  Future<Either<Failure, List<DoctorProfileModel>>> getAllDoctors();
  Future<Either<Failure, void>> sendConnectionRequest(String doctorId);
  Future<Either<Failure, String?>> getConnectionStatus(String doctorId);
  Future<Either<Failure, List<DoctorProfileModel>>> getMyDoctors();
}

class PatientRepositoryImpl implements PatientRepository {
  final PatientRemoteDataSource remoteDataSource;

  PatientRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<ArticleModel>>> getFeedArticles() async {
    try {
      final result = await remoteDataSource.getFeedArticles();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DoctorProfileModel>>> getAllDoctors() async {
    try {
      final result = await remoteDataSource.getAllDoctors();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendConnectionRequest(String doctorId) async {
    try {
      await remoteDataSource.sendConnectionRequest(doctorId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> getConnectionStatus(String doctorId) async {
    try {
      final result = await remoteDataSource.getConnectionStatus(doctorId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<DoctorProfileModel>>> getMyDoctors() async {
    try {
      final result = await remoteDataSource.getMyDoctors();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
