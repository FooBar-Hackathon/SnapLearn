class utils {
  static int getTimerForDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 50;
      case 'medium':
        return 40;
      case 'hard':
        return 30;
      case 'expert':
        return 20;
      default:
        return 20;
    }
  }
}
