import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowly/data/models/cart_item_model.dart';
import 'package:flowly/data/models/product_model.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState());
  void addToCart(ProductModel product) {
    final List<CartItemModel> cartItems = List.from(state.items);
    final int index = cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );
    if (index != -1) {
      final oldItem = cartItems[index];
      if (oldItem.quantity < product.stock) {
        cartItems[index] = oldItem.copyWith(quantity: oldItem.quantity + 1);
      }
    } else {
      cartItems.add(CartItemModel(product: product, quantity: 1));
    }
    emit(CartState(items: cartItems));
  }

  void decreaseQuantity(int productId) {
    List<CartItemModel> newItems = List.from(state.items);
    final index = newItems.indexWhere((item) => item.product.id == productId);

    if (index == -1) return; // Should not happen

    if (newItems[index].quantity > 1) {
      // Decrease by 1
      newItems[index] = newItems[index].copyWith(
        quantity: newItems[index].quantity - 1,
      );
    } else {
      // If quantity is 1, remove it completely
      newItems.removeAt(index);
    }

    emit(CartState(items: newItems));
  }

  // 3. REMOVE ITEM (Trash can button)
  void removeFromCart(int productId) {
    List<CartItemModel> newItems = state.items
        .where((item) => item.product.id != productId)
        .toList();
    emit(CartState(items: newItems));
  }

  void clearCart() {
    emit(CartState(items: []));
  }
}
