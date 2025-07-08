import 'package:flutter/material.dart';

class FormattedText extends StatelessWidget {
  final String text;

  const FormattedText(this.text, {super.key});

  static final _cache = <String, TextSpan>{};

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: Theme.of(
        context,
      ).textTheme.bodyMedium!.color!.withValues(alpha: 0.9),
    );

    final boldTextStyle = defaultTextStyle.copyWith(
      fontWeight: FontWeight.bold,
    );
    final italicTextStyle = defaultTextStyle.copyWith(
      fontStyle: FontStyle.italic,
    );

    final span = _cache[text] ??= _buildTextSpan(
      text,
      defaultTextStyle: defaultTextStyle,
      boldTextStyle: boldTextStyle,
      italicTextStyle: italicTextStyle,
    );

    return RepaintBoundary(
      child: RichText(
        text: span,
        textAlign: TextAlign.start,
      ),
    );
  }

  TextSpan _buildTextSpan(
    String text, {
    required TextStyle defaultTextStyle,
    required TextStyle boldTextStyle,
    required TextStyle italicTextStyle,
  }) {
    final lines = text.split('\n');
    final spans = <TextSpan>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        spans.add(const TextSpan(text: '\n'));
        continue;
      }

      spans.add(
        _processLine(
          line,
          defaultTextStyle: defaultTextStyle,
          italicTextStyle: italicTextStyle,
          boldTextStyle: boldTextStyle,
        ),
      );
      spans.add(const TextSpan(text: '\n'));
    }

    return TextSpan(children: spans, style: defaultTextStyle);
  }

  TextSpan _processLine(
    String line, {
    required TextStyle defaultTextStyle,
    required TextStyle boldTextStyle,
    required TextStyle italicTextStyle,
  }) {
    final pattern = RegExp(r'(\*\*[^*]+\*\*|\*[^*]+\*|_.+_)');
    final matches = pattern.allMatches(line);
    if (matches.isEmpty) {
      return TextSpan(text: line);
    }

    final spans = <TextSpan>[];
    int lastEnd = 0;

    for (final match in matches) {
      // Текст до совпадения
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: line.substring(lastEnd, match.start)));
      }

      // Обработка совпадения
      final matchedText = match.group(0)!;
      final content = matchedText.substring(1, matchedText.length - 1);

      if (matchedText.startsWith('**')) {
        spans.add(
          TextSpan(text: content.replaceAll('*', ''), style: boldTextStyle),
        );
      } else if (matchedText.startsWith('*') || matchedText.startsWith('_')) {
        spans.add(TextSpan(text: content, style: italicTextStyle));
      }
      lastEnd = match.end;
    }

    // Остаток строки
    if (lastEnd < line.length) {
      spans.add(TextSpan(text: line.substring(lastEnd)));
    }

    return TextSpan(children: spans);
  }
}
