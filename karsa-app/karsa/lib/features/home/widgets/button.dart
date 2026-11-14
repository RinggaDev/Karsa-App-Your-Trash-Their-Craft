import 'package:flutter/material.dart';

class _AnimatedMenuButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedMenuButton({
    required this.child,
    required this.onTap,
  });

  @override
  State<_AnimatedMenuButton> createState() => _AnimatedMenuButtonState();
}

class _AnimatedMenuButtonState extends State<_AnimatedMenuButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        Future.delayed(Duration(milliseconds: 100), widget.onTap);
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.85 : 1.0,
        duration: Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: _isPressed ? 0.6 : 1.0,
          duration: Duration(milliseconds: 150),
          child: widget.child,
        ),
      ),
    );
  }
}