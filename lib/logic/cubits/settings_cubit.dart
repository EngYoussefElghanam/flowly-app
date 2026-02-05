import 'package:flowly/data/repositories/settings_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repo;

  SettingsCubit(this._repo) : super(SettingsInitial());

  // Initial Load (We still need a spinner here because we have NO data yet)
  Future<void> getSettings(String token) async {
    emit(SettingsLoading());
    try {
      final settings = await _repo.getSettings(token);
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError("Error Fetching Settings $e"));
    }
  }

  // ⚡ OPTIMISTIC UPDATE
  Future<void> updateSettings(
    String token,
    int inactiveThreshold,
    int vipOrderThreshold,
  ) async {
    // 1. Capture the OLD state (Snapshot for rollback) 📸
    final previousState = state;

    // 2. Emit the NEW state IMMEDIATELY (No waiting, No Spinner) 🚀
    // We manually construct the Map so the UI updates instantly
    emit(
      SettingsLoaded({
        'inactiveThreshold': inactiveThreshold,
        'vipOrderThreshold': vipOrderThreshold,
      }),
    );

    // 3. Talk to the Server in the background ☁️
    try {
      await _repo.updateSettings(token, inactiveThreshold, vipOrderThreshold);
      // Success? Great. The UI is already up to date. We do nothing.
    } catch (e) {
      // 4. Failure? ROLLBACK! ↩️
      // Show error
      emit(SettingsError("Update failed: $e"));

      // Restore the old slider positions
      if (previousState is SettingsLoaded) {
        emit(previousState);
      }
    }
  }
}
