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
    //print("JSON data: $json");
    return QuestionRequestIdPlant(
      id: json['id'] ?? 0,
      questionId: json['question_id'] ?? 0,
      plantId: json['plant_id'] ?? 0,
      updatedAt: json['updated_at'] ?? '',
      question: json['question'] != null
          ? Question.fromJson(json['question'])
          : throw Exception('Missing question data'),
      plant: json['plant'] != null
          ? Plantvisit.fromJson(json['plant'])
          : throw Exception('Missing plant data'),
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
