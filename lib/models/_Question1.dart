import 'choices.dart';

class Question {
  final int id;
  final String questionText;
  final String questionType;
  final String explanation;
  final List<Choice> choices;
  final List<int> correctAnswers; // Tambahkan ini

  Question({
    required this.id,
    required this.questionText,
    required this.questionType,
    required this.explanation,
    required this.choices,
    required this.correctAnswers, // Tambahkan ini
  });

  // factory constructor untuk parsing JSON
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      questionText: json['question_text'],
      questionType: json['question_type'],
      explanation: json['explanation'],
      choices: (json['choices'] as List<dynamic>?)
          ?.map((choice) => Choice.fromJson(choice))
          .toList() ??
          [],
      correctAnswers: (json['correctanswers'] as List<dynamic>?)
          ?.map((answer) => answer['choice_id'] as int)
          .toList() ??
          [],
      // choices: (json['choices'] as List<dynamic>)
      //     .map((choice) => Choice.fromJson(choice))
      //     .toList(),

      // correctAnswers: (json['correctanswers'] as List<dynamic>)
      //     .map((answer) => answer['choice_id'] as int)
      //     .toList(), // Ambil hanya choice_id dari correctanswers
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_text': questionText,
      'question_type': questionType,
      'explanation': explanation,
      'choices': choices.map((choice) => choice.toJson()).toList(),
      'correctanswers': correctAnswers,
    };
  }
}
