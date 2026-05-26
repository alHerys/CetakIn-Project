import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/atk_product_repository.dart';
import 'partner_atk_event.dart';
import 'partner_atk_state.dart';

class PartnerAtkBloc extends Bloc<PartnerAtkEvent, PartnerAtkState> {
  final AtkProductRepository _repository;

  PartnerAtkBloc(this._repository) : super(PartnerAtkInitial()) {
    on<PartnerAtkLoadRequested>(_onLoadRequested);
    on<PartnerAtkCreateRequested>(_onCreateRequested);
    on<PartnerAtkUpdateRequested>(_onUpdateRequested);
    on<PartnerAtkDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onLoadRequested(
    PartnerAtkLoadRequested event,
    Emitter<PartnerAtkState> emit,
  ) async {
    emit(PartnerAtkLoading());
    final result = await _repository.getProducts();
    result.fold(
      (error) => emit(PartnerAtkFailure(error)),
      (products) => emit(PartnerAtkLoaded(products)),
    );
  }

  Future<void> _onCreateRequested(
    PartnerAtkCreateRequested event,
    Emitter<PartnerAtkState> emit,
  ) async {
    emit(PartnerAtkActionLoading());
    final result = await _repository.createProduct(
      name: event.name,
      price: event.price,
      stock: event.stock,
      description: event.description,
      isAvailable: event.isAvailable,
      photo: event.photo,
    );
    
    result.fold(
      (error) => emit(PartnerAtkFailure(error)),
      (_) {
        emit(PartnerAtkActionSuccess('Produk ATK berhasil ditambahkan'));
        add(PartnerAtkLoadRequested());
      },
    );
  }

  Future<void> _onUpdateRequested(
    PartnerAtkUpdateRequested event,
    Emitter<PartnerAtkState> emit,
  ) async {
    emit(PartnerAtkActionLoading());
    final result = await _repository.updateProduct(
      event.id,
      name: event.name,
      price: event.price,
      stock: event.stock,
      description: event.description,
      isAvailable: event.isAvailable,
      photo: event.photo,
    );
    
    result.fold(
      (error) => emit(PartnerAtkFailure(error)),
      (_) {
        emit(PartnerAtkActionSuccess('Produk ATK berhasil diperbarui'));
        add(PartnerAtkLoadRequested());
      },
    );
  }

  Future<void> _onDeleteRequested(
    PartnerAtkDeleteRequested event,
    Emitter<PartnerAtkState> emit,
  ) async {
    emit(PartnerAtkActionLoading());
    final result = await _repository.deleteProduct(event.id);
    
    result.fold(
      (error) => emit(PartnerAtkFailure(error)),
      (_) {
        emit(PartnerAtkActionSuccess('Produk ATK berhasil dihapus'));
        add(PartnerAtkLoadRequested());
      },
    );
  }
}
