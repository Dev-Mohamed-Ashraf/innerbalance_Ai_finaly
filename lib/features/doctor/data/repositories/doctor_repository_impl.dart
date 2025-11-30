import 'package:dartz/dartz.dart';
import 'package:innerbalance/core/error/failures.dart';
import 'package:innerbalance/features/doctor/data/datasources/doctor_remote_data_source.dart';
import 'package:innerbalance/features/doctor/data/models/article_model.dart';
import 'package:innerbalance/features/doctor/data/models/doctor_profile_model.dart';

abstract class DoctorRepository {
  Future<Either<Failure, DoctorProfileModel?>> getDoctorProfile(String userId);
  Future<Either<Failure, void>> updateDoctorProfile(DoctorProfileModel profile);
  Future<Either<Failure, void>> createArticle(ArticleModel article);
  Future<Either<Failure, List<ArticleModel>>> getDoctorArticles(String doctorId);
  Future<Either<Failure, List<Map<String, dynamic>>>> getPendingRequests(String doctorId);
  Future<Either<Failure, void>> updateRequestStatus(String requestId, String status);
  Future<Either<Failure, List<Map<String, dynamic>>>> getMyPatients(String doctorId);
}

class DoctorRepositoryImpl implements DoctorRepository {
  final DoctorRemoteDataSource remoteDataSource;

  DoctorRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, DoctorProfileModel?>> getDoctorProfile(String userId) async {
    try {
      final result = await remoteDataSource.getDoctorProfile(userId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateDoctorProfile(DoctorProfileModel profile) async {
    try {
      await remoteDataSource.updateDoctorProfile(profile);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createArticle(ArticleModel article) async {
    try {
      await remoteDataSource.createArticle(article);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ArticleModel>>> getDoctorArticles(String doctorId) async {
    try {
      final result = await remoteDataSource.getDoctorArticles(doctorId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> getPendingRequests(String doctorId) async {
    try {
      final result = await remoteDataSource.getPendingRequests(doctorId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> updateRequestStatus(String requestId, String status) async {
    try {
      await remoteDataSource.updateRequestStatus(requestId, status);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> getMyPatients(String doctorId) async {
    try {
      final result = await remoteDataSource.getMyPatients(doctorId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
