import 'package:flutter/material.dart';

import '../../../core/units/unit_converter.dart';

const _unitConverter = UnitConverter();

/// One plan/fact numeric cell in the sets table (S-03). Every keystroke
/// calls [onChanged] (drives the controller's debounced autosave); losing
/// focus or pressing "Done" calls [onCommit] for an immediate write
/// (03_TECHNICAL_SPEC.md, section 5). The displayed text only resyncs from
/// [value] while the field is unfocused, so an in-flight edit is never
/// clobbered by a rebuild.
class SetNumberField extends StatefulWidget {
  const SetNumberField({
    super.key,
    required this.value,
    required this.decimals,
    required this.onChanged,
    required this.onCommit,
    this.semanticLabel,
  });

  final double? value;
  final int decimals;
  final String? semanticLabel;
  final ValueChanged<double?> onChanged;
  final VoidCallback onCommit;

  @override
  State<SetNumberField> createState() => _SetNumberFieldState();
}

class _SetNumberFieldState extends State<SetNumberField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.value));
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant SetNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && widget.value != oldWidget.value) {
      _controller.text = _format(widget.value);
    }
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) widget.onCommit();
  }

  String _format(double? value) {
    if (value == null) return '';
    return widget.decimals == 0
        ? value.round().toString()
        : value.toStringAsFixed(widget.decimals);
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
    return SizedBox(
      height: 48,
      child: Semantics(
        label: widget.semanticLabel,
        textField: true,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.numberWithOptions(
            decimal: widget.decimals > 0,
          ),
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 4),
          ),
          onChanged: (text) =>
              widget.onChanged(_unitConverter.parseDecimal(text)),
          onSubmitted: (_) => widget.onCommit(),
        ),
      ),
    );
  }
}
