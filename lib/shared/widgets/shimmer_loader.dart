import 'package:flutter/material.dart';

class ShimmerLoader extends StatefulWidget {
  final double height;
  final double width;
  final BorderRadius borderRadius;

  const ShimmerLoader({
    super.key,
    this.height = 20,
    this.width = double.infinity,
    BorderRadius? borderRadius,
  }) : borderRadius = borderRadius ?? const BorderRadius.all(Radius.circular(8));

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: [
                _animationController.value - 0.3,
                _animationController.value,
                _animationController.value + 0.3,
              ],
            ),
          ),
        );
      },
    );
  }
}