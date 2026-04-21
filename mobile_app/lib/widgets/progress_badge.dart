import 'package:flutter/material.dart';

class ProgressBadge extends StatelessWidget {
  final String label;

  const ProgressBadge({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xC7FFF8F1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x1F9D5F3F)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: const Color(0xFF74675B),
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}
