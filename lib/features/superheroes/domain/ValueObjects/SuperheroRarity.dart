class SuperheroRarity {
  static String calculate(Map<String, dynamic> powerstats) {
    final int power = powerstats['power'] ?? powerstats['combat'] ?? 0;
    if (power >= 90) return 'Lendário';
    if (power >= 75) return 'Místico';
    if (power >= 50) return 'Bom';
    return 'Comum';
  }
}