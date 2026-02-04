import 'package:flowly/data/models/marketing_opportunity.dart';
import 'package:flowly/data/repositories/marketing_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'marketing_state.dart';

class MarketingCubit extends Cubit<MarketingState> {
  final MarketingRepository _repo;
  MarketingCubit(this._repo) : super(MarketingInitial());
  Future<void> loadOpportunities(String token) async {
    emit(MarketingLoading());
    try {
      final opportunities = await _repo.fetchOpportunities(token);
      if (opportunities.isEmpty) {
        emit(MarketingEmpty());
      } else {
        emit(MarketingLoaded(opportunities));
      }
    } catch (e) {
      emit(MarketingError("Error Fetching opportunities $e"));
    }
  }

  void forceEmpty() {
    emit(MarketingEmpty());
  }

  Future<void> handleAction(
    String token,
    String action,
    int opportunityId,
  ) async {
    if (state is MarketingLoaded) {
      final currentList = (state as MarketingLoaded).opportunities;
      //Optimistic update for smooth UI
      final updatedList = List<MarketingOpportunity>.from(currentList)
        ..removeWhere((opp) => opp.id == opportunityId);
      if (updatedList.isEmpty) {
        emit(MarketingEmpty());
      } else {
        emit(MarketingLoaded(updatedList));
      }
    }
    try {
      await _repo.sendAction(token, action, opportunityId);
    } catch (e) {
      //silent failure is better here in a tinder swiping effect
      print("Sync failed for ID $opportunityId: $e");
    }
  }
}
