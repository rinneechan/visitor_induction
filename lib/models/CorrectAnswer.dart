class CorrectAnswer {
  final int id;
  final int questionId;
  final int choiceId;

  CorrectAnswer({
    required this.id,
    required this.questionId,
    required this.choiceId,
  });

  factory CorrectAnswer.fromJson(Map<String, dynamic> json) {
    return CorrectAnswer(
      id: json['id'],
      questionId: json['question_id'],
      choiceId: json['choice_id'],
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
