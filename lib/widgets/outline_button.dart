import 'package:flutter/material.dart';

class OutlineButtonCustom extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const OutlineButtonCustom({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}