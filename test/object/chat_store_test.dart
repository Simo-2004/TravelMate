import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travelmate/shared/state/chat_store.dart';

import '../helpers/test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Route chat persistence to an in-memory source instead of the SQLite
  // plugin, which is unavailable in the unit-test VM.
  setUp(resetChatStore);

  test('initialize is idempotent and safe to call', () async {
    await ChatStore.instance.initialize();
    await ChatStore.instance.initialize();
  });

  test('conversationFor returns a stable notifier per mate', () {
    final store = ChatStore.instance;
    final a = store.conversationFor('mate_conv');
    final b = store.conversationFor('mate_conv');
    expect(identical(a, b), isTrue);
  });

  test('sendMessage ignores blank text', () {
    final store = ChatStore.instance;
    final convo = store.conversationFor('mate_blank');
    final before = convo.value.length;
    store.sendMessage('mate_blank', '   ');
    expect(convo.value.length, before);
  });

  test('sendMessage appends my message and marks mate online', () {
    fakeAsync((async) {
      final store = ChatStore.instance;
      final convo = store.conversationFor('mate_send');
      final online = store.onlineStatusFor('mate_send');

      store.sendMessage('mate_send', 'hello there');
      async.flushMicrotasks();

      expect(convo.value.last.text, 'hello there');
      expect(convo.value.last.isFromMe, isTrue);
      expect(online.value, isTrue);

      // Auto-reply arrives after the reply delay.
      async.elapse(const Duration(seconds: 1));
      expect(convo.value.last.isFromMe, isFalse);
      expect(convo.value.last.text, isNotEmpty);

      // Mate goes offline after the idle timeout.
      async.elapse(const Duration(seconds: 6));
      expect(online.value, isFalse);
    });
  });

  test('sendTripInvite attaches trip and schedules a reply', () {
    fakeAsync((async) {
      final store = ChatStore.instance;
      final convo = store.conversationFor('mate_invite');

      store.sendTripInvite(
        'mate_invite',
        tripId: 'trip_1',
        message: 'Join me?',
        reply: 'Sure!',
      );
      async.flushMicrotasks();

      final sent = convo.value.last;
      expect(sent.attachedTripId, 'trip_1');
      expect(sent.isFromMe, isTrue);

      async.elapse(const Duration(seconds: 1));
      expect(convo.value.last.text, 'Sure!');
      expect(convo.value.last.isFromMe, isFalse);
    });
  });

  test('clearConversation empties the history', () {
    fakeAsync((async) {
      final store = ChatStore.instance;
      final convo = store.conversationFor('mate_clear');
      store.sendMessage('mate_clear', 'hi');
      async.flushMicrotasks();
      expect(convo.value, isNotEmpty);

      store.clearConversation('mate_clear');
      async.flushMicrotasks();
      expect(convo.value, isEmpty);

      // Drain the pending scheduled reply timer.
      async.elapse(const Duration(seconds: 2));
    });
  });

  test('notifyActivity toggles online then offline after idle', () {
    fakeAsync((async) {
      final store = ChatStore.instance;
      final online = store.onlineStatusFor('mate_activity');
      expect(online.value, isFalse);

      store.notifyActivity('mate_activity');
      expect(online.value, isTrue);

      async.elapse(const Duration(seconds: 6));
      expect(online.value, isFalse);
    });
  });
}
