import 'package:flutter/material.dart';

class ErrorIllustration extends StatelessWidget {
  final Object error;
  final double? height;
  final BoxFit fit;

  const ErrorIllustration({
    super.key,
    required this.error,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final String asset = _mapErrorToAsset(error);
    return Image.asset(
      asset,
      height: height,
      fit: fit,
    );
  }

  /// Определяем нужную картинку в зависимости от ошибки
  String _mapErrorToAsset(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('404')) {
      return 'assets/images/error_404.jpg';
    } else if (message.contains('network') ||
        message.contains('socket') ||
        message.contains('failed host')) {
      return 'assets/images/network_break.jpg';
    } else if (message.contains('timeout')) {
      return 'assets/images/out_of_order.jpg';
    } else if (message.contains('parse') || message.contains('format')) {
      return 'assets/images/awake.jpg';
    } else {
      return 'assets/images/error_collage.jpg';
    }
  }
}
