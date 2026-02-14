import 'package:flutter/material.dart';

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blueGrey.shade300),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
              color: Colors.blueGrey.shade300,
              fontWeight: FontWeight.bold,
              fontSize: 13),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              color: Color(0xFF263238)),
        ),
      ],
    );
  }
}
