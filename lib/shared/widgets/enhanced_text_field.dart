import 'package:flutter/material.dart';

class EnhancedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int maxLines;
  final int minLines;
  final bool obscureText;
  final Widget? suffix;
  final VoidCallback? onChanged;

  const EnhancedTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.minLines = 1,
    this.obscureText = false,
    this.suffix,
    this.onChanged,
  });

  @override
  State<EnhancedTextField> createState() => _EnhancedTextFieldState();
}

class _EnhancedTextFieldState extends State<EnhancedTextField> {
  late FocusNode _focusNode;
  String? _error;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && widget.validator != null) {
        setState(() {
          _error = widget.validator!(widget.controller.text);
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// LABEL
        Text(
          widget.label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),

        /// FIELD
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _error != null
                  ? Colors.red
                  : isFocused
                  ? Colors.black
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            onChanged: (val) {
              widget.onChanged?.call();
            },
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon:
              widget.icon != null ? Icon(widget.icon) : null,
              suffixIcon: widget.suffix,
              border: InputBorder.none,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),

        /// ERROR
        if (_error != null) ...[
          const SizedBox(height: 6),
          Text(
            _error!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          )
        ]
      ],
    );
  }
}