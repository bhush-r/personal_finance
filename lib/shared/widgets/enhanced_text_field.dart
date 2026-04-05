import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class EnhancedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? hint;
  final IconData? icon;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int maxLines;
  final int minLines;
  final bool obscureText;
  final Widget? suffix;
  final VoidCallback? onChanged;
  final bool showSuccessIndicator;
  final Color? accentColor;

  const EnhancedTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.hint,
    this.icon,
    this.prefixIcon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.minLines = 1,
    this.obscureText = false,
    this.suffix,
    this.onChanged,
    this.showSuccessIndicator = false,
    this.accentColor,
  });

  @override
  State<EnhancedTextField> createState() => _EnhancedTextFieldState();
}

class _EnhancedTextFieldState extends State<EnhancedTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  String? _error;
  bool _isValid = false;
  late AnimationController _errorAnimationController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _errorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && widget.validator != null) {
        setState(() {
          _error = widget.validator!(widget.controller.text);
          if (_error != null) {
            _errorAnimationController.forward();
          }
        });
      } else {
        _errorAnimationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _errorAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;
    final displayHint = widget.hintText ?? widget.hint;
    final displayIcon = widget.prefixIcon ?? widget.icon;
    final accentColor = widget.accentColor ?? Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
            if (_isValid && widget.showSuccessIndicator) ...[
              const SizedBox(width: 8),
              Icon(
                Iconsax.tick_circle,
                color: Colors.green.shade400,
                size: 16,
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isFocused ? Colors.white : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _error != null
                  ? Colors.red.shade400
                  : isFocused
                  ? accentColor
                  : Colors.grey.shade200,
              width: _error != null ? 2 : (isFocused ? 1.5 : 1),
            ),
            boxShadow: isFocused
                ? [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : [],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            onChanged: (val) {
              if (widget.validator != null) {
                setState(() {
                  _error = widget.validator!(val);
                  _isValid = _error == null && val.isNotEmpty;
                });
              }
              widget.onChanged?.call();
            },
            decoration: InputDecoration(
              hintText: displayHint,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
              ),
              prefixIcon: displayIcon != null
                  ? Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(
                  displayIcon,
                  color:
                  isFocused ? accentColor : Colors.grey.shade500,
                  size: 20,
                ),
              )
                  : null,
              prefixIconConstraints: const BoxConstraints(minWidth: 0),
              suffixIcon: widget.suffix,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: displayIcon != null ? 8 : 14,
                vertical: 14,
              ),
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 6),
          ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: _errorAnimationController,
                curve: Curves.elasticOut,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red.shade400,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Colors.red.shade400,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )
        ]
      ],
    );
  }
}