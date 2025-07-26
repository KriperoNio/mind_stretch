import 'package:flutter/material.dart';
import 'package:mind_stretch/core/logger/app_logger.dart';

class EditableField extends StatefulWidget {
  final String label;
  final String initialValue;
  final bool isLoading;

  final VoidCallback? onReset;

  final ValueChanged<String> onSave;

  final ValueChanged<String>? onChanged;
  final ValueChanged<bool>? onEditToggle;

  const EditableField({
    super.key,
    required this.label,
    required this.onSave,
    this.initialValue = '',
    this.isLoading = false,
    this.onChanged,
    this.onReset,
    this.onEditToggle,
  });

  @override
  State<EditableField> createState() => _EditableFieldState();
}

class _EditableFieldState extends State<EditableField> {
  late final TextEditingController _controller;
  final ValueNotifier<bool> _isDirtyNotifier = ValueNotifier(false);
  bool _isEditable = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _controller.addListener(_updateDirtyState);
  }

  void _updateDirtyState() {
    final isDirty = _controller.text != widget.initialValue;
    if (_isDirtyNotifier.value != isDirty) {
      _isDirtyNotifier.value = isDirty;
    }
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
    _controller.removeListener(_updateDirtyState);
    _controller.dispose();
    _isDirtyNotifier.dispose();
    super.dispose();
  }

  void _handleEditToggle(bool value) {
    if (_isEditable != value) {
      setState(() => _isEditable = value);
      widget.onEditToggle?.call(value);
    }

    if (!value &&
        _controller.text == widget.initialValue &&
        widget.onChanged != null) {
      widget.onChanged!(_controller.text);
    }
  }

  void _handleReset() {
    _controller.text = widget.initialValue;
    widget.onReset?.call();
    _handleEditToggle(false);
  }

  void _handleSave() {
    widget.onSave.call(_controller.text);
    _handleEditToggle(false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: _isDirtyNotifier,
          builder: (context, isDirty, _) {
            return Row(
              children: [
                if (!_isEditable || !isDirty) ...[
                  Checkbox(
                    value: _isEditable,
                    onChanged: widget.isLoading
                        ? null
                        : (value) => _handleEditToggle(value ?? false),
                  ),
                  const Text('Редактировать'),
                ] else ...[
                  IconButton(
                    onPressed: widget.isLoading ? null : _handleReset,
                    icon: const Icon(Icons.swap_horiz_rounded),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: widget.isLoading ? null : _handleSave,
                    icon: const Icon(Icons.backup_rounded),
                  ),
                ],
              ],
            );
          },
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
