class ChoiceExternal {
  final int id;
  final int questionId;
  final String choiceText;

  ChoiceExternal({
    required this.id,
    required this.questionId,
    required this.choiceText,
  });

  factory ChoiceExternal.fromJson(Map<String, dynamic> json) {
    return ChoiceExternal(
      id: json['id'] ?? 0,
      questionId: json['question_id'] ?? 0,
      choiceText: json['choice_text'] ?? '',
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
