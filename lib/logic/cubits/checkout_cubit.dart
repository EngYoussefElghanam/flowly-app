import 'package:flowly/data/models/cart_item_model.dart';
import 'package:flowly/data/repositories/order_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final OrderRepository _repo;
  CheckoutCubit(this._repo) : super(CheckoutInitial());

  Future<void> submitOrder(
    String token,
    int customerId,
    List<CartItemModel> items,
  ) async {
    // 🛡️ GUARD: Ensure a customer is selected
    if (customerId <= 0) {
      emit(CheckoutError("Please select a customer first."));
      return;
    }

    // 🛡️ GUARD: Ensure cart is not empty
    if (items.isEmpty) {
      emit(CheckoutError("Cart is empty."));
      return;
    }

    emit(CheckoutLoading());
    try {
      await _repo.createOrder(token, customerId, items);
      emit(CheckoutSuccess());
    } catch (e) {
      emit(
        CheckoutError(e.toString()),
      ); // Removed "Error submitting order" to keep message clean
    }
  }
}
