import 'package:flutter/material.dart';

class ShakeTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double offset;

  const ShakeTransition({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.delay = Duration.zero,
    this.offset = 20.0,
  }) : super(key: key);

  @override
  _ShakeTransitionState createState() => _ShakeTransitionState();
}

class _ShakeTransitionState extends State<ShakeTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _offsetAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -widget.offset), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -widget.offset, end: widget.offset), weight: 2),
      TweenSequenceItem(tween: Tween(begin: widget.offset, end: -widget.offset / 2), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -widget.offset / 2, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_offsetAnimation.value, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
