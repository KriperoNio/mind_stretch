import 'package:flutter/material.dart';

class FormattedText extends StatelessWidget {
  final String text;

  const FormattedText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(text: _buildTextSpan(text));
  }

  TextSpan _buildTextSpan(String text) {
    final lines = text.split('\n');
    final spans = <TextSpan>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        spans.add(const TextSpan(text: '\n'));
        continue;
      }

      spans.add(_processLine(line));
      spans.add(const TextSpan(text: '\n'));
    }

    return TextSpan(children: spans);
  }

  TextSpan _processLine(String line) {
    final pattern = RegExp(r'(\*\*[^*]+\*\*|\*[^*]+\*|_.+_|`[^`]+`)');
    final matches = pattern.allMatches(line);
    if (matches.isEmpty) {
      return TextSpan(
        text: line,
        style: TextStyle(color: Colors.black),
      );
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
          TextSpan(
            text: content.replaceAll('*', ''),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      } else if (matchedText.startsWith('*')) {
        spans.add(
          TextSpan(
            text: content,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        );
      } else if (matchedText.startsWith('_')) {
        spans.add(
          TextSpan(
            text: content,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        );
      } else if (matchedText.startsWith('`')) {
        spans.add(
          TextSpan(
            text: content,
            style: TextStyle(
              fontFamily: 'monospace',
              backgroundColor: Colors.grey[400],
            ),
          ),
        );
      }

      lastEnd = match.end;
    }

    // Остаток строки
    if (lastEnd < line.length) {
      spans.add(TextSpan(text: line.substring(lastEnd)));
    }

    return TextSpan(
      children: spans,
      style: TextStyle(color: Colors.black),
    );
  }
}
