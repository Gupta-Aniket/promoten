
import 'package:get/get.dart';
import '../models/question_model.dart';
import 'project_controller.dart';

class QuestionController extends GetxController {
  final ProjectController projectController = Get.find();

  RxList<QuestionModel> questions = <QuestionModel>[].obs;
  RxInt currentIndex = 0.obs;

  void loadQuestionsFromProject() {
    questions.value = projectController.clarifyingQuestions
        .map((q) => QuestionModel(question: q))
        .toList();
  }

  void updateAnswer(String text) {
    questions[currentIndex.value].answer = text;
  }

  void goToNext() {
    if (currentIndex.value < questions.length - 1) {
      currentIndex.value++;
    } else {
      // TODO: Proceed to next step - send to LLM
      Get.toNamed('/result');
    }
  }

  void goToPrevious() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
    }
  }
}
