import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

Future<void> launchPlatformShare({
  required String platform,
  required String content,
}) async {
  Uri? uri;

  switch (platform.toLowerCase()) {
    case 'linkedin':
      uri = Uri.parse("linkedin://shareArticle?mini=true&summary=${Uri.encodeComponent(content)}");
      break;

    case 'x':
      uri = Uri.parse("twitter://post?message=${Uri.encodeComponent(content)}");
      break;

    case 'reddit':
      uri = Uri.parse("reddit://submit?title=${Uri.encodeComponent(content)}");
      break;

    case 'discord':
      // No official share intent, fallback
      uri = null;
      break;

    default:
      uri = null;
      break;
  }

  if (uri != null && await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    // Fallback to native share sheet
    await Share.share(content, subject: "Post for $platform");
  }
}
