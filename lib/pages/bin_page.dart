import 'package:flutter/material.dart';

import '../models/password_item.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

/// Screen displaying all deleted credentials stored in the Bin.
/// Allows restoring items back to the active vault or permanently deleting them.
class BinPage extends StatefulWidget {
  final StorageService storageService;

  const BinPage({super.key, required this.storageService});

  @override
  State<BinPage> createState() => _BinPageState();
}

class _BinPageState extends State<BinPage> {
  List<PasswordItem> _deletedItems = [];
  bool _isLoading = true;
  final Set<String> _revealedPasswords = {};

  @override
  void initState() {
    super.initState();
    _loadDeletedItems();
  }

  Future<void> _loadDeletedItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await widget.storageService.getDeletedCredentials();
      if (mounted) {
        setState(() {
          _deletedItems = items;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _restoreItem(PasswordItem item) async {
    try {
      await widget.storageService.restoreCredential(item.id);
      setState(() {
        _deletedItems.removeWhere((element) => element.id == item.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restored "${item.appName}" to active Chest'),
            backgroundColor: AppTheme.elevatedSurface,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to restore item. Please try again.'),
          ),
        );
      }
    }
  }

  Future<void> _confirmDeletePermanently(PasswordItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Permanently?'),
          content: Text(
            'Are you sure you want to permanently delete "${item.appName}"? This cannot be undone.',
            style: const TextStyle(
              color: AppTheme.secondaryText,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.danger,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete Forever'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      try {
        await widget.storageService.deletePermanently(item.id);
        setState(() {
          _deletedItems.removeWhere((element) => element.id == item.id);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Permanently deleted "${item.appName}"'),
              backgroundColor: AppTheme.elevatedSurface,
            ),
          );
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete item.')),
          );
        }
      }
    }
  }

  Future<void> _confirmEmptyBin() async {
    if (_deletedItems.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Empty Entire Bin?'),
          content: const Text(
            'All items in the Bin will be permanently removed. This action cannot be recovered.',
            style: TextStyle(
              color: AppTheme.secondaryText,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.danger,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Empty Bin'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      try {
        await widget.storageService.emptyBin();
        setState(() {
          _deletedItems.clear();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bin emptied successfully'),
              backgroundColor: AppTheme.elevatedSurface,
            ),
          );
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Failed to empty bin.')));
        }
      }
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border, width: 1),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppTheme.danger,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text('Bin'),
          ],
        ),
        actions: [
          if (_deletedItems.isNotEmpty)
            TextButton.icon(
              icon: const Icon(
                Icons.delete_sweep_rounded,
                size: 18,
                color: AppTheme.danger,
              ),
              label: const Text(
                'Empty Bin',
                style: TextStyle(
                  color: AppTheme.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: _confirmEmptyBin,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.accent,
                  strokeWidth: 2.5,
                ),
              )
            : _deletedItems.isEmpty
            ? Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 24,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.border,
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.auto_delete_outlined,
                          size: 36,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Bin is empty',
                        style: TextStyle(
                          color: AppTheme.primaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Credentials moved to the bin will appear here.\nYou can restore them or delete them permanently anytime.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.secondaryText,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                color: AppTheme.accent,
                backgroundColor: AppTheme.elevatedSurface,
                onRefresh: _loadDeletedItems,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  itemCount: _deletedItems.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _deletedItems[index];
                    final isRevealed = _revealedPasswords.contains(item.id);
                    final maskedPassword =
                        '•' * (item.password.length.clamp(8, 16));

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top row: App name & date
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.background,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppTheme.border,
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.inventory_2_outlined,
                                    size: 18,
                                    color: AppTheme.secondaryText,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.appName,
                                        style: const TextStyle(
                                          color: AppTheme.primaryText,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (item.deletedAt != null)
                                        Text(
                                          'Deleted on ${_formatDate(item.deletedAt)}',
                                          style: const TextStyle(
                                            color: AppTheme.secondaryText,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                // Restore button
                                IconButton(
                                  tooltip: 'Restore to Chest',
                                  icon: const Icon(
                                    Icons.restore_from_trash_rounded,
                                    color: AppTheme.accent,
                                    size: 22,
                                  ),
                                  onPressed: () => _restoreItem(item),
                                ),
                                // Permanent delete button
                                IconButton(
                                  tooltip: 'Delete permanently',
                                  icon: const Icon(
                                    Icons.delete_forever_rounded,
                                    color: AppTheme.danger,
                                    size: 22,
                                  ),
                                  onPressed: () =>
                                      _confirmDeletePermanently(item),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 12),
                            // Username
                            Row(
                              children: [
                                const Icon(
                                  Icons.person_outline_rounded,
                                  size: 16,
                                  color: AppTheme.secondaryText,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item.username,
                                    style: const TextStyle(
                                      color: AppTheme.secondaryText,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Password
                            Row(
                              children: [
                                const Icon(
                                  Icons.key_rounded,
                                  size: 16,
                                  color: AppTheme.secondaryText,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    isRevealed ? item.password : maskedPassword,
                                    style: TextStyle(
                                      color: isRevealed
                                          ? AppTheme.primaryText
                                          : AppTheme.secondaryText,
                                      fontSize: isRevealed ? 14 : 16,
                                      letterSpacing: isRevealed ? 0.2 : 2.0,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  tooltip: isRevealed
                                      ? 'Hide password'
                                      : 'Show password',
                                  icon: Icon(
                                    isRevealed
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 18,
                                    color: AppTheme.secondaryText,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    setState(() {
                                      if (isRevealed) {
                                        _revealedPasswords.remove(item.id);
                                      } else {
                                        _revealedPasswords.add(item.id);
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
