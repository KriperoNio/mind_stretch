import 'package:flutter/material.dart';

class EditableField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isEditable;
  final ValueChanged<bool> onEditToggle;
  final VoidCallback onReverse;
  final bool isLoading;

  const EditableField({
    super.key,
    required this.label,
    required this.isLoading,
    required this.controller,
    required this.isEditable,
    required this.onEditToggle,
    required this.onReverse,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ?isLoading
            ? null
            : Row(
                children: [
                  Checkbox(
                    value: isEditable,
                    onChanged: (value) => onEditToggle(value ?? false),
                  ),
                  Text('Редактировать'),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.swap_horiz),
                    tooltip: 'Реверс текста',
                    onPressed: isEditable ? onReverse : null,
                  ),
                ],
              ),
        TextField(
          controller: controller,
          enabled: isEditable,
          maxLines: 4,
          minLines: 4,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            filled: !isEditable,
          ),
        ),
      ],
    );
  }
}
