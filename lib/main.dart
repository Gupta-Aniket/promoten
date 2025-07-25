// Project Sharer - Flutter App with GetX & MVC Support

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:promoten/bindings/result_binding.dart';
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

  String? initialRoute;
  bool corruptProject = false;

  if (!hasApiKey) {
    initialRoute = '/setup';
  } else {
    final saved = prefs.getString('latestProject');
    if (saved != null) {
      try {
        final decoded = jsonDecode(saved);
        if (decoded is! Map ||
            !decoded.containsKey('title') ||
            !decoded.containsKey('platforms')) {
          throw Exception("Malformed project");
        }
        initialRoute = '/result';
      } catch (e) {
        corruptProject = true;
        await prefs.remove('latestProject');
        initialRoute = '/';
      }
    } else {
      initialRoute = '/';
    }
  }

  runApp(
    ProjectSharerApp(
      initialRoute: initialRoute!,
      showLoadError: corruptProject,
    ),
  );
}

class ProjectSharerApp extends StatelessWidget {
  final String initialRoute;
  final bool showLoadError;

  const ProjectSharerApp({
    super.key,
    required this.initialRoute,
    this.showLoadError = false,
  });

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
        GetPage(
          name: '/result',
          page: () => ResultScreen(),
          binding: ResultBinding(),
        ),
        GetPage(name: '/setup', page: () => ApiSetupScreen()),
      ],
      builder: (context, child) {
        // Show snackbar after routing is done
        Future.delayed(Duration.zero, () {
          if (showLoadError) {
            Get.snackbar(
              "Load Failed",
              "There was an error while loading the saved project.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
              margin: const EdgeInsets.all(16),
              icon: const Icon(Icons.error, color: Colors.white),
              duration: const Duration(seconds: 3),
            );
          }
        });
        return child!;
      },
    );
  }
}
