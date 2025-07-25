import 'package:flutter/material.dart';

class DifficultySelectionView extends StatelessWidget {
  final ValueChanged<String> onDifficultySelected;
  const DifficultySelectionView({
    required this.onDifficultySelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events, size: 72, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Pick Your Challenge!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a difficulty to start your quiz adventure.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Interactive difficulty cards
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              _DifficultyCard(
                label: 'Easy',
                color: Colors.green,
                icon: Icons.sentiment_satisfied_alt,
                multiplier: '1x XP',
                onTap: () => onDifficultySelected('Easy'),
              ),
              _DifficultyCard(
                label: 'Medium',
                color: Colors.blue,
                icon: Icons.sentiment_neutral,
                multiplier: '1.25x XP',
                onTap: () => onDifficultySelected('Medium'),
              ),
              _DifficultyCard(
                label: 'Hard',
                color: Colors.orange,
                icon: Icons.sentiment_dissatisfied,
                multiplier: '1.5x XP',
                onTap: () => onDifficultySelected('Hard'),
              ),
              _DifficultyCard(
                label: 'Expert',
                color: Colors.red,
                icon: Icons.whatshot,
                multiplier: '2x XP',
                onTap: () => onDifficultySelected('Expert'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final String multiplier;
  final VoidCallback onTap;
  const _DifficultyCard({
    required this.label,
    required this.color,
    required this.icon,
    required this.multiplier,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.13),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              multiplier,
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
