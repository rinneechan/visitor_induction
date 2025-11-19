import 'question_external.dart';

class QuestionRequestExternal {
  final int id;
  final int questionId;
  final int plantId;
  final String updatedAt;
  final QuestionExternal question;

  QuestionRequestExternal({
    required this.id,
    required this.questionId,
    required this.plantId,
    required this.updatedAt,
    required this.question,
  });

  factory QuestionRequestExternal.fromJson(Map<String, dynamic> json) {
    return QuestionRequestExternal(
      id: json['id'] ?? 0,
      questionId: json['question_id'] ?? 0,
      plantId: json['plant_id'] ?? 0,
      updatedAt: json['updated_at'] ?? '',
      question: QuestionExternal.fromJson(json['question']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'plant_id': plantId,
      'updated_at': updatedAt,
      'question': question.toJson(),
    };
  }
}
