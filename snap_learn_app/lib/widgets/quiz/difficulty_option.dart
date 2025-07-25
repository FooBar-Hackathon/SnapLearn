import 'package:flutter/material.dart';

class DifficultyOption extends StatelessWidget {
  final String difficulty;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const DifficultyOption({
    required this.difficulty,
    required this.selected,
    required this.color,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: selected ? color : Colors.grey[300],
          shape: BoxShape.circle,
        ),
      ),
      title: Text(
        difficulty,
        style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected ? color : Colors.black,
        ),
      ),
      onTap: onTap,
    );
  }
}
