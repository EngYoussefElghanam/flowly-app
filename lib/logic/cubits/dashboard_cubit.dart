import 'package:flowly/data/models/dashboard_stats_model.dart';
import 'package:flowly/data/repositories/dashboard_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _dashboardRepository;
  DashboardCubit(this._dashboardRepository) : super(DashboardInitial());
  Future<void> getStats(String token) async {
    emit(DashboardLoading());
    try {
      final stats = await _dashboardRepository.getStats(token);
      emit(DashboardSuccess(stats));
    } catch (e) {
      emit(DashboardError("An unexpected Error happened $e"));
    }
  }
}
