import 'package:flutter/material.dart';

class CategoryTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool showArrow;

  const CategoryTab({
    super.key,
    required this.label,
    this.isActive = false,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.green : const Color(0xFF333333),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey,
              fontSize: 14,
            ),
          ),
          if (showArrow) const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 16),
        ],
      ),
    );
  }
}
