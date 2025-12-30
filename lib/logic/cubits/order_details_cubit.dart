import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flowly/data/models/order_model.dart';
import 'package:flowly/data/repositories/order_repository.dart';

part 'order_details_state.dart';

class OrderDetailsCubit extends Cubit<OrderDetailsState> {
  final OrderRepository _repo;
  OrderDetailsCubit(this._repo) : super(OrderDetailsInitial());

  // 1. Initial Load (Full screen loading is okay here)
  Future<void> getDetails(String token, int orderId) async {
    emit(OrderDetailsLoading());
    try {
      final order = await _repo.getOrderDetails(token, orderId);
      emit(OrderDetailsSuccess(order));
    } catch (e) {
      emit(OrderDetailsError("Error fetching details: $e"));
    }
  }

  // 2. Status Update (Targeted loading)
  Future<void> updateStatus(String token, int orderId, String newStatus) async {
    // Safety check
    if (state is! OrderDetailsSuccess) return;

    final currentState = state as OrderDetailsSuccess;

    // A. Keep screen visible, but turn on the "spinner" flag
    emit(currentState.copyWith(isUpdatingStatus: true));

    try {
      // B. Call API
      await _repo.updateStatus(token, orderId, newStatus);

      // C. Get fresh data
      final updatedOrder = await _repo.getOrderDetails(token, orderId);

      // D. Success! Turn off spinner and show new data
      emit(OrderDetailsSuccess(updatedOrder, isUpdatingStatus: false));
    } catch (e) {
      // E. If error, keep the OLD data visible, turn off spinner.
      // (Ideally, you'd use a Listener in UI to show a SnackBar for the error)
      emit(currentState.copyWith(isUpdatingStatus: false));
    }
  }
}
