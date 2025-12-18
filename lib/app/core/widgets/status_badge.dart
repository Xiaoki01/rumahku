import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final String? label;

  const StatusBadge({
    super.key,
    required this.status,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'planning':
        color = Colors.blue;
        break;
      case 'ongoing':
        color = Colors.orange;
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'suspended':
        color = Colors.red;
        break;
      case 'pending':
      case 'menunggu':
        color = Colors.amber;
        break;
      case 'approved':
      case 'diverifikasi':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        label ?? status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
