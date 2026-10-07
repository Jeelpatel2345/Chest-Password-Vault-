import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:password_vault/models/password_item.dart';
import 'package:password_vault/services/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalStorageService Tests', () {
    late LocalStorageService storageService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storageService = LocalStorageService();
    });

    test('initial credentials list is empty', () async {
      final items = await storageService.getCredentials();
      expect(items, isEmpty);
      final deleted = await storageService.getDeletedCredentials();
      expect(deleted, isEmpty);
    });

    test('saveCredential adds item and persists it', () async {
      final item = PasswordItem(
        id: 'uuid-1',
        appName: 'GitHub',
        username: 'dev@github.com',
        password: 'Password123',
      );

      await storageService.saveCredential(item);

      final items = await storageService.getCredentials();
      expect(items.length, equals(1));
      expect(items.first.id, equals('uuid-1'));
      expect(items.first.appName, equals('GitHub'));
      expect(items.first.username, equals('dev@github.com'));
      expect(items.first.password, equals('Password123'));
    });

    test('moveToBin and restoreCredential works properly', () async {
      final item1 = PasswordItem(
        id: 'uuid-1',
        appName: 'GitHub',
        username: 'dev@github.com',
        password: 'Password123',
      );

      await storageService.saveCredential(item1);
      expect((await storageService.getCredentials()).length, equals(1));
      expect((await storageService.getDeletedCredentials()).length, equals(0));

      await storageService.moveToBin('uuid-1');

      expect((await storageService.getCredentials()).length, equals(0));
      var deleted = await storageService.getDeletedCredentials();
      expect(deleted.length, equals(1));
      expect(deleted.first.id, equals('uuid-1'));
      expect(deleted.first.isDeleted, isTrue);

      await storageService.restoreCredential('uuid-1');

      expect((await storageService.getCredentials()).length, equals(1));
      expect((await storageService.getDeletedCredentials()).length, equals(0));
    });

    test('moveToBinBatch and restoreBatch works properly', () async {
      final item1 = PasswordItem(
        id: 'uuid-1',
        appName: 'GitHub',
        username: 'dev@github.com',
        password: 'Pass1',
      );
      final item2 = PasswordItem(
        id: 'uuid-2',
        appName: 'GitLab',
        username: 'dev@gitlab.com',
        password: 'Pass2',
      );

      await storageService.saveCredential(item1);
      await storageService.saveCredential(item2);

      await storageService.moveToBinBatch(['uuid-1', 'uuid-2']);

      expect((await storageService.getCredentials()).length, equals(0));
      expect((await storageService.getDeletedCredentials()).length, equals(2));

      await storageService.restoreBatch(['uuid-1', 'uuid-2']);

      expect((await storageService.getCredentials()).length, equals(2));
      expect((await storageService.getDeletedCredentials()).length, equals(0));
    });

    test('deletePermanently and emptyBin removes items forever', () async {
      final item1 = PasswordItem(
        id: 'uuid-1',
        appName: 'Slack',
        username: 'user@work.com',
        password: 'Password789',
      );
      final item2 = PasswordItem(
        id: 'uuid-2',
        appName: 'Discord',
        username: 'gamer@chat.com',
        password: 'Password999',
      );

      await storageService.saveCredential(item1);
      await storageService.saveCredential(item2);

      await storageService.moveToBin('uuid-1');
      await storageService.deletePermanently('uuid-1');

      expect((await storageService.getDeletedCredentials()).length, equals(0));

      await storageService.moveToBin('uuid-2');
      await storageService.emptyBin();

      expect((await storageService.getDeletedCredentials()).length, equals(0));
      expect((await storageService.getCredentials()).length, equals(0));
    });

    test('clearAll wipes all stored data', () async {
      final item = PasswordItem(
        id: 'uuid-1',
        appName: 'Slack',
        username: 'user@work.com',
        password: 'Password789',
      );

      await storageService.saveCredential(item);
      expect((await storageService.getCredentials()).length, equals(1));

      await storageService.clearAll();
      expect((await storageService.getCredentials()).length, equals(0));
    });
  });
}
