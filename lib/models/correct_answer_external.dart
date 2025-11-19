class CorrectAnswerExternal {
  final int id;
  final int questionId;
  final int choiceId;

  CorrectAnswerExternal({
    required this.id,
    required this.questionId,
    required this.choiceId,
  });

  factory CorrectAnswerExternal.fromJson(Map<String, dynamic> json) {
    return CorrectAnswerExternal(
      id: json['id'] ?? 0,
      questionId: json['question_id'] ?? 0,
      choiceId: json['choice_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'choice_id': choiceId,
    };
  }
}
