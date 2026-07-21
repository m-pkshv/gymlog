import 'package:flutter/material.dart';

/// A free-text comment field (S-03: workout/exercise comments) with the
/// same debounce-friendly resync behavior as `SetNumberField`: every
/// keystroke calls [onChanged] (drives the controller's debounced
/// autosave, 03_TECHNICAL_SPEC.md section 5); losing focus calls
/// [onCommit] for an immediate write. The displayed text only resyncs
/// from [value] while the field is unfocused, so an in-flight edit is
/// never clobbered by a rebuild.
class CommentField extends StatefulWidget {
  const CommentField({
    super.key,
    required this.value,
    required this.label,
    required this.maxLength,
    required this.onChanged,
    required this.onCommit,
    this.maxLines = 3,
    this.minLines = 1,
  });

  final String? value;
  final String label;
  final int maxLength;
  final ValueChanged<String> onChanged;
  final VoidCallback onCommit;

  /// Defaults preserve the multi-line comment box every existing caller
  /// uses; a single-line caller (e.g. the template name field, S-13) can
  /// pass `maxLines: 1, minLines: 1` -- same debounce-friendly mechanics
  /// either way.
  final int maxLines;
  final int minLines;

  @override
  State<CommentField> createState() => _CommentFieldState();
}

class _CommentFieldState extends State<CommentField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant CommentField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && widget.value != oldWidget.value) {
      _controller.text = widget.value ?? '';
    }
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) widget.onCommit();
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      decoration: InputDecoration(
        labelText: widget.label,
        alignLabelWithHint: true,
        isDense: true,
      ),
      textInputAction: TextInputAction.done,
      onChanged: widget.onChanged,
      onSubmitted: (_) => widget.onCommit(),
    );
  }
}
