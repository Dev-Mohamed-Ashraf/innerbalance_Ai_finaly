import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:innerbalance/core/usecases/usecase.dart';
import 'package:innerbalance/features/auth/domain/usecases/login_anonymous.dart';
import 'package:innerbalance/features/auth/domain/usecases/login_user.dart';
import 'package:innerbalance/features/auth/domain/usecases/register_user.dart';
import 'package:innerbalance/features/auth/presentation/bloc/auth_event.dart';
import 'package:innerbalance/features/auth/presentation/bloc/auth_state.dart';
import 'package:innerbalance/features/auth/domain/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser _loginUser;
  final RegisterUser _registerUser;
  final LoginAnonymous _loginAnonymous;
  final AuthRepository _authRepository; // Needed for check status/logout

  AuthBloc({
    required LoginUser loginUser,
    required RegisterUser registerUser,
    required LoginAnonymous loginAnonymous,
    required AuthRepository authRepository,
  })  : _loginUser = loginUser,
        _registerUser = registerUser,
        _loginAnonymous = loginAnonymous,
        _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthLogin>(_onLogin);
    on<AuthRegister>(_onRegister);
    on<AuthLoginAnonymous>(_onLoginAnonymous);
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthLogout>(_onLogout);
  }

  Future<void> _onLogin(AuthLogin event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _loginUser(LoginUserParams(
      email: event.email,
      password: event.password,
    ));
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onRegister(AuthRegister event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _registerUser(RegisterUserParams(
      name: event.name,
      email: event.email,
      password: event.password,
      role: event.role,
    ));
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLoginAnonymous(AuthLoginAnonymous event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _loginAnonymous(NoParams());
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }
  
  Future<void> _onCheckStatus(AuthCheckStatus event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _authRepository.getCurrentUser();
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user)),
    );
  }
  
  Future<void> _onLogout(AuthLogout event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }
}
