import 'package:get_it/get_it.dart';
import 'package:innerbalance/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:innerbalance/features/doctor/data/datasources/doctor_remote_data_source.dart';
import 'package:innerbalance/features/doctor/data/repositories/doctor_repository_impl.dart';
import 'package:innerbalance/features/patient/data/datasources/patient_remote_data_source.dart';
import 'package:innerbalance/features/patient/data/repositories/patient_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:innerbalance/core/services/face_recognition_service.dart';
import 'package:innerbalance/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:innerbalance/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:innerbalance/features/auth/domain/repositories/auth_repository.dart';
import 'package:innerbalance/features/auth/domain/usecases/login_anonymous.dart';
import 'package:innerbalance/features/auth/domain/usecases/login_user.dart';
import 'package:innerbalance/features/auth/domain/usecases/register_user.dart';
import 'package:innerbalance/features/admin/data/datasources/admin_remote_data_source.dart';
import 'package:innerbalance/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:innerbalance/features/admin/domain/repositories/admin_repository.dart';
import 'package:innerbalance/features/admin/domain/usecases/approve_doctor.dart';
import 'package:innerbalance/features/admin/domain/usecases/get_pending_doctors.dart';
import 'package:innerbalance/features/admin/presentation/bloc/admin_bloc.dart';
final sl = GetIt.instance;

Future<void> init() async {
  // External
  await Supabase.initialize(
    url: 'https://amzbdqmeovitxvssoten.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFtemJkcW1lb3ZpdHh2c3NvdGVuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ0NjEwNzAsImV4cCI6MjA4MDAzNzA3MH0.a0TL8f-CLUFyGvNkRRlb70_w4NRaBAV0LKupOts8wsM',
  );
  sl.registerLazySingleton(() => Supabase.instance.client);

  // Core
  sl.registerLazySingleton<FaceRecognitionService>(() => FaceRecognitionServiceImpl());

  // Features - Auth
  _initAuth();

  // Features - Admin
  _initAdmin();

  // Features - Doctor
  _initDoctor();

  // Features - Patient
  _initPatient();
}

void _initPatient() {
  // Datasources
  sl.registerLazySingleton<PatientRemoteDataSource>(
    () => PatientRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<PatientRepository>(
    () => PatientRepositoryImpl(sl()),
  );
}

void _initDoctor() {
  // Datasources
  sl.registerLazySingleton<DoctorRemoteDataSource>(
    () => DoctorRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<DoctorRepository>(
    () => DoctorRepositoryImpl(sl()),
  );
}

void _initAuth() {
  // Datasources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => LoginAnonymous(sl()));

  // Blocs
  sl.registerFactory(
    () => AuthBloc(
      loginUser: sl(),
      registerUser: sl(),
      loginAnonymous: sl(),
      authRepository: sl(),
    ),
  );

  // Features - Admin
  // _initAdmin(); // Removed duplicate call
}

void _initAdmin() {
  // Datasources
  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => GetPendingDoctors(sl()));
  sl.registerLazySingleton(() => ApproveDoctor(sl()));

  // Blocs
  sl.registerFactory(
    () => AdminBloc(
      getPendingDoctors: sl(),
      approveDoctor: sl(),
    ),
  );
}
