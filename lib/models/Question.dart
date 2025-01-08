import 'choices.dart';

class Question {
  final int id;
  final String questionText;
  final String questionType;
  final List<Choice> choices;

  Question({
    required this.id,
    required this.questionText,
    required this.questionType,
    required this.choices,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      questionText: json['question_text'],
      questionType: json['question_type'],
      choices: (json['choices'] as List<dynamic>)
          .map((choice) => Choice.fromJson(choice))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_text': questionText,
      'question_type': questionType,
      'choices': choices.map((choice) => choice.toJson()).toList(),
    };
  }
}
