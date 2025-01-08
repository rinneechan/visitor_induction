import 'question.dart';
import 'plantvisit.dart';

class QuestionRequestIdPlant {
  final int id;
  final int questionId;
  final int plantId;
  final String updatedAt;
  final Question question;
  final Plantvisit plant;

  QuestionRequestIdPlant({
    required this.id,
    required this.questionId,
    required this.plantId,
    required this.updatedAt,
    required this.question,
    required this.plant,
  });

  factory QuestionRequestIdPlant.fromJson(Map<String, dynamic> json) {
    return QuestionRequestIdPlant(
      id: json['id'],
      questionId: json['question_id'],
      plantId: json['plant_id'],
      updatedAt: json['updated_at'],
      question: Question.fromJson(json['question']),
      plant: Plantvisit.fromJson(json['plant']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'plant_id': plantId,
      'updated_at': updatedAt,
      'question': question.toJson(),
      'plant': plant.toJson(),
    };
  }
}
