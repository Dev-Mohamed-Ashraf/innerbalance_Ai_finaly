import 'package:equatable/equatable.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object> get props => [];
}

class LoadPendingDoctors extends AdminEvent {}

class ApproveDoctorEvent extends AdminEvent {
  final String userId;

  const ApproveDoctorEvent(this.userId);

  @override
  List<Object> get props => [userId];
}
