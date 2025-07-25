// bindings/result_binding.dart

import 'package:get/get.dart';
import '../controllers/project_controller.dart';
import '../controllers/question_controller.dart';

class ResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProjectController());
    Get.lazyPut(() => QuestionController());
  }
}
