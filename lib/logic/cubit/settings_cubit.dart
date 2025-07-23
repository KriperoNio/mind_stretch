import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_stretch/controller/content_controller.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final ContentController contentController;

  SettingsCubit({required this.contentController}) : super(SettingsInitial());

  Future<void> refreshContent() async {
    emit(SettingsLoading());
    try {
      await contentController.refreshContent();
      if (!isClosed) emit(SettingsSuccess());
    } catch (e) {
      emit(SettingsFailure(e.toString()));
    }
  }

  Future<void> resetContent() async {
    emit(SettingsLoading());
    try {
      await contentController.resetContent();
      if (!isClosed) emit(SettingsSuccess());
    } catch (e) {
      emit(SettingsFailure(e.toString()));
    }
  }

  Future<void> resetSettings() async {
    emit(SettingsLoading());
    try {
      await contentController.resetSettings();
      if (!isClosed) emit(SettingsSuccess());
    } catch (e) {
      emit(SettingsFailure(e.toString()));
    }
  }

  void clear() {
    emit(SettingsInitial());
  }
}

sealed class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsSuccess extends SettingsState {}

class SettingsFailure extends SettingsState {
  final String error;
  SettingsFailure(this.error);
}
