import 'package:flowly/data/repositories/customer_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'customer_stats_state.dart';

class CustomerStatsCubit extends Cubit<CustomerStatsState> {
  final CustomerRepository _repo;
  CustomerStatsCubit(this._repo) : super(CustomerStatsInitial());
  Future<void> loadStats(int customerId, String token) async {
    emit(CustomerStatsLoading());
    try {
      final data = await _repo.getCustomerStats(customerId, token);
      emit(
        CustomerStatsLoaded(
          data['totalSpent'],
          data['favoriteItem'],
          data['totalOrders'],
        ),
      );
    } catch (e) {
      print("${e.toString()}");
      emit(CustomerStatsError(e.toString()));
    }
  }
}
