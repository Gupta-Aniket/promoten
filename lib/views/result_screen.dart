// views/result_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:promoten/views/project_input_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/project_controller.dart';
import '../controllers/question_controller.dart';
import '../services/api_service.dart';
import 'widgets/platform_card.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  Future<void> saveLatestProject() async {
    final prefs = await SharedPreferences.getInstance();
    final project = {
      'title': projectController.titleController.text,
      'description': projectController.descriptionController.text,
      'platforms': platformContent,
    };
    // await prefs.setString('latestProject', project.toString());

    await prefs.setString('latestProject', jsonEncode(project));
  }

  DateTime? lastBackPressTime;
  final projectController = Get.find<ProjectController>();
  final questionController = Get.find<QuestionController>();
  final RxMap<String, String> platformContent = <String, String>{}.obs;
  final RxBool isGenerating = true.obs;
  final RxString currentGenerating = ''.obs;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _restoreOrGenerate();
  }

  void _restoreOrGenerate() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('latestProject');

    if (saved != null) {
      // Load from storage
      final Map<String, dynamic> project = Map<String, dynamic>.from(
        jsonDecode(saved),
      );

      // Restore into platformContent
      final restoredContent = Map<String, String>.from(project['platforms']);
      platformContent.assignAll(restoredContent);

      // Restore title/desc into controllers
      projectController.titleController.text = project['title'];
      projectController.descriptionController.text = project['description'];

      isGenerating.value = false;
      _pulseController.stop();
    } else {
      // If nothing saved, run normal generation
      _startStreaming();
    }
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startStreaming() async {
    final selectedPlatforms =
        projectController.selectedPlatforms.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();

    final stream = await ApiService.generatePlatformContentStream(
      title: projectController.titleController.text,
      description: projectController.descriptionController.text,
      questions: questionController.questions.map((q) => q.question).toList(),
      answers: questionController.questions.map((q) => q.answer).toList(),
      platforms: selectedPlatforms,
    );

    await for (final chunk in stream) {
      platformContent.addAll(chunk);
      if (chunk.isNotEmpty) {
        currentGenerating.value = chunk.keys.first;
      }
    }

    isGenerating.value = false;
    _pulseController.stop();
    await saveLatestProject();
  }

  void _regenerateContent() {
    platformContent.clear();
    isGenerating.value = true;
    currentGenerating.value = '';
    _pulseController.repeat(reverse: true);
    _startStreaming();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final now = DateTime.now();
        if (lastBackPressTime == null ||
            now.difference(lastBackPressTime!) > const Duration(seconds: 2)) {
          lastBackPressTime = now;
          Get.snackbar(
            "Hold on!",
            "Press back again to return to the input screen.",
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
            backgroundColor: colorScheme.inverseSurface,
            colorText: colorScheme.onInverseSurface,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
            icon: Icon(Icons.info_outline, color: colorScheme.onInverseSurface),
          );

          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('latestProject');
        Get.offAll(() => ProjectInputScreen());
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: const Text('Generated Content'),
          backgroundColor: colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          actions: [
            Obx(
              () =>
                  !isGenerating.value
                      ? IconButton(
                        onPressed: _regenerateContent,
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Regenerate Content',
                      )
                      : const SizedBox.shrink(),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.primaryContainer.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Obx(
                () => Column(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale:
                              isGenerating.value ? _pulseAnimation.value : 1.0,
                          child: Icon(
                            isGenerating.value
                                ? Icons.auto_awesome
                                : Icons.check_circle,
                            size: 40,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isGenerating.value
                          ? 'Generating Content...'
                          : 'Content Ready!',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isGenerating.value
                          ? currentGenerating.value.isNotEmpty
                              ? 'Working on ${currentGenerating.value}...'
                              : 'Preparing your platform-specific posts'
                          : 'Swipe through your personalized content below',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (isGenerating.value) ...[
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          backgroundColor: colorScheme.surface.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.onPrimaryContainer,
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Content Section
            Expanded(
              child: Obx(() {
                if (platformContent.isEmpty && isGenerating.value) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Crafting your content...',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (platformContent.isEmpty && !isGenerating.value) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No content generated',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try regenerating the content',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _regenerateContent,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Regenerate'),
                        ),
                      ],
                    ),
                  );
                }

                return PageView.builder(
                  itemCount: platformContent.length,
                  padEnds: false,
                  controller: PageController(viewportFraction: 0.85),
                  itemBuilder: (context, index) {
                    final entry = platformContent.entries.elementAt(index);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: PlatformCard(
                        platform: entry.key,
                        content: entry.value,
                      ),
                    );
                  },
                );
              }),
            ),

            // Bottom Info
            if (!isGenerating.value)
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.swipe,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Swipe to see all platforms',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// views/widgets/platform_card.dart
