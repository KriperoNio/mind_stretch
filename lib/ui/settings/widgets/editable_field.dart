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

  final TextEditingController controller;
  final ValueNotifier<bool> isEditableNotifier;

  const EditableField({
    super.key,
    required this.label,
    required this.onSave,
    required this.controller,
    required this.isEditableNotifier,
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
  final ValueNotifier<bool> _isDirtyNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    widget.controller.text = widget.initialValue;
    widget.controller.addListener(_updateDirtyState);
  }

  void _updateDirtyState() {
    final isDirty = widget.controller.text != widget.initialValue;
    if (_isDirtyNotifier.value != isDirty) {
      _isDirtyNotifier.value = isDirty;
    }
  }

  @override
  void didUpdateWidget(covariant EditableField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      AppLogger.info('>>> didUpdateWidget', name: 'EditableField $hashCode');
      widget.controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateDirtyState);
    _isDirtyNotifier.dispose();
    super.dispose();
  }

  void _handleEditToggle(bool value) {
    widget.isEditableNotifier.value = value;
    widget.onEditToggle?.call(value);

    if (!value &&
        widget.controller.text == widget.initialValue &&
        widget.onChanged != null) {
      widget.onChanged!(widget.controller.text);
    }
  }

  void _handleReset() {
    widget.controller.text = widget.initialValue;
    widget.onReset?.call();
    _handleEditToggle(false);
  }

  void _handleSave() {
    widget.onSave.call(widget.controller.text);
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
            return ValueListenableBuilder<bool>(
              valueListenable: widget.isEditableNotifier,
              builder: (context, isEditable, _) {
                return Row(
                  children: [
                    if (!isEditable || !isDirty) ...[
                      Checkbox(
                        value: isEditable,
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
            );
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: widget.isEditableNotifier,
          builder: (context, isEditable, _) {
            return TextField(
              controller: widget.controller,
              enabled: isEditable && !widget.isLoading,
              maxLines: 4,
              minLines: 4,
              decoration: InputDecoration(
                labelText: widget.label,
                border: const OutlineInputBorder(),
                filled: !isEditable,
              ),
              onChanged: isEditable ? widget.onChanged : null,
            );
          },
        ),
      ],
    );
  }
}
