class MCQuestion {
  final int id;
  final int plantId;
  final String question;
  final String type; // multiple_choice / true_false
  final String? correctAnswer;
  final String? optionA;
  final String? optionB;
  final String? optionC;
  final String? optionD;

  final bool? isActive;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool isSelected; // UI only

  MCQuestion({
    required this.id,
    required this.plantId,
    required this.question,
    required this.type,
    this.correctAnswer,
    this.optionA,
    this.optionB,
    this.optionC,
    this.optionD,
    this.isActive,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.isSelected = false,
  });

  factory MCQuestion.fromJson(Map<String, dynamic> json) {
    final questionData = json['question'] ?? {};
    final choices = questionData['choices'] as List<dynamic>? ?? [];
    final corrects = questionData['correctanswers'] as List<dynamic>? ?? [];

    String? getChoice(int index) =>
        index < choices.length ? choices[index]['choice_text'] : null;

    String? getCorrectAnswer() {
      if (corrects.isEmpty) return null;
      final choiceId = corrects[0]['choice_id'];
      final correctChoice = choices.firstWhere(
        (c) => c['id'] == choiceId,
        orElse: () => null,
      );
      return correctChoice != null ? correctChoice['choice_text'] : null;
    }

    return MCQuestion(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      plantId: json['plant_id'] ?? 0,
      question: questionData['question_text'] ?? '',
      type: questionData['question_type'] ?? 'multiple_choice',
      optionA: getChoice(0),
      optionB: getChoice(1),
      optionC: getChoice(2),
      optionD: getChoice(3),
      correctAnswer: getCorrectAnswer(),
      isSelected: false,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      status: json['status']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  bool get isTrueFalse => type.toLowerCase() == "true_false";
  bool get isMultipleChoice => type.toLowerCase() == "multiple_choice";
}