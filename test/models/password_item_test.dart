import 'package:flutter_test/flutter_test.dart';
import 'package:password_vault/models/password_item.dart';

void main() {
  group('PasswordItem Model Tests', () {
    test('serializes and deserializes correctly including bin fields', () {
      final now = DateTime(2026, 1, 1, 12, 0);
      final item = PasswordItem(
        id: 'test-uuid-123',
        appName: 'GitHub',
        username: 'octocat@github.com',
        password: 'SuperSecret123!',
        createdAt: now,
        isDeleted: true,
        deletedAt: now,
      );

      final json = item.toJson();
      final deserialized = PasswordItem.fromJson(json);

      expect(deserialized.id, equals(item.id));
      expect(deserialized.appName, equals(item.appName));
      expect(deserialized.username, equals(item.username));
      expect(deserialized.password, equals(item.password));
      expect(deserialized.createdAt, equals(item.createdAt));
      expect(deserialized.isDeleted, isTrue);
      expect(deserialized.deletedAt, equals(now));
      expect(deserialized, equals(item));
    });

    test('toString() masks the password for security', () {
      final item = PasswordItem(
        id: 'test-uuid-123',
        appName: 'Google',
        username: 'user@gmail.com',
        password: 'VisiblePasswordShouldNotBeLogged',
      );

      final str = item.toString();
      expect(str, contains('[PROTECTED]'));
      expect(str.contains('VisiblePasswordShouldNotBeLogged'), isFalse);
    });

    test('copyWith works properly and can clear deletedAt', () {
      final original = PasswordItem(
        id: '1',
        appName: 'Amazon',
        username: 'buyer@amazon.com',
        password: 'Pass1',
        isDeleted: true,
        deletedAt: DateTime.now(),
      );

      final modified = original.copyWith(appName: 'AWS');
      expect(modified.appName, equals('AWS'));
      expect(modified.username, equals(original.username));
      expect(modified.isDeleted, isTrue);

      final restored = original.copyWith(
        isDeleted: false,
        clearDeletedAt: true,
      );
      expect(restored.isDeleted, isFalse);
      expect(restored.deletedAt, isNull);
    });
  });
}
