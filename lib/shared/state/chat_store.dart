import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:travelmate/shared/data/chat_data_source.dart';
import 'package:travelmate/shared/data/sqlite_chat_data.dart';
import 'package:travelmate/shared/models/chat_message.dart';
import 'package:travelmate/shared/utils/chat_auto_reply.dart';

/// Chat conversations, keyed by mate id, persisted to disk so history
/// survives app restarts until a conversation is explicitly cleared.
class ChatStore {
  ChatStore._({ChatDataSource? dataSource})
    : _dataSource = dataSource ?? SqliteChatData.production();

  static final ChatStore instance = ChatStore._();

  static const Duration _replyDelay = Duration(milliseconds: 900);
  static const Duration _onlineIdleTimeout = Duration(seconds: 5);

  ChatDataSource _dataSource;
  final Map<String, ValueNotifier<List<ChatMessage>>> _conversations = {};
  final Map<String, ValueNotifier<bool>> _onlineStatus = {};
  final Map<String, Timer> _offlineTimers = {};
  bool _initialized = false;
  int _lastMessageId = 0;

  /// Test-only seam: swaps the backing data source (typically over an
  /// in-memory fake), so chat flows can be exercised without SQLite / secure
  /// storage plugins.
  ///
  /// Also drops everything held in memory — conversations, online flags, the
  /// pending idle timers and the message-id counter — because the store is now
  /// pointed at different storage and must not keep serving the old one's
  /// history.
  @visibleForTesting
  void debugSetDataSource(ChatDataSource dataSource) {
    _dataSource = dataSource;
    _initialized = false;
    _lastMessageId = 0;

    for (final timer in _offlineTimers.values) {
      timer.cancel();
    }
    _offlineTimers.clear();

    // The notifiers themselves are kept: callers may already be listening to
    // one, and they should see it emptied rather than be silently orphaned.
    for (final conversation in _conversations.values) {
      conversation.value = const [];
    }
    for (final status in _onlineStatus.values) {
      status.value = false;
    }
  }

  /// Loads persisted conversations and resumes the message-id counter from
  /// the highest id found, so ids keep increasing across app restarts; a
  /// no-op after the first call.
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;

    final persisted = await _dataSource.readAll();
    var highestId = 0;

    for (final entry in persisted.entries) {
      conversationFor(entry.key).value = List<ChatMessage>.unmodifiable(
        entry.value,
      );

      for (final message in entry.value) {
        final parsedId = int.tryParse(message.id);
        if (parsedId != null && parsedId > highestId) {
          highestId = parsedId;
        }
      }
    }

    _lastMessageId = highestId;
  }

  /// Returns the stable notifier for [mateId]'s conversation, creating an
  /// empty one on first access.
  ValueNotifier<List<ChatMessage>> conversationFor(String mateId) {
    return _conversations.putIfAbsent(
      mateId,
      () => ValueNotifier<List<ChatMessage>>(const []),
    );
  }

  /// Whether [mateId] currently appears online. Starts offline and turns on
  /// through [notifyActivity] — typing or sending — going back offline after
  /// [_onlineIdleTimeout] of no further activity.
  ValueNotifier<bool> onlineStatusFor(String mateId) {
    return _onlineStatus.putIfAbsent(mateId, () => ValueNotifier<bool>(false));
  }

  /// Marks [mateId] as online (simulating them noticing you typing or
  /// replying) and (re)starts the idle countdown that takes them offline.
  void notifyActivity(String mateId) {
    onlineStatusFor(mateId).value = true;

    _offlineTimers[mateId]?.cancel();
    _offlineTimers[mateId] = Timer(_onlineIdleTimeout, () {
      onlineStatusFor(mateId).value = false;
    });
  }

  /// Sends [text] as the current user (ignored if blank), then schedules an
  /// auto-reply from the mate.
  void sendMessage(String mateId, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }

    notifyActivity(mateId);

    _append(
      mateId,
      ChatMessage(
        id: _nextId(),
        text: trimmed,
        isFromMe: true,
        sentAt: DateTime.now(),
      ),
    );

    unawaited(_scheduleReply(mateId, resolveAutoReply(trimmed)));
  }

  /// Sends [message] carrying [tripId] as an attachment, then schedules
  /// [reply] as the mate's response. Whether the mate accepts or declines
  /// the invite is decided by the caller (see mateLikesTrip).
  void sendTripInvite(
    String mateId, {
    required String tripId,
    required String message,
    required String reply,
  }) {
    notifyActivity(mateId);

    _append(
      mateId,
      ChatMessage(
        id: _nextId(),
        text: message,
        isFromMe: true,
        sentAt: DateTime.now(),
        attachedTripId: tripId,
      ),
    );

    unawaited(_scheduleReply(mateId, reply));
  }

  /// Clears [mateId]'s conversation, in memory and in persistent storage.
  void clearConversation(String mateId) {
    conversationFor(mateId).value = const [];
    unawaited(_dataSource.clearConversation(mateId));
  }

  Future<void> _scheduleReply(String mateId, String replyText) async {
    await Future.delayed(_replyDelay);

    notifyActivity(mateId);

    _append(
      mateId,
      ChatMessage(
        id: _nextId(),
        text: replyText,
        isFromMe: false,
        sentAt: DateTime.now(),
      ),
    );
  }

  void _append(String mateId, ChatMessage message) {
    final notifier = conversationFor(mateId);
    notifier.value = List<ChatMessage>.unmodifiable([
      ...notifier.value,
      message,
    ]);
    unawaited(_dataSource.appendMessage(mateId, message));
  }

  String _nextId() {
    _lastMessageId += 1;
    return _lastMessageId.toString();
  }
}
