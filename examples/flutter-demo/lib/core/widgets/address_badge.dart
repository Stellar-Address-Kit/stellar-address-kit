import 'package:flutter/material.dart';

enum AddressKind { G, M, C, Unknown }

class AddressBadge extends StatelessWidget {
  final String kind;

  const AddressBadge({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (kind.toUpperCase()) {
      case 'G':
        color = Colors.blue;
        break;
      case 'M':
        color = Colors.purple;
        break;
      case 'C':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        kind.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
