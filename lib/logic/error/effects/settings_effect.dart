sealed class SettingsEffect {
  const SettingsEffect();
}

class ShowSnackbar extends SettingsEffect {
  final String message;
  const ShowSnackbar(this.message);
}

class PageBack<T> extends SettingsEffect {
  final T? result;
  const PageBack(this.result);
}
