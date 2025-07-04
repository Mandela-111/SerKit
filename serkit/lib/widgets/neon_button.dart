import 'package:flutter/material.dart';

class NeonButton extends StatefulWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final Color color;
  final double fontSize;

  const NeonButton({
    super.key,
    this.text,
    this.child,
    required this.onPressed,
    this.width = 200,
    this.height = 50,
    this.color = const Color(0xFF00FFFF),
    this.fontSize = 18,
  }) : assert(text != null || child != null, 'Either text or child must be provided');

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (_) {
            if (widget.onPressed != null) {
              setState(() {
                _isPressed = true;
              });
            }
          },
          onTapUp: (_) {
            if (widget.onPressed != null) {
              setState(() {
                _isPressed = false;
              });
              widget.onPressed!();
            }
          },
          onTapCancel: () {
            if (widget.onPressed != null) {
              setState(() {
                _isPressed = false;
              });
            }
          },
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.onPressed == null
                    ? widget.color.withOpacity(0.3)
                    : _isPressed
                        ? widget.color
                        : widget.color.withOpacity(0.7),
                width: _isPressed ? 2.0 : 1.5,
              ),
              boxShadow: widget.onPressed == null
                  ? []
                  : [
                      BoxShadow(
                        color: widget.color.withOpacity(
                            _isPressed ? 0.7 : 0.3 * _glowAnimation.value),
                        blurRadius: _isPressed ? 16 : 12 * _glowAnimation.value,
                        spreadRadius: _isPressed ? 2 : 1,
                      ),
                    ],
            ),
            child: Center(
              child: widget.child ?? Text(
                widget.text!,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.bold,
                  color: widget.onPressed == null
                      ? widget.color.withOpacity(0.3)
                      : widget.color,
                  letterSpacing: 1.5,
                  shadows: widget.onPressed == null
                      ? []
                      : [
                          Shadow(
                            color: widget.color.withOpacity(
                                _isPressed ? 0.8 : 0.4 * _glowAnimation.value),
                            blurRadius: _isPressed ? 12 : 8 * _glowAnimation.value,
                          ),
                        ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
