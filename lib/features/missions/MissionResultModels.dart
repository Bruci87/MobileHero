enum MissionOutcome { success, failure, draw }

class RoundResult {
  final int roundIndex;
  final String attribute;
  final dynamic playerHero;
  final dynamic enemyHero;
  final MissionOutcome outcome;

  RoundResult({
    required this.roundIndex,
    required this.attribute,
    required this.playerHero,
    required this.enemyHero,
    required this.outcome,
  });
}

class MissionResult {
  final String crisisName;
  final List<RoundResult> roundResults;
  final int totalVictories;
  final bool isOverallSuccess;
  final String? buffedHeroName;
  final String? buffedAttribute;

  MissionResult({
    required this.crisisName,
    required this.roundResults,
    required this.totalVictories,
    required this.isOverallSuccess,
    this.buffedHeroName,
    this.buffedAttribute,
  });
}