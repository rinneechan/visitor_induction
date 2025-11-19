import 'choice_external.dart';
import 'correct_answer_external.dart';

class QuestionExternal {
  final int id;
  final String questionText;
  final String explanation;
  final List<ChoiceExternal> choices;
  final List<CorrectAnswerExternal> correctAnswers;

  QuestionExternal({
    required this.id,
    required this.questionText,
    required this.explanation,
    required this.choices,
    required this.correctAnswers,
  });

  factory QuestionExternal.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return QuestionExternal(
        id: 0,
        questionText: '',
        explanation: '',
        choices: [],
        correctAnswers: [],
      );
    }

    return QuestionExternal(
      id: json['id'] ?? 0,
      questionText: json['question_text'] ?? '',
      explanation: json['explanation'] ?? '',
      choices: (json['choices'] is List)
          ? (json['choices'] as List)
              .map((c) => ChoiceExternal.fromJson(c))
              .toList()
          : [],
      correctAnswers: (json['correctanswers'] is List)
          ? (json['correctanswers'] as List)
              .map((c) => CorrectAnswerExternal.fromJson(c))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_text': questionText,
      'explanation': explanation,
      'choices': choices.map((c) => c.toJson()).toList(),
      'correctanswers': correctAnswers.map((c) => c.toJson()).toList(),
    };
  }
}
