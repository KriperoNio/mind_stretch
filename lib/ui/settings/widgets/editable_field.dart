import 'package:flutter/material.dart';
import 'package:mind_stretch/core/logger/app_logger.dart';

class EditableField extends StatefulWidget {
  final String label;
  final String initialValue;

  final bool isLoading;
  final bool showEditToggle;

  final ValueChanged<String>? onChanged;

  const EditableField({
    super.key,
    required this.label,
    this.initialValue = '',

    this.isLoading = false,
    this.showEditToggle = true,

    this.onChanged,
  });

  @override
  State<EditableField> createState() => _EditableFieldState();
}

class _EditableFieldState extends State<EditableField> {
  late final TextEditingController _controller;
  bool _isEditable = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant EditableField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      AppLogger.info('>>> didUpdateWidget', name: 'EditableField $hashCode');
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleEditToggle(bool value) {
    setState(() => _isEditable = value);
    if (!value && widget.onChanged != null) {
      AppLogger.info('>>> _handleEditToggle', name: 'EditableField $hashCode');
      widget.onChanged!(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (widget.showEditToggle && !widget.isLoading) ...[
              Checkbox(
                value: _isEditable,
                onChanged: (value) => _handleEditToggle(value ?? false),
              ),
              const Text('Редактировать'),
            ] else ...[
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.swap_horiz_rounded),
              ),
              Spacer(),
              IconButton(onPressed: () {}, icon: Icon(Icons.backup_rounded)),
            ],
          ],
        ),
        TextField(
          controller: _controller,
          enabled: _isEditable && !widget.isLoading,
          maxLines: 4,
          minLines: 4,
          decoration: InputDecoration(
            labelText: widget.label,
            border: const OutlineInputBorder(),
            filled: !_isEditable,
          ),
          onChanged: _isEditable ? widget.onChanged : null,
        ),
      ],
    );
  }
}
