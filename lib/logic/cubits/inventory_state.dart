part of 'inventory_cubit.dart';

sealed class InventoryState extends Equatable {
  const InventoryState();

  @override
  List<Object> get props => [];
}

final class InventoryInitial extends InventoryState {}

final class InventoryLoading extends InventoryState {}

final class InventorySuccess extends InventoryState {
  final List<ProductModel> products;
  InventorySuccess(this.products);
}

final class InventoryError extends InventoryState {
  final String message;
  InventoryError(this.message);
}
