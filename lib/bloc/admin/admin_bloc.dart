import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/admin_repository.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _adminRepository;

  AdminBloc(this._adminRepository) : super(AdminInitial()) {
    on<AdminGetPartnersRequested>(_onGetPartnersRequested);
    on<AdminApprovePartnerRequested>(_onApprovePartnerRequested);
    on<AdminRejectPartnerRequested>(_onRejectPartnerRequested);
  }

  Future<void> _onGetPartnersRequested(
    AdminGetPartnersRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final result = await _adminRepository.getPartners(status: event.status);
    result.fold(
      (failure) => emit(AdminFailure(failure)),
      (partners) => emit(AdminPartnersLoaded(partners)),
    );
  }

  Future<void> _onApprovePartnerRequested(
    AdminApprovePartnerRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final result = await _adminRepository.approvePartner(event.id);
    result.fold(
      (failure) => emit(AdminFailure(failure)),
      (_) {
        emit(AdminActionSuccess('Partner approved successfully'));
        add(AdminGetPartnersRequested()); // Refresh list
      },
    );
  }

  Future<void> _onRejectPartnerRequested(
    AdminRejectPartnerRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final result = await _adminRepository.rejectPartner(event.id, event.reason);
    result.fold(
      (failure) => emit(AdminFailure(failure)),
      (_) {
        emit(AdminActionSuccess('Partner rejected successfully'));
        add(AdminGetPartnersRequested()); // Refresh list
      },
    );
  }
}
