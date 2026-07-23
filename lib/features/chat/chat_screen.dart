import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';
import 'package:travelmate/features/schedule/travel_schedule_screen.dart';
import 'package:travelmate/shared/models/chat_message.dart';
import 'package:travelmate/shared/models/mate_profile.dart';
import 'package:travelmate/shared/models/privacy_settings.dart';
import 'package:travelmate/shared/models/saved_trip_preview.dart';
import 'package:travelmate/shared/models/trip_tile_data.dart';
import 'package:travelmate/shared/state/chat_store.dart';
import 'package:travelmate/shared/state/privacy_settings_store.dart';
import 'package:travelmate/shared/state/saved_trip_preview_store.dart';
import 'package:travelmate/shared/state/trip_store.dart';
import 'package:travelmate/shared/utils/trip_invite.dart';
import 'package:travelmate/shared/widgets/app_snackbar.dart';
import 'package:travelmate/shared/widgets/chat_input_bar.dart';
import 'package:travelmate/shared/widgets/chat_message_bubble.dart';
import 'package:travelmate/shared/widgets/chat_online_status.dart';
import 'package:travelmate/shared/widgets/chat_trip_attachment_picker.dart';

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
  bool _showTripPicker = false;

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

  void _handleAttachToggle() {
    setState(() => _showTripPicker = !_showTripPicker);
  }

  void _handleTripSelected(TripTileData trip) {
    final accepted = mateLikesTrip(widget.mate, trip);

    ChatStore.instance.sendTripInvite(
      widget.mate.id,
      tripId: trip.tripId,
      message: AppStrings.chatTripInviteMessage,
      reply: accepted
          ? AppStrings.chatReplyTripAccepted
          : AppStrings.chatReplyTripDeclined,
    );

    setState(() => _showTripPicker = false);
  }

  void _openTripDetails(TripTileData trip) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TravelScheduleScreen(
          tripId: trip.tripId,
          tripName: trip.destinationTitle,
          images: trip.scheduleImages,
          tags: trip.tags,
          destinationTitle: trip.destinationTitle,
          destinationDescription: trip.description,
        ),
      ),
    );
  }

  List<TripTileData> _resolveSavedTrips(List<SavedTripPreview> bookmarks) {
    return bookmarks
        .where((item) => item.bookmarkType == SavedBookmarkType.trip)
        .map((item) => TripStore.instance.findTripById(item.sourceId))
        .whereType<TripTileData>()
        .toList(growable: false);
  }

  void _handleClearHistory() {
    ChatStore.instance.clearConversation(widget.mate.id);

    AppSnackBar.show(
      ScaffoldMessenger.of(context),
      AppStrings.chatHistoryClearedMessage,
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
                  builder: (context, isMateOnline, _) {
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
                      return ChatMessageBubble(
                        message: messages[index],
                        onTripTap: _openTripDetails,
                      );
                    },
                  );
                },
              ),
            ),
            if (_showTripPicker)
              ValueListenableBuilder<List<SavedTripPreview>>(
                valueListenable: SavedTripPreviewStore.instance,
                builder: (context, bookmarks, _) {
                  return ChatTripAttachmentPicker(
                    trips: _resolveSavedTrips(bookmarks),
                    onTripSelected: _handleTripSelected,
                  );
                },
              ),
            ChatInputBar(
              controller: _textController,
              onSend: _handleSend,
              onChanged: _handleTextChanged,
              onAttachTap: _handleAttachToggle,
            ),
          ],
        ),
      ),
    );
  }
}
