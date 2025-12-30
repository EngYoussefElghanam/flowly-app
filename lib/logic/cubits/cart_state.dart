part of 'cart_cubit.dart';

class CartState {
  final List<CartItemModel> items;

  CartState({this.items = const []});

  // Helper getters for the UI (so we don't have to calculate this in the view)
  double get totalAmount => items.fold(0, (sum, item) => sum + item.totalPrice);
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
}
