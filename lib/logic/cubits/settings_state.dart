part of 'settings_cubit.dart';

sealed class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

final class SettingsInitial extends SettingsState {}

final class SettingsLoading extends SettingsState {}

final class SettingsLoaded extends SettingsState {
  final Map<String, int> settings;
  const SettingsLoaded(this.settings);
}

final class SettingsError extends SettingsState {
  final String message;
  const SettingsError(this.message);
}
