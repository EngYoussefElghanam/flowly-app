import 'package:flowly/data/repositories/product_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'add_product_state.dart';

class AddProductCubit extends Cubit<AddProductState> {
  final ProductRepository _repo;

  AddProductCubit(this._repo) : super(AddProductInitial());

  Future<void> createProduct({
    required String token,
    required String name,
    required double costPrice,
    required double sellPrice,
    required int stock,
  }) async {
    emit(AddProductLoading());
    try {
      await _repo.createProduct(
        token: token,
        name: name,
        costPrice: costPrice,
        sellPrice: sellPrice,
        stock: stock,
      );
      emit(AddProductSuccess());
    } catch (e) {
      emit(AddProductError(e.toString()));
    }
  }
}
