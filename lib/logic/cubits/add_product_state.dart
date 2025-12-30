part of 'add_product_cubit.dart';

sealed class AddProductState extends Equatable {
  const AddProductState();

  @override
  List<Object> get props => [];
}

class AddProductInitial extends AddProductState {}

class AddProductLoading extends AddProductState {}

class AddProductSuccess extends AddProductState {} // 🎉 Just a signal

class AddProductError extends AddProductState {
  final String message;
  const AddProductError(this.message);
}
