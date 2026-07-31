/// Integration testing — the chat persistence stack.
///
/// ChatRepository -> AesCipher -> ChatDao, with SqliteChatData on top handling
/// the migration of any history left behind in SharedPreferences, and ChatStore
/// above that. Message text is encrypted at rest, so these tests check both
/// that it round-trips and that what reaches the DAO is unreadable.
library;

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:travelmate/shared/data/chat_history_data.dart';
import 'package:travelmate/shared/data/chat_repository.dart';
import 'package:travelmate/shared/data/sqlite_chat_data.dart';
import 'package:travelmate/shared/models/chat_message.dart';
import 'package:travelmate/shared/state/chat_store.dart';

import '../helpers/test_harness.dart';

void main() {
  group('ChatRepository', () {
    ChatRepository build(FakeChatDao dao) => testChatRepository(dao);

    test('encrypts message text on write, decrypts on read', () async {
      final dao = FakeChatDao();
      final repository = build(dao);

      await repository.appendMessage(
        'mate_1',
        buildMessage('1', text: 'Secret plan'),
      );

      expect(dao.rows.single['text'], isNot('Secret plan'));

      final conversations = await repository.readAllConversations();
      expect(conversations['mate_1']!.single.text, 'Secret plan');
    });

    test('groups messages by mate id, preserving order', () async {
      final dao = FakeChatDao();
      final repository = build(dao);

      await repository.appendMessage('mate_1', buildMessage('1', text: 'a'));
      await repository.appendMessage('mate_2', buildMessage('2', text: 'b'));
      await repository.appendMessage('mate_1', buildMessage('3', text: 'c'));

      final conversations = await repository.readAllConversations();
      expect(conversations['mate_1']!.map((m) => m.text), ['a', 'c']);
      expect(conversations['mate_2']!.single.text, 'b');
    });

    test(
      'preserves attachedTripId and isFromMe through the round trip',
      () async {
        final dao = FakeChatDao();
        final repository = build(dao);
        final message = ChatMessage(
          id: '1',
          text: 'Join me?',
          isFromMe: false,
          sentAt: DateTime(2024, 5, 1),
          attachedTripId: 'trip_1',
        );

        await repository.appendMessage('mate_1', message);
        final restored =
            (await repository.readAllConversations())['mate_1']!.single;

        expect(restored.attachedTripId, 'trip_1');
        expect(restored.isFromMe, isFalse);
        expect(restored.sentAt, DateTime(2024, 5, 1));
      },
    );

    test('appendAll bulk-inserts every conversation', () async {
      final dao = FakeChatDao();
      final repository = build(dao);

      await repository.appendAll({
        'mate_1': [buildMessage('1'), buildMessage('2')],
        'mate_2': [buildMessage('3')],
      });

      expect(await repository.countMessages(), 3);
    });

    test('appendAll is a no-op for an empty map', () async {
      final dao = FakeChatDao();
      await build(dao).appendAll(const {});
      expect(dao.rows, isEmpty);
    });

    test('clearConversation removes only that mate\'s messages', () async {
      final dao = FakeChatDao();
      final repository = build(dao);
      await repository.appendMessage('mate_1', buildMessage('1'));
      await repository.appendMessage('mate_2', buildMessage('2'));

      await repository.clearConversation('mate_1');

      final conversations = await repository.readAllConversations();
      expect(conversations.containsKey('mate_1'), isFalse);
      expect(conversations['mate_2'], hasLength(1));
    });

    test(
      'readAllConversations returns empty map when nothing stored',
      () async {
        expect(await build(FakeChatDao()).readAllConversations(), isEmpty);
      },
    );
  });

  group('SqliteChatData', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    SqliteChatData build(FakeChatDao dao) {
      return SqliteChatData(repository: testChatRepository(dao));
    }

    test('returns empty when nothing is stored anywhere', () async {
      expect(await build(FakeChatDao()).readAll(), isEmpty);
    });

    test('migrates legacy SharedPreferences history into the db', () async {
      await const ChatHistoryData().writeAll({
        'mate_1': [buildMessage('1', text: 'Legacy hello')],
      });

      final dao = FakeChatDao();
      final data = build(dao);

      final migrated = await data.readAll();
      expect(migrated['mate_1']!.single.text, 'Legacy hello');
      expect(dao.rows, isNotEmpty); // written through to the encrypted db

      // A subsequent read comes from the db, not the legacy store again.
      expect((await data.readAll())['mate_1']!.single.text, 'Legacy hello');
    });

    test('does not re-migrate once the db already has messages', () async {
      final dao = FakeChatDao();
      final data = build(dao);
      await data.appendMessage('mate_1', buildMessage('1', text: 'Fresh'));

      await const ChatHistoryData().writeAll({
        'mate_1': [buildMessage('2', text: 'Should be ignored')],
      });

      final result = await data.readAll();
      expect(result['mate_1']!.single.text, 'Fresh');
    });

    test(
      'appendMessage and clearConversation delegate to the repository',
      () async {
        final dao = FakeChatDao();
        final data = build(dao);

        await data.appendMessage('mate_1', buildMessage('1', text: 'Hey'));
        expect((await data.readAll())['mate_1']!.single.text, 'Hey');

        await data.clearConversation('mate_1');
        expect(await data.readAll(), isEmpty);
      },
    );
  });

  group('ChatStore persistence', () {
    setUp(resetChatStore);

    test('sendMessage persists through the injected data source', () async {
      final dataSource = InMemoryChatData();
      ChatStore.instance.debugSetDataSource(dataSource);

      ChatStore.instance.sendMessage('mate_x', 'Persisted?');
      await Future<void>.delayed(Duration.zero);

      final persisted = await dataSource.readAll();
      expect(persisted['mate_x']!.single.text, 'Persisted?');
    });

    test('clearConversation removes persisted history', () async {
      final dataSource = InMemoryChatData();
      ChatStore.instance.debugSetDataSource(dataSource);

      ChatStore.instance.sendMessage('mate_y', 'Bye later');
      await Future<void>.delayed(Duration.zero);
      ChatStore.instance.clearConversation('mate_y');
      await Future<void>.delayed(Duration.zero);

      final persisted = await dataSource.readAll();
      expect(persisted['mate_y'] ?? const [], isEmpty);
    });

    test('initialize restores history and continues message ids', () {
      fakeAsync((async) {
        // Simulate history persisted by an earlier session, highest id = 5.
        ChatStore.instance.debugSetDataSource(
          InMemoryChatData({
            'mate_z': [buildMessage('5', text: 'From last time')],
          }),
        );

        ChatStore.instance.initialize();
        async.flushMicrotasks();

        final restored = ChatStore.instance.conversationFor('mate_z').value;
        expect(restored.single.text, 'From last time');

        // A new message must continue from id 5, not restart at 1.
        ChatStore.instance.sendMessage('mate_z', 'Back again');
        async.flushMicrotasks();
        expect(ChatStore.instance.conversationFor('mate_z').value.last.id, '6');

        // Drain the scheduled auto-reply timer.
        async.elapse(const Duration(seconds: 2));
      });
    });
  });
}
