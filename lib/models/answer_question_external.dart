class AnswerQuestionExternalResponse {
  final bool status;
  final String message;
  final AnswerQuestionExternalData? data;

  AnswerQuestionExternalResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory AnswerQuestionExternalResponse.fromJson(Map<String, dynamic> json) {
    return AnswerQuestionExternalResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? AnswerQuestionExternalData.fromJson(json['data'])
          : null,
    );
  }
}

class AnswerQuestionExternalData {
  final int id;
  final int inductionRequestId;
  final int questionId;
  final int selectedChoiceId;
  final String updatedAt;

  AnswerQuestionExternalData({
    required this.id,
    required this.inductionRequestId,
    required this.questionId,
    required this.selectedChoiceId,
    required this.updatedAt,
  });

  factory AnswerQuestionExternalData.fromJson(Map<String, dynamic> json) {
    return AnswerQuestionExternalData(
      id: json['id'] ?? 0,
      inductionRequestId: json['induction_request_id'] ?? 0,
      questionId: json['question_id'] ?? 0,
      selectedChoiceId: json['selected_choice_id'] ?? 0,
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
