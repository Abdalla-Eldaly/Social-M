import 'package:flutter/material.dart';

enum PageTransitionType {
  slideFromBottom,
  slideFromRight,
  slideFromTop,
  scaleWithFade,
  fade,
}

class AnimatedPageWrapper extends StatefulWidget {
  final Widget child;
  final PageTransitionType transitionType;
  final Duration duration;

  const AnimatedPageWrapper({
    super.key,
    required this.child,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedPageWrapper> createState() => _AnimatedPageWrapperState();
}

class _AnimatedPageWrapperState extends State<AnimatedPageWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        switch (widget.transitionType) {
          case PageTransitionType.slideFromBottom:
            return Transform.translate(
              offset: Offset(
                0.0,
                (1 - _animation.value) * MediaQuery.of(context).size.height,
              ),
              child: widget.child,
            );

          case PageTransitionType.slideFromRight:
            return Transform.translate(
              offset: Offset(
                (1 - _animation.value) * MediaQuery.of(context).size.width,
                0.0,
              ),
              child: widget.child,
            );

          case PageTransitionType.slideFromTop:
            return Transform.translate(
              offset: Offset(
                0.0,
                -(1 - _animation.value) * MediaQuery.of(context).size.height,
              ),
              child: widget.child,
            );

          case PageTransitionType.scaleWithFade:
            return Transform.scale(
              scale: 0.8 + (_animation.value * 0.2),
              child: Opacity(
                opacity: _animation.value,
                child: widget.child,
              ),
            );

          case PageTransitionType.fade:
            return Opacity(
              opacity: _animation.value,
              child: widget.child,
            );
        }
      },
    );
  }
}