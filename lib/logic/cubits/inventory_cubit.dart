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

  Future<void> updateProduct(
    String token,
    int productId, {
    required String name,
    required int stock,
    required double sellPrice,
    required double costPrice,
  }) async {
    emit(InventoryLoading());
    try {
      await _productRepo.updateProduct(
        token,
        productId,
        name: name,
        stock: stock,
        sellPrice: sellPrice,
        costPrice: costPrice,
      );
      final products = await _productRepo.getProducts(token);
      emit(InventorySuccess(products));
    } catch (e) {
      emit(InventoryError("Error updating products $e"));
    }
  }

  Future<void> deleteProduct(String token, int productId) async {
    emit(InventoryLoading());
    try {
      await _productRepo.deleteProduct(token, productId);
      final products = await _productRepo.getProducts(token);
      emit(InventorySuccess(products));
    } catch (e) {
      emit(InventoryError("Error deleting products $e"));
    }
  }
}
