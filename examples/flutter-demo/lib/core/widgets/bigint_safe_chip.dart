import 'package:flutter/material.dart';

class BigIntSafeChip extends StatelessWidget {
  const BigIntSafeChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      backgroundColor: Colors.green.withOpacity(0.1),
      side: BorderSide(color: Colors.green.withOpacity(0.3)),
      label: const Text(
        'BigInt-safe',
        style: TextStyle(
          color: Colors.green,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      avatar: const Icon(
        Icons.verified_user_outlined,
        size: 14,
        color: Colors.green,
      ),
    );
  }
}
