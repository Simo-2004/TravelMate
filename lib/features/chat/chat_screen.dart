import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';
import 'package:travelmate/shared/models/chat_message.dart';
import 'package:travelmate/shared/models/mate_profile.dart';
import 'package:travelmate/shared/models/privacy_settings.dart';
import 'package:travelmate/shared/state/chat_store.dart';
import 'package:travelmate/shared/state/privacy_settings_store.dart';
import 'package:travelmate/shared/widgets/chat_input_bar.dart';
import 'package:travelmate/shared/widgets/chat_message_bubble.dart';
import 'package:travelmate/shared/widgets/chat_online_status.dart';

/// Conversation screen with [mate]. History is persisted by [ChatStore]
/// and survives app restarts until cleared; replies are simulated by
/// [ChatStore]'s keyword-matched auto-reply engine.
class ChatScreen extends StatefulWidget {
  final MateProfile mate;

  const ChatScreen({super.key, required this.mate});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ValueNotifier<List<ChatMessage>> _conversation;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _conversation = ChatStore.instance.conversationFor(widget.mate.id);
    _conversation.addListener(_handleMessagesChanged);
  }

  @override
  void dispose() {
    _conversation.removeListener(_handleMessagesChanged);
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _handleMessagesChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _handleSend(String text) {
    ChatStore.instance.sendMessage(widget.mate.id, text);
    _textController.clear();
  }

  void _handleTextChanged(String _) {
    ChatStore.instance.notifyActivity(widget.mate.id);
  }

  void _handleClearHistory() {
    ChatStore.instance.clearConversation(widget.mate.id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.chatHistoryClearedMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.mate.name,
              style: AppTextStyles.titleLg(
                sizes,
              ).copyWith(color: AppColors.yellow),
            ),
            // Offline mode hides other people's status too — a mate's
            // online status is only ever shown to you when you're
            // visible yourself.
            ValueListenableBuilder<PrivacySettings>(
              valueListenable: PrivacySettingsStore.instance,
              builder: (context, privacySettings, _) {
                if (privacySettings.offlineMode) {
                  return const ChatOnlineStatus(isOnline: false);
                }

                return ValueListenableBuilder<bool>(
                  valueListenable: ChatStore.instance.onlineStatusFor(
                    widget.mate.id,
                  ),
                  builder: (context, isMateOnline, __) {
                    return ChatOnlineStatus(isOnline: isMateOnline);
                  },
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: AppStrings.chatClearHistoryTooltip,
            icon: const Icon(Icons.delete_outline_rounded),
            color: AppColors.black,
            onPressed: _handleClearHistory,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ValueListenableBuilder<List<ChatMessage>>(
                valueListenable: _conversation,
                builder: (context, messages, _) {
                  if (messages.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(sizes.padL),
                        child: Text(
                          AppStrings.chatEmptyStateMessage,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMd(sizes),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(sizes.padL),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return ChatMessageBubble(message: messages[index]);
                    },
                  );
                },
              ),
            ),
            ChatInputBar(
              controller: _textController,
              onSend: _handleSend,
              onChanged: _handleTextChanged,
            ),
          ],
        ),
      ),
    );
  }
}
