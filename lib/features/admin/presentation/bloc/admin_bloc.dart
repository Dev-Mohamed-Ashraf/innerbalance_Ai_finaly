import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:innerbalancee/core/usecases/usecase.dart';
import 'package:innerbalancee/features/admin/domain/usecases/approve_doctor.dart';
import 'package:innerbalancee/features/admin/domain/usecases/get_pending_doctors.dart';
import 'package:innerbalancee/features/admin/presentation/bloc/admin_event.dart';
import 'package:innerbalancee/features/admin/presentation/bloc/admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final GetPendingDoctors _getPendingDoctors;
  final ApproveDoctor _approveDoctor;

  AdminBloc({
    required GetPendingDoctors getPendingDoctors,
    required ApproveDoctor approveDoctor,
  })  : _getPendingDoctors = getPendingDoctors,
        _approveDoctor = approveDoctor,
        super(AdminInitial()) {
    on<LoadPendingDoctors>(_onLoadPendingDoctors);
    on<ApproveDoctorEvent>(_onApproveDoctor);
  }

  Future<void> _onLoadPendingDoctors(
      LoadPendingDoctors event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    final result = await _getPendingDoctors(NoParams());
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (doctors) => emit(AdminLoaded(doctors)),
    );
  }

  Future<void> _onApproveDoctor(
      ApproveDoctorEvent event, Emitter<AdminState> emit) async {
    // Optimistic update or reload? Let's reload for safety.
    emit(AdminLoading());
    final result = await _approveDoctor(ApproveDoctorParams(event.userId));
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (_) => add(LoadPendingDoctors()), // Reload list
    );
  }
}
