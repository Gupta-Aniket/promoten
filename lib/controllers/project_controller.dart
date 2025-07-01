import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProjectController extends GetxController {
  @override
  void onInit() {
    loadPreferences();
    super.onInit();
  }

  // Text controllers for project input
  final titleController = TextEditingController();
  
  final descriptionController = TextEditingController();
  final githubController = TextEditingController();
  final liveLinkController = TextEditingController();
  final linkedinController = TextEditingController();
  final portfolioController = TextEditingController();
  RxList<String> base64Images = <String>[].obs;

  // Observables for selected images (4 max)
  RxInt  tokenCount= 0.obs;
  RxList<String> clarifyingQuestions = <String>[].obs;

  // Answers to the questions (indexed)
  RxMap<int, String> questionAnswers = <int, String>{}.obs;

  // Saved social handles (loaded from local storage later)
  RxString savedLinkedIn = ''.obs;
  RxString savedPortfolio = ''.obs;

  // Platform selection (LinkedIn, X, etc.)
  RxMap<String, bool> selectedPlatforms =
      {
        'linkedin': true,
        'x': true,
        'reddit': false,
        'hackernews': true,
        'discord': false,
        'hashnode': true,
      }.obs;

  /// Triggered when user submits initial form and hits "Generate Questions"
  void generateQuestions() async {
    final basePrompt = {
      "title": titleController.text,
      "description": descriptionController.text,
      "github": githubController.text.isEmpty ? null : githubController.text,
      "live_link":
          liveLinkController.text.isEmpty ? null : liveLinkController.text,
      "linkedin":
          linkedinController.text.isEmpty ? null : linkedinController.text,
      "portfolio":
          portfolioController.text.isEmpty ? null : portfolioController.text,
    };

    // TODO: Replace with actual LLM API call (for now: mock questions)
    clarifyingQuestions.value = [
      "What problem does this solve?",
      "Who is it for?",
      "What makes this unique?",
      "How long did it take to build?",
      "What tech stack did you use?",
    ];

    // Navigate to the question UI
    Get.toNamed('/questions');
  }

  void updateAnswer(int index, String answer) {
    questionAnswers[index] = answer;
  }

  void resetAll() {
    titleController.clear();
    descriptionController.clear();
    githubController.clear();
    liveLinkController.clear();
    linkedinController.clear();
    portfolioController.clear();
    clarifyingQuestions.clear();
    questionAnswers.clear();
    selectedPlatforms.updateAll((key, value) => false);
  }

  @override
  void onClose() {
    // Clean up controllers
    titleController.dispose();
    descriptionController.dispose();
    githubController.dispose();
    liveLinkController.dispose();
    linkedinController.dispose();
    portfolioController.dispose();
    super.onClose();
  }

  Future<void> savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('linkedin', linkedinController.text);
    await prefs.setString('portfolio', portfolioController.text);
    await prefs.setStringList(
      'selectedPlatforms',
      selectedPlatforms.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList(),
    );
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    savedLinkedIn.value = prefs.getString('linkedin') ?? '';
    savedPortfolio.value = prefs.getString('portfolio') ?? '';
    linkedinController.text = prefs.getString('linkedin') ?? '';
    portfolioController.text = prefs.getString('portfolio') ?? '';

    final savedPlatforms = prefs.getStringList('selectedPlatforms') ?? [];
    selectedPlatforms.updateAll((key, value) => savedPlatforms.contains(key));
    tokenCount.value = prefs.getInt('tokenCount') ?? 0;
  }
}
