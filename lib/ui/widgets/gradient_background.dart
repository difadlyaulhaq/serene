import 'package:flutter/material.dart';
import 'package:serene/shared/theme.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  
  const GradientBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.1, 0.3, 0.7, 1.0],
          colors: [
            blue,
            lavender,
            lightPink,
            peach,
            white,
          ],
        ),
      ),
      child: child,
    );
  }
}