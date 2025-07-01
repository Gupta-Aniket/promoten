// services/api_service.dart using Gemini SDK with streaming + image + token tracking

import 'dart:async';

import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:promoten/controllers/project_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final projectController = Get.find<ProjectController>();
  static Future<Stream<Map<String, String>>> generatePlatformContentStream({
    required String title,
    required String description,
    required List<String> questions,
    required List<String> answers,
    required List<String> platforms,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('geminiKey') ?? '';

    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);

    final qaPairs = <Map<String, String>>[];
    for (int i = 0; i < questions.length; i++) {
      if (answers[i].trim().isNotEmpty) {
        qaPairs.add({"question": questions[i], "answer": answers[i]});
      }
    }

    final prompt = '''
Here is a project with the following information:
- Title: $title
- Description: $description
- Q&A:
${qaPairs.map((e) => "Q: ${e['question']}\nA: ${e['answer']}").join("\n\n")}

Each post should be:
- Pure text (no markdown, no code blocks, no triple backticks)

Generate markdown-wrapped post content for the following platforms,
${platforms.join(", ")},
one per section:
Each response should look like:
<platformName>Your post content here</platformName>

No explanations, no code blocks, no markdown.
Only valid tags like <linkedin>...</linkedin>

The model may emit the tags one at a time in streaming chunks.

''';

    final parts = <Part>[TextPart(prompt)];
    final content = Content('user', parts);
    final stream = model.generateContentStream([content]);

    final portfolioLink = prefs.getString('portfolio');
    final linkedinLink = prefs.getString('linkedin');
    final controller = StreamController<Map<String, String>>();
    final regex = RegExp(r'<(\w+)>(.*?)</\1>', dotAll: true);

    final yielded = <String>{};
    String buffer = '';
    bool counted = false;

    stream.listen(
      (response) async {
        final text = response.text;
        if (text != null) {
          buffer += text;

          for (final match in regex.allMatches(buffer)) {
            final platform = match.group(1)!;
            final content = match.group(2)!.trim();

            if (!yielded.contains(platform)) {
              yielded.add(platform);

              // Inject your saved links
              final injected =
                  '$content\n Portfolio: $portfolioLink\n LinkedIn: $linkedinLink';

              controller.add({platform: injected});
            }
          }

          buffer = buffer.replaceAll(regex, '');
        }

        // ✅ Update token count (once, at end or first chunk with metadata)
        if (!counted && response.usageMetadata != null) {
          counted = true;
          final used = response.usageMetadata?.totalTokenCount ?? 0;
          final prefs = await SharedPreferences.getInstance();
          final oldCount = prefs.getInt('tokenCount') ?? 0;
          await prefs.setInt('tokenCount', oldCount + used);
          print("Token count: $used");
        }
      },
      onError: controller.addError,
      onDone: controller.close,
      cancelOnError: true,
    );

    return controller.stream;
  }
}
