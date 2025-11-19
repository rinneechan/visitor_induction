class Choice {
  final int id;
  final int questionId;
  final String choiceText;

  Choice({
    required this.id,
    required this.questionId,
    required this.choiceText,
  });

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      id: json['id'],
      questionId: json['question_id'],
      choiceText: json['choice_text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'choice_text': choiceText,
    };
  }
}
