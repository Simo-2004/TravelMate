import 'package:travelmate/core/constants/app_strings.dart';

class ChatAutoReplyRule {
  final List<String> keywords;
  final String reply;

  const ChatAutoReplyRule({required this.keywords, required this.reply});
}

/// Keyword-matched canned replies used to simulate a mate responding to a
/// message. Rules are checked in order, so more specific phrases are listed
/// before generic single-word ones.
class ChatAutoReplyCatalog {
  static const List<ChatAutoReplyRule> rules = [
    ChatAutoReplyRule(
      keywords: ['how are you', 'how r u'],
      reply: AppStrings.chatReplyHowAreYou,
    ),
    ChatAutoReplyRule(
      keywords: ['hello', 'hi', 'hey', 'yo'],
      reply: AppStrings.chatReplyGreeting,
    ),
    ChatAutoReplyRule(
      keywords: ['trip', 'travel', 'destination', 'vacation', 'itinerary'],
      reply: AppStrings.chatReplyTravelPlans,
    ),
    ChatAutoReplyRule(
      keywords: ['thank', 'thanks'],
      reply: AppStrings.chatReplyThanks,
    ),
    ChatAutoReplyRule(keywords: ['name'], reply: AppStrings.chatReplyName),
    ChatAutoReplyRule(
      keywords: ['haha', 'lol', 'lmao', 'funny'],
      reply: AppStrings.chatReplyLaugh,
    ),
    ChatAutoReplyRule(keywords: ['where'], reply: AppStrings.chatReplyLocation),
    ChatAutoReplyRule(
      keywords: ['weather'],
      reply: AppStrings.chatReplyWeather,
    ),
    ChatAutoReplyRule(
      keywords: ['food', 'eat', 'restaurant'],
      reply: AppStrings.chatReplyFood,
    ),
    ChatAutoReplyRule(
      keywords: ['photo', 'picture', 'pic'],
      reply: AppStrings.chatReplyPhoto,
    ),
    ChatAutoReplyRule(
      keywords: ['yes', 'sure', 'agree', 'ok', 'okay'],
      reply: AppStrings.chatReplyAgreement,
    ),
    ChatAutoReplyRule(
      keywords: ['no', 'nah', 'not really'],
      reply: AppStrings.chatReplyDisagreement,
    ),
    ChatAutoReplyRule(
      keywords: ['bye', 'goodbye', 'see you', 'later'],
      reply: AppStrings.chatReplyGoodbye,
    ),
  ];
}
