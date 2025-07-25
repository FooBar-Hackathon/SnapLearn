import 'package:flutter/material.dart';

class LevelUpAnimation extends StatefulWidget {
  final int newLevel;
  final VoidCallback? onClose;
  const LevelUpAnimation({super.key, required this.newLevel, this.onClose});

  @override
  State<LevelUpAnimation> createState() => _LevelUpAnimationState();
}

class _LevelUpAnimationState extends State<LevelUpAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events, color: Colors.amber, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Level Up!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text('You reached Level', style: theme.textTheme.titleMedium),
                Text(
                  '${widget.newLevel}',
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.amber.withOpacity(0.5),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Awesome!'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (widget.onClose != null) widget.onClose!();
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(140, 48),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
