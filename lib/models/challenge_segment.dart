class ChallengeSegment {
  final String id;
  final String text;
  final int points;
  final int? timerSeconds;

  const ChallengeSegment({
    required this.id,
    required this.text,
    required this.points,
    this.timerSeconds,
  });

  factory ChallengeSegment.fromJson(Map<String, dynamic> json) {
    return ChallengeSegment(
      id: json['id'] as String,
      text: json['text'] as String,
      points: json['points'] as int,
      timerSeconds: json['timerSeconds'] as int?,
    );
  }

  bool get hasTimer => timerSeconds != null && timerSeconds! > 0;
}
