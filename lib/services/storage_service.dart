import '../models/password_item.dart';

/// Abstract storage contract for credentials and deleted bin management.
abstract class StorageService {
  /// Retrieves all active credentials (not in bin).
  Future<List<PasswordItem>> getCredentials();

  /// Retrieves all deleted credentials stored in the bin.
  Future<List<PasswordItem>> getDeletedCredentials();

  /// Saves a new credential or updates an existing one.
  Future<void> saveCredential(PasswordItem item);

  /// Moves a single credential to the bin.
  Future<void> moveToBin(String id);

  /// Moves multiple credentials to the bin in a single batch.
  Future<void> moveToBinBatch(List<String> ids);

  /// Restores a single credential from the bin back to active vault.
  Future<void> restoreCredential(String id);

  /// Restores multiple credentials from the bin back to active vault.
  Future<void> restoreBatch(List<String> ids);

  /// Permanently deletes a credential from the vault.
  Future<void> deletePermanently(String id);

  /// Deletes a credential (alias for moveToBin for backward compatibility).
  Future<void> deleteCredential(String id);

  /// Clears all credentials in the bin permanently.
  Future<void> emptyBin();

  /// Clears all credentials completely (active and deleted).
  Future<void> clearAll();
}
