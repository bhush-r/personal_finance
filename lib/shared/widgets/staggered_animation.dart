import 'package:flutter/material.dart';

class StaggeredAnimation extends StatefulWidget {
  final List<Widget> children;
  final Duration duration;
  final Duration delayBetween;
  final Curve curve;

  const StaggeredAnimation({
    super.key,
    required this.children,
    this.duration = const Duration(milliseconds: 500),
    this.delayBetween = const Duration(milliseconds: 100),
    this.curve = Curves.easeOut,
  });

  @override
  State<StaggeredAnimation> createState() => _StaggeredAnimationState();
}

class _StaggeredAnimationState extends State<StaggeredAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.children.length,
          (index) => AnimationController(
        duration: widget.duration,
        vsync: this,
      ),
    );

    _fadeAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: widget.curve),
      );
    }).toList();

    _slideAnimations = _controllers.map((controller) {
      return Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
          .animate(
        CurvedAnimation(parent: controller, curve: widget.curve),
      );
    }).toList();

    Future.delayed(Duration.zero, () {
      for (int i = 0; i < _controllers.length; i++) {
        Future.delayed(
          widget.delayBetween * i,
              () {
            if (mounted) {
              _controllers[i].forward();
            }
          },
        );
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        widget.children.length,
            (index) => FadeTransition(
          opacity: _fadeAnimations[index],
          child: SlideTransition(
            position: _slideAnimations[index],
            child: widget.children[index],
          ),
        ),
      ),
    );
  }
}