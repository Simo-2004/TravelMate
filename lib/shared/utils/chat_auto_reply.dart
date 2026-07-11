import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/shared/data/chat_auto_reply_catalog.dart';

/// Resolves a canned reply for [incomingMessage] by matching it against
/// [ChatAutoReplyCatalog.rules], or the fallback message if nothing matches.
String resolveAutoReply(String incomingMessage) {
  final normalized = incomingMessage.trim().toLowerCase();
  if (normalized.isEmpty) {
    return AppStrings.chatFallbackReply;
  }

  for (final rule in ChatAutoReplyCatalog.rules) {
    if (rule.keywords.any((keyword) => _containsWord(normalized, keyword))) {
      return rule.reply;
    }
  }

  return AppStrings.chatFallbackReply;
}

bool _containsWord(String normalizedMessage, String keyword) {
  final pattern = RegExp(r'\b' + RegExp.escape(keyword) + r'\b');
  return pattern.hasMatch(normalizedMessage);
}
