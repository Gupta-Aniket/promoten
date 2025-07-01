// Project Sharer - Flutter App with GetX & MVC Support

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bindings/project_binding.dart';
import 'views/project_input_screen.dart';
import 'views/question_screen.dart';
import 'views/result_screen.dart';
import 'views/api_setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final hasApiKey = prefs.getString('geminiKey')?.isNotEmpty ?? false;
  runApp(ProjectSharerApp(initialRoute: hasApiKey ? '/' : '/setup'));
}

class ProjectSharerApp extends StatelessWidget {
  final String initialRoute;
  ProjectSharerApp({required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Project Sharer',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      initialBinding: ProjectBinding(),
      initialRoute: initialRoute,
      getPages: [
        GetPage(name: '/', page: () => ProjectInputScreen()),
        GetPage(name: '/questions', page: () => QuestionScreen()),
        GetPage(name: '/result', page: () => ResultScreen()),
        GetPage(name: '/setup', page: () => ApiSetupScreen()),
      ],
    );
  }
}
