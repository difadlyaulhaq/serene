import 'package:flutter/material.dart';
import 'package:serene/shared/theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double horizontalPadding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width,
    this.horizontalPadding = 100,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: darkGray,
          foregroundColor: white,
          padding: EdgeInsets.symmetric(
            vertical: 16,
            horizontal: horizontalPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          elevation: 3,
          shadowColor: darkGray,
        ),
        child: Text(text),
      ),
    );
  }
}