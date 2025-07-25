import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promoten/services/platfrom_share_service.dart';

class PlatformCard extends StatelessWidget {
  final String platform;
  final String content;

  const PlatformCard({Key? key, required this.platform, required this.content})
    : super(key: key);

  Color get platformColor {
    switch (platform.toLowerCase()) {
      case 'linkedin':
        return const Color(0xFF0077B5);
      case 'x':
        return const Color(0xFF1DA1F2);
      case 'github':
        return const Color(0xFF333333);
      case 'reddit':
        return const Color(0xFFFF4500);
      case 'hackernews':
        return const Color(0xFFFF6600);
      case 'discord':
        return const Color(0xFF5865F2);
      case 'hashnode':
        return const Color(0xFF2962FF);
      default:
        return Colors.blueGrey;
    }
  }

  IconData get platformIcon {
    switch (platform.toLowerCase()) {
      case 'linkedin':
        return Icons.business;
      case 'x':
        return Icons.alternate_email;
      case 'github':
        return Icons.code;
      case 'reddit':
        return Icons.forum;
      case 'hackernews':
        return Icons.newspaper;
      case 'discord':
        return Icons.chat;
      case 'hashnode':
        return Icons.article;
      default:
        return Icons.share;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: platformColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: platformColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: platformColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: platformColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(platformIcon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        platform.toUpperCase(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: platformColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Ready to post',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: platformColor.withOpacity(0.3)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: content));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: colorScheme.onInverseSurface,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              const Text("Copied to clipboard!"),
                            ],
                          ),
                          backgroundColor: colorScheme.inverseSurface,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    },
                    tooltip: 'Copy content',
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.preview, size: 16, color: colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Preview',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.1),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          content,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Footer Actions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: content));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Content copied!"),
                          backgroundColor: platformColor,
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy All'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: platformColor,
                      side: BorderSide(color: platformColor.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      launchPlatformShare( platform: platform, content: content);
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(
                      //     content: Text("Share feature coming soon!"),
                      //   ),
                      // );
                    },
                    icon: const Icon(Icons.share, size: 16),
                    label: const Text('Share'),
                    style: FilledButton.styleFrom(
                      backgroundColor: platformColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
