import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/project_controller.dart';

class ProjectInputScreen extends StatelessWidget {
  final controller = Get.find<ProjectController>();

  ProjectInputScreen({Key? key}) : super(key: key);

  Future<void> _resetApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('geminiKey');
    Get.offAllNamed('/setup');
  }

  void _showResetDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Reset API Key'),
        content: const Text(
          'Are you sure you want to reset your API key? You will be redirected to the setup screen.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Get.back();
              _resetApiKey();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Promoten'),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          // API Key Reset Button
          IconButton(
            onPressed: _showResetDialog,
            icon: const Icon(Icons.key_off),
            tooltip: 'Reset API Key',
          ),
          const SizedBox(width: 8),
          // Token Count
          Obx(
            () => GestureDetector(
              onTap: () {
                Get.snackbar(
                  'Token Usage',
                  'Tokens used this month. Count resets on the 1st of next month.',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.black87,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(12),
                  borderRadius: 12,
                  duration: const Duration(seconds: 3),
                  icon: const Icon(Icons.info_outline, color: Colors.white),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "${controller.tokenCount.value}",
                  style: TextStyle(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.rocket_launch,
                    size: 32,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Share Your Project',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tell everyone about your amazing project',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Project Details Section
            _buildSection(context, 'Project Details', Icons.info_outline, [
              _buildTextField(
                controller: controller.titleController,
                label: 'Project Title',
                hint: 'Enter your project name',
                icon: Icons.title,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: controller.descriptionController,
                label: 'Description',
                hint: 'Describe what your project does',
                icon: Icons.description,
                maxLines: 4,
              ),
            ]),

            const SizedBox(height: 24),

            // Links Section
            _buildSection(context, 'Project Links', Icons.link, [
              _buildTextField(
                controller: controller.githubController,
                label: 'GitHub Repository',
                hint: 'https://github.com/username/repo',
                icon: Icons.code,
                optional: true,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: controller.liveLinkController,
                label: 'Live Demo',
                hint: 'https://your-project.com',
                icon: Icons.launch,
                optional: true,
              ),
            ]),

            const SizedBox(height: 24),

            // Social Links Section
            Obx(
              () => _buildExpandableSection(
                context,
                'Social Links',
                Icons.person,
                controller.savedLinkedIn.value.isEmpty ||
                    controller.savedPortfolio.value.isEmpty,
                [
                  _buildTextField(
                    controller: controller.linkedinController,
                    label: 'LinkedIn Profile',
                    hint: 'https://linkedin.com/in/username',
                    icon: Icons.business,
                    optional: true,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: controller.portfolioController,
                    label: 'Portfolio Website',
                    hint: 'https://your-portfolio.com',
                    icon: Icons.web,
                    optional: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Platforms Section
            _buildSection(context, 'Share Platforms', Icons.share, [
              const SizedBox(height: 8),
              Obx(
                () => Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                      controller.selectedPlatforms.keys.map((platform) {
                        final isSelected =
                            controller.selectedPlatforms[platform]!;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: FilterChip(
                            label: Text(platform),
                            selected: isSelected,
                            onSelected: (selected) async {
                              controller.selectedPlatforms[platform] = selected;
                              await controller.savePreferences();
                            },
                            backgroundColor: colorScheme.surface,
                            selectedColor: colorScheme.primaryContainer,
                            checkmarkColor: colorScheme.onPrimaryContainer,
                            labelStyle: TextStyle(
                              color:
                                  isSelected
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSurface,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                            ),
                            side: BorderSide(
                              color:
                                  isSelected
                                      ? colorScheme.primary
                                      : colorScheme.outline.withOpacity(0.5),
                              width: isSelected ? 2 : 1,
                            ),
                            elevation: isSelected ? 2 : 0,
                            pressElevation: 4,
                          ),
                        );
                      }).toList(),
                ),
              ),
            ]),

            const SizedBox(height: 40),

            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: () {
                  controller.savePreferences();
                  controller.generateQuestions();
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text(
                  'Continue to Questions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildExpandableSection(
    BuildContext context,
    String title,
    IconData icon,
    bool initiallyExpanded,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Icon(icon, size: 20, color: colorScheme.primary),
          title: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: children,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    bool optional = false,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Container(
          padding: EdgeInsets.only(top: 10),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              labelText: optional ? '$label (Optional)' : label,
              hintText: hint,
              prefixIcon: Icon(icon, size: 20),
              filled: true,
              fillColor: colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outline.withOpacity(0.5),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outline.withOpacity(0.5),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              labelStyle: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }
}
