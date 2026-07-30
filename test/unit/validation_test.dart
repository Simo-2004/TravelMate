/// Unit testing — form validation and tag-list editing.
///
/// [AccountValidation] and [TagInput] are deliberately free of Flutter and
/// plugin dependencies so the sign-up rules can be tested as plain functions.
/// The boundary cases below are driven off the published constants rather than
/// hard-coded numbers, so the tests follow if a limit is ever changed.
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:travelmate/shared/utils/account_validation.dart';
import 'package:travelmate/shared/utils/tag_input.dart';

void main() {
  group('AccountValidation.validateUsername', () {
    test('rejects blank input', () {
      expect(AccountValidation.validateUsername(''), isNotNull);
      expect(AccountValidation.validateUsername('  '), isNotNull);
    });

    test('accepts letters, digits, underscore and dot', () {
      expect(AccountValidation.validateUsername('good_user.1'), isNull);
    });

    test('rejects spaces and other punctuation', () {
      expect(AccountValidation.validateUsername('bad name'), isNotNull);
      expect(AccountValidation.validateUsername('bad-name'), isNotNull);
      expect(AccountValidation.validateUsername('bad@name'), isNotNull);
    });

    test('length boundaries: one short fails, exactly at the limit passes', () {
      const min = AccountValidation.usernameMinLength;
      const max = AccountValidation.usernameMaxLength;

      expect(AccountValidation.validateUsername('a' * (min - 1)), isNotNull);
      expect(AccountValidation.validateUsername('a' * min), isNull);
      expect(AccountValidation.validateUsername('a' * max), isNull);
      expect(AccountValidation.validateUsername('a' * (max + 1)), isNotNull);
    });

    test('length is measured after trimming', () {
      expect(AccountValidation.validateUsername('  abc  '), isNull);
    });
  });

  group('AccountValidation.validatePassword', () {
    test('rejects blank input', () {
      expect(AccountValidation.validatePassword(''), isNotNull);
    });

    test('length boundaries: one short fails, exactly at the limit passes', () {
      const min = AccountValidation.passwordMinLength;
      const max = AccountValidation.passwordMaxLength;

      expect(AccountValidation.validatePassword('a' * (min - 1)), isNotNull);
      expect(AccountValidation.validatePassword('a' * min), isNull);
      expect(AccountValidation.validatePassword('a' * max), isNull);
      expect(AccountValidation.validatePassword('a' * (max + 1)), isNotNull);
    });

    test('does not trim — leading/trailing spaces are part of the secret', () {
      // 8 characters, two of which are spaces: still a valid password.
      expect(AccountValidation.validatePassword(' abcdef '), isNull);
    });

    test('accepts symbols and unicode', () {
      expect(AccountValidation.validatePassword(r'p@$$w0rd!'), isNull);
      expect(AccountValidation.validatePassword('пароль12'), isNull);
    });
  });

  group('AccountValidation.validateRequiredName', () {
    test('rejects blank and names past the limit', () {
      expect(AccountValidation.validateRequiredName('', 'Name'), isNotNull);
      expect(AccountValidation.validateRequiredName('   ', 'Name'), isNotNull);
      expect(
        AccountValidation.validateRequiredName(
          'a' * (AccountValidation.nameMaxLength + 1),
          'Name',
        ),
        isNotNull,
      );
    });

    test('accepts a normal name and one exactly at the limit', () {
      expect(AccountValidation.validateRequiredName('Alessia', 'Name'), isNull);
      expect(
        AccountValidation.validateRequiredName(
          'a' * AccountValidation.nameMaxLength,
          'Name',
        ),
        isNull,
      );
    });

    test('names the offending field in the message', () {
      expect(
        AccountValidation.validateRequiredName('', 'Surname'),
        contains('Surname'),
      );
    });
  });

  group('AccountValidation.validateDescription', () {
    test('is optional but bounded', () {
      expect(AccountValidation.validateDescription(''), isNull);
      expect(AccountValidation.validateDescription('short'), isNull);
      expect(
        AccountValidation.validateDescription(
          'a' * AccountValidation.descriptionMaxLength,
        ),
        isNull,
      );
      expect(
        AccountValidation.validateDescription(
          'a' * (AccountValidation.descriptionMaxLength + 1),
        ),
        isNotNull,
      );
    });
  });

  group('TagInput', () {
    test('normalize collapses whitespace', () {
      expect(TagInput.normalizeLabel('  beach   life '), 'beach life');
    });

    test('clean drops blanks and case-insensitive duplicates', () {
      expect(TagInput.clean(['Beach', 'beach', '  ', 'Food']), [
        'Beach',
        'Food',
      ]);
    });

    test('clean keeps the first spelling of a duplicate', () {
      expect(TagInput.clean(['BEACH', 'beach']), ['BEACH']);
    });

    test('tryAdd appends, rejects duplicates and blanks', () {
      expect(TagInput.tryAdd(['Beach'], 'Food'), ['Beach', 'Food']);
      expect(TagInput.tryAdd(['Beach'], 'beach'), isNull);
      expect(TagInput.tryAdd(['Beach'], '   '), isNull);
    });

    test('tryAdd does not mutate the list it was given', () {
      final original = ['Beach'];
      TagInput.tryAdd(original, 'Food');
      expect(original, ['Beach']);
    });

    test('remove deletes case-insensitively and is a no-op when absent', () {
      expect(TagInput.remove(['Beach', 'Food'], 'beach'), ['Food']);
      expect(TagInput.remove(['Beach'], 'Nope'), ['Beach']);
    });
  });
}
