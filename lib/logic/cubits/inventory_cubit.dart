import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flowly/data/models/product_model.dart';
import 'package:flowly/data/repositories/product_repository.dart';

part 'inventory_state.dart';

class InventoryCubit extends Cubit<InventoryState> {
  final ProductRepository _productRepo;
  InventoryCubit(this._productRepo) : super(InventoryInitial());
  Future<void> getProducts(String token) async {
    emit(InventoryLoading());
    try {
      final products = await _productRepo.getProducts(token);
      emit(InventorySuccess(products));
    } catch (e) {
      emit(InventoryError("Error fetching products $e"));
    }
  }
}
