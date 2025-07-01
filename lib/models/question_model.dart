class QuestionModel {
  final String question;
  String answer;

  QuestionModel({required this.question, this.answer = ''});

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(question: json['question']);
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
    };
  }
}
