/// Unit testing — the chat decision functions.
///
/// [resolveAutoReply] picks a mate's canned answer from the text it was sent,
/// and [mateLikesTrip] decides whether a mate accepts a trip invite. Both are
/// pure functions, so every branch can be pinned down without a widget, a
/// store, or a database.
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/shared/utils/chat_auto_reply.dart';
import 'package:travelmate/shared/utils/trip_invite.dart';

import '../helpers/fixtures.dart';

void main() {
  group('resolveAutoReply', () {
    test('empty text returns fallback', () {
      expect(resolveAutoReply('  '), AppStrings.chatFallbackReply);
    });

    test('greeting keyword', () {
      expect(resolveAutoReply('Hello there'), AppStrings.chatReplyGreeting);
    });

    test('how are you takes priority over greeting', () {
      expect(
        resolveAutoReply('hi, how are you?'),
        AppStrings.chatReplyHowAreYou,
      );
    });

    test('travel keyword', () {
      expect(
        resolveAutoReply('I love to travel'),
        AppStrings.chatReplyTravelPlans,
      );
    });

    test('goodbye keyword', () {
      expect(resolveAutoReply('goodbye for now'), AppStrings.chatReplyGoodbye);
    });

    test('agreement keyword matches before goodbye', () {
      expect(resolveAutoReply('ok bye'), AppStrings.chatReplyAgreement);
    });

    test('whole-word matching avoids false positives', () {
      // "hi" must not match inside "this".
      expect(
        resolveAutoReply('think about this'),
        AppStrings.chatFallbackReply,
      );
    });

    test('unknown text returns fallback', () {
      expect(resolveAutoReply('xyzzy'), AppStrings.chatFallbackReply);
    });

    test('matching ignores case', () {
      expect(resolveAutoReply('HELLO'), AppStrings.chatReplyGreeting);
    });

    test('always answers with something non-empty', () {
      const inputs = ['', 'hello', 'xyzzy', '???', '12345'];
      for (final input in inputs) {
        expect(resolveAutoReply(input), isNotEmpty, reason: 'input: "$input"');
      }
    });
  });

  group('mateLikesTrip', () {
    final trip = buildTaggedTrip(
      id: 'trip_x',
      label: 'X',
      tagLabels: ['island-vibe', 'relax-mode'],
    );

    test('accepts when a tag matches a preferred trip', () {
      final mate = buildMate(id: 'm', preferredTrips: ['island-vibe']);
      expect(mateLikesTrip(mate, trip), isTrue);
    });

    test('accepts when a tag matches an interest', () {
      final mate = buildMate(id: 'm', interests: ['relax-mode']);
      expect(mateLikesTrip(mate, trip), isTrue);
    });

    test('declines when no tag matches', () {
      final mate = buildMate(id: 'm', interests: ['culture']);
      expect(mateLikesTrip(mate, trip), isFalse);
    });

    test('matching is case-insensitive', () {
      final mate = buildMate(id: 'm', preferredTrips: ['ISLAND-VIBE']);
      expect(mateLikesTrip(mate, trip), isTrue);
    });

    test('a mate with no interests at all declines', () {
      expect(mateLikesTrip(buildMate(id: 'm'), trip), isFalse);
    });

    test('an untagged trip is declined even by an enthusiastic mate', () {
      final untagged = buildTaggedTrip(id: 'trip_bare', label: 'Bare');
      final mate = buildMate(
        id: 'm',
        interests: ['island-vibe'],
        preferredTrips: ['relax-mode'],
      );
      expect(mateLikesTrip(mate, untagged), isFalse);
    });
  });
}
