import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:promoten/views/project_input_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ApiSetupScreen extends StatefulWidget {
  @override
  State<ApiSetupScreen> createState() => _ApiSetupScreenState();
}

class _ApiSetupScreenState extends State<ApiSetupScreen>
    with TickerProviderStateMixin {
  final TextEditingController apiController = TextEditingController();
  final RxInt tokenCount = 0.obs;
  final RxBool loading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isValid = false.obs;

  Future<void> _loadTokenCount() async {
    final prefs = await SharedPreferences.getInstance();
    tokenCount.value = prefs.getInt('tokenCount') ?? 0;
  }

  Future<bool> testApiKey(String key) async {
    try {
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: key);
      final response = await model.generateContent([
        Content('user', [TextPart("Say hello")]),
      ]);
      final text = response.text?.toLowerCase() ?? '';
      tokenCount.value = response.usageMetadata?.totalTokenCount ?? 0;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('tokenCount', tokenCount.value);

      return text.contains("hello") || text.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> saveApiKeyAndProceed() async {
    final key = apiController.text.trim();
    if (key.isEmpty) {
      errorMessage.value = "API key cannot be empty";
      return;
    }

    loading.value = true;
    errorMessage.value = '';
    isValid.value = false;

    final isValidKey = await testApiKey(key);

    if (isValidKey) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('geminiKey', key);
      isValid.value = true;
      await Future.delayed(const Duration(milliseconds: 500));
      loading.value = false;

      Get.off(() => ProjectInputScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 300));
    } else {
      loading.value = false;
      errorMessage.value = "Invalid API key. Please check and try again.";
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTokenCount();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Connect Gemini API'),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: colorScheme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        actions: [
          IconButton(
            onPressed: _showApiKeyHelp,
            icon: const Icon(Icons.help_outline),
            tooltip: 'Need Help?',
          )
        ],
      ),
      body: Obx(() => Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Instruction Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.vpn_key, size: 36, color: colorScheme.primary),
                      const SizedBox(height: 16),
                      Text(
                        'Enter your Gemini API key below to begin.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // API Key Input
                TextField(
                  controller: apiController,
                  decoration: InputDecoration(
                    hintText: 'Paste your Gemini API key here',
                    prefixIcon: const Icon(Icons.key),
                    suffixIcon: isValid.value
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withOpacity(0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                  ),
                  obscureText: true,
                ),

                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      errorMessage.value,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),

                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: loading.value ? null : saveApiKeyAndProceed,
                    icon: loading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline),
                    label: Text(
                      loading.value ? 'Validating...' : 'Validate & Continue',
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Token Count
                if (tokenCount.value > 0)
                  Row(
                    children: [
                      Icon(Icons.analytics_outlined,
                          color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        'Tokens used: ${tokenCount.value}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  )
              ],
            ),
          )),
    );
  }

  void _showApiKeyHelp() {
    Get.dialog(
      AlertDialog(
        title: const Text('Getting Your API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('To get your Gemini API key:'),
            SizedBox(height: 12),
            Text('1. Visit console.cloud.google.com'),
            Text('2. Enable the Gemini API'),
            Text('3. Create credentials (API key)'),
            Text('4. Copy and paste it here'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
