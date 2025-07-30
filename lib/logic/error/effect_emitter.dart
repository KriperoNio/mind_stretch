import 'dart:async';

mixin EffectEmitter<Effect> {
  final _effectController = StreamController<Effect>.broadcast();

  Stream<Effect> get effects => _effectController.stream;
  void emitEffect(Effect effect) => _effectController.add(effect);

  void disposeEffects() => _effectController.close();
}
