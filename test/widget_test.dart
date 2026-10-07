import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:password_vault/main.dart';
import 'package:password_vault/models/password_item.dart';
import 'package:password_vault/services/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Chest Full Widget & UI Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets(
      'Renders Chest title, logo, and empty state when vault is empty',
      (tester) async {
        final storageService = LocalStorageService();
        await tester.pumpWidget(
          PasswordVaultApp(storageService: storageService),
        );
        await tester.pumpAndSettle();

        expect(find.text('Chest'), findsOneWidget);
        expect(find.text('No credentials yet'), findsOneWidget);
        expect(find.text('Add Credential'), findsWidgets);
      },
    );

    testWidgets(
      'Opens dialog, validates required fields, and rejects empty form',
      (tester) async {
        final storageService = LocalStorageService();
        await tester.pumpWidget(
          PasswordVaultApp(storageService: storageService),
        );
        await tester.pumpAndSettle();

        final addIcon = find.byIcon(Icons.add_rounded);
        expect(addIcon, findsOneWidget);
        await tester.tap(addIcon);
        await tester.pumpAndSettle();

        expect(find.text('Save Credential'), findsOneWidget);

        await tester.tap(find.text('Save Credential'));
        await tester.pumpAndSettle();

        expect(
          find.text('Please enter the app or website name'),
          findsOneWidget,
        );
        expect(find.text('Please enter the username or email'), findsOneWidget);
        expect(find.text('Please enter a password'), findsOneWidget);
      },
    );

    testWidgets(
      'Adds a new credential, shows in list, and can reveal password',
      (tester) async {
        final storageService = LocalStorageService();
        await tester.pumpWidget(
          PasswordVaultApp(storageService: storageService),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add_rounded));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'e.g., GitHub, Google, Netflix'),
          'GitHub',
        );
        await tester.enterText(
          find.widgetWithText(
            TextFormField,
            'e.g., username or name@example.com',
          ),
          'jeel@example.com',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Enter password'),
          'MySecretPass123',
        );

        await tester.tap(find.text('Save Credential'));
        await tester.pumpAndSettle();

        expect(find.text('GitHub'), findsOneWidget);
        expect(find.text('jeel@example.com'), findsOneWidget);
        expect(find.text('MySecretPass123'), findsNothing);

        final revealBtn = find.byTooltip('Show password');
        expect(revealBtn, findsOneWidget);
        await tester.tap(revealBtn);
        await tester.pumpAndSettle();

        expect(find.text('MySecretPass123'), findsOneWidget);
      },
    );

    testWidgets('Long press opens action sheet with Edit and Move to Bin', (
      tester,
    ) async {
      final storageService = LocalStorageService();
      await storageService.saveCredential(
        PasswordItem(
          id: 'item-edit-1',
          appName: 'Twitter',
          username: 'user@x.com',
          password: 'Pass1',
        ),
      );

      await tester.pumpWidget(PasswordVaultApp(storageService: storageService));
      await tester.pumpAndSettle();

      expect(find.text('Twitter'), findsOneWidget);

      // Long press on Twitter card
      await tester.longPress(find.text('Twitter'));
      await tester.pumpAndSettle();

      // Verify modal sheet appears with Edit Credential and Move to Bin
      expect(find.text('Edit Credential'), findsOneWidget);
      expect(find.text('Move to Bin'), findsOneWidget);

      // Tap Edit Credential
      await tester.tap(find.text('Edit Credential'));
      await tester.pumpAndSettle();

      // Dialog is in edit mode prefilled with Twitter
      expect(find.text('Edit Credential'), findsOneWidget);
      expect(find.text('Update Credential'), findsOneWidget);

      // Change app name to X
      await tester.enterText(find.byType(TextFormField).first, 'X Platform');
      await tester.tap(find.text('Update Credential'));
      await tester.pumpAndSettle();

      // Card is updated
      expect(find.text('X Platform'), findsOneWidget);
      expect(find.text('Twitter'), findsNothing);
    });

    testWidgets(
      'Moves item to Bin, views in BinPage, and restores back to Chest',
      (tester) async {
        final storageService = LocalStorageService();
        await storageService.saveCredential(
          PasswordItem(
            id: 'item-bin-1',
            appName: 'Spotify',
            username: 'music@spotify.com',
            password: 'PassToBin',
          ),
        );

        await tester.pumpWidget(
          PasswordVaultApp(storageService: storageService),
        );
        await tester.pumpAndSettle();

        expect(find.text('Spotify'), findsOneWidget);

        // Open options
        await tester.tap(find.byTooltip('Options (Edit / Remove)'));
        await tester.pumpAndSettle();

        // Move to Bin
        await tester.tap(find.text('Move to Bin'));
        await tester.pumpAndSettle();

        // Spotify removed from active list
        expect(find.text('Spotify'), findsNothing);

        // Open Bin screen
        await tester.tap(find.byTooltip('Deleted Bin'));
        await tester.pumpAndSettle();

        // Verify Spotify is in the Bin
        expect(find.text('Bin'), findsOneWidget);
        expect(find.text('Spotify'), findsOneWidget);

        // Restore it
        await tester.tap(find.byTooltip('Restore to Chest'));
        await tester.pumpAndSettle();

        // Bin is now empty
        expect(find.text('Bin is empty'), findsOneWidget);

        // Navigate back to Chest
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        // Spotify is back in active list!
        expect(find.text('Spotify'), findsOneWidget);
      },
    );

    testWidgets('Multi-select items and move batch to Bin', (tester) async {
      final storageService = LocalStorageService();
      await storageService.saveCredential(
        PasswordItem(
          id: 'item-1',
          appName: 'Item One',
          username: 'user1',
          password: 'p1',
        ),
      );
      await storageService.saveCredential(
        PasswordItem(
          id: 'item-2',
          appName: 'Item Two',
          username: 'user2',
          password: 'p2',
        ),
      );

      await tester.pumpWidget(PasswordVaultApp(storageService: storageService));
      await tester.pumpAndSettle();

      expect(find.text('Item One'), findsOneWidget);
      expect(find.text('Item Two'), findsOneWidget);

      // Tap select items button in AppBar
      await tester.tap(find.byTooltip('Select items'));
      await tester.pumpAndSettle();

      expect(find.text('0 Selected'), findsOneWidget);

      // Select All
      await tester.tap(find.text('Select All'));
      await tester.pumpAndSettle();

      expect(find.text('2 Selected'), findsOneWidget);

      // Move selected to Bin
      await tester.tap(find.byTooltip('Move selected to Bin'));
      await tester.pumpAndSettle();

      // Confirm dialog
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Move to Bin'));
      await tester.pumpAndSettle();

      // Both items are moved to bin, empty state shows
      expect(find.text('No credentials yet'), findsOneWidget);
    });
  });
}
