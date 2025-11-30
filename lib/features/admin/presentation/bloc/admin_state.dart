import 'package:equatable/equatable.dart';
import 'package:innerbalance/features/auth/domain/entities/user.dart';

abstract class AdminState extends Equatable {
  const AdminState();
  
  @override
  List<Object> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminLoaded extends AdminState {
  final List<UserEntity> pendingDoctors;

  const AdminLoaded(this.pendingDoctors);

  @override
  List<Object> get props => [pendingDoctors];
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object> get props => [message];
}
