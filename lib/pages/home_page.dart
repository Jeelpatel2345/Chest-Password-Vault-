import 'package:flutter/material.dart';

import '../models/password_item.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/add_credential_dialog.dart';
import '../widgets/credential_card.dart';
import '../widgets/empty_state.dart';
import 'bin_page.dart';

/// The primary screen of Chest (Password Vault).
class HomePage extends StatefulWidget {
  final StorageService storageService;

  const HomePage({super.key, required this.storageService});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<PasswordItem> _credentials = [];
  int _deletedCount = 0;
  bool _isLoading = true;

  // Multi-selection state
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await widget.storageService.getCredentials();
      final deleted = await widget.storageService.getDeletedCredentials();
      if (mounted) {
        setState(() {
          _credentials = items;
          _deletedCount = deleted.length;
          _isLoading = false;
          // Clear selections if selected items are no longer present
          _selectedIds.removeWhere((id) => !items.any((item) => item.id == id));
          if (_selectedIds.isEmpty && _isSelectionMode) {
            _isSelectionMode = false;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load stored credentials')),
        );
      }
    }
  }

  void _enterSelectionMode([String? initialId]) {
    setState(() {
      _isSelectionMode = true;
      if (initialId != null) {
        _selectedIds.add(initialId);
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedIds.length == _credentials.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(_credentials.map((e) => e.id));
      }
    });
  }

  Future<void> _openAddCredentialDialog() async {
    final newItem = await showDialog<PasswordItem>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) => const AddCredentialDialog(),
    );

    if (newItem != null && mounted) {
      try {
        await widget.storageService.saveCredential(newItem);
        setState(() {
          _credentials.insert(0, newItem);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved "${newItem.appName}" to Chest'),
              backgroundColor: AppTheme.elevatedSurface,
            ),
          );
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not save credential. Please try again.'),
            ),
          );
        }
      }
    }
  }

  Future<void> _openEditCredentialDialog(PasswordItem item) async {
    final updatedItem = await showDialog<PasswordItem>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) =>
          AddCredentialDialog(initialItem: item),
    );

    if (updatedItem != null && mounted) {
      try {
        await widget.storageService.saveCredential(updatedItem);
        setState(() {
          final index = _credentials.indexWhere((e) => e.id == updatedItem.id);
          if (index >= 0) {
            _credentials[index] = updatedItem;
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Updated "${updatedItem.appName}" in Chest'),
              backgroundColor: AppTheme.elevatedSurface,
            ),
          );
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not update credential. Please try again.'),
            ),
          );
        }
      }
    }
  }

  Future<void> _moveToBin(PasswordItem item) async {
    try {
      await widget.storageService.moveToBin(item.id);
      setState(() {
        _credentials.removeWhere((element) => element.id == item.id);
        _selectedIds.remove(item.id);
        _deletedCount++;
        if (_credentials.isEmpty && _isSelectionMode) {
          _isSelectionMode = false;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Moved "${item.appName}" to Bin'),
            backgroundColor: AppTheme.elevatedSurface,
            action: SnackBarAction(
              label: 'Undo',
              textColor: AppTheme.accentLight,
              onPressed: () async {
                await widget.storageService.restoreCredential(item.id);
                _loadCredentials();
              },
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not move to bin. Please try again.'),
          ),
        );
      }
    }
  }

  Future<void> _moveSelectedToBin() async {
    if (_selectedIds.isEmpty) return;

    final count = _selectedIds.length;
    final idsToBin = List<String>.from(_selectedIds);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Move to Bin'),
          content: Text(
            'Move $count selected ${count == 1 ? "credential" : "credentials"} to the Bin?',
            style: const TextStyle(color: AppTheme.secondaryText, fontSize: 14),
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
              child: const Text('Move to Bin'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      try {
        await widget.storageService.moveToBinBatch(idsToBin);
        setState(() {
          _credentials.removeWhere((item) => idsToBin.contains(item.id));
          _deletedCount += count;
          _exitSelectionMode();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Moved $count items to Bin'),
              backgroundColor: AppTheme.elevatedSurface,
              action: SnackBarAction(
                label: 'Undo',
                textColor: AppTheme.accentLight,
                onPressed: () async {
                  await widget.storageService.restoreBatch(idsToBin);
                  _loadCredentials();
                },
              ),
            ),
          );
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not move selected items to bin.'),
            ),
          );
        }
      }
    }
  }

  Future<void> _openBinPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BinPage(storageService: widget.storageService),
      ),
    );
    // Refresh count and active credentials after returning from Bin
    _loadCredentials();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isSelectionMode ? _buildSelectionAppBar() : _buildNormalAppBar(),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.accent,
                  strokeWidth: 2.5,
                ),
              )
            : _credentials.isEmpty
            ? EmptyState(onAddPressed: _openAddCredentialDialog)
            : RefreshIndicator(
                color: AppTheme.accent,
                backgroundColor: AppTheme.elevatedSurface,
                onRefresh: _loadCredentials,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _credentials.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _credentials[index];
                    final isSelected = _selectedIds.contains(item.id);

                    return Dismissible(
                      key: ValueKey('dismiss_${item.id}'),
                      direction: _isSelectionMode
                          ? DismissDirection.none
                          : DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: AppTheme.dangerSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppTheme.danger.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Move to Bin',
                              style: TextStyle(
                                color: AppTheme.danger,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.delete_sweep_rounded,
                              color: AppTheme.danger,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                      onDismissed: (_) => _moveToBin(item),
                      child: CredentialCard(
                        key: ValueKey(item.id),
                        item: item,
                        isSelectionMode: _isSelectionMode,
                        isSelected: isSelected,
                        onSelectChanged: (val) {
                          setState(() {
                            if (val) {
                              _selectedIds.add(item.id);
                            } else {
                              _selectedIds.remove(item.id);
                            }
                          });
                        },
                        onStartSelection: () => _enterSelectionMode(item.id),
                        onEdit: () => _openEditCredentialDialog(item),
                        onDelete: () => _moveToBin(item),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  PreferredSizeWidget _buildNormalAppBar() {
    return AppBar(
      title: const Text('Chest'),
      actions: [
        // Multi-select toggle button
        if (_credentials.isNotEmpty)
          IconButton(
            tooltip: 'Select items',
            icon: const Icon(
              Icons.checklist_rounded,
              size: 22,
              color: AppTheme.secondaryText,
            ),
            onPressed: () => _enterSelectionMode(),
          ),
        // Bin navigation button with badge
        Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              tooltip: 'Deleted Bin',
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 22,
                color: AppTheme.secondaryText,
              ),
              onPressed: _openBinPage,
            ),
            if (_deletedCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.danger,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    _deletedCount > 99 ? '99+' : '$_deletedCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        // Add Credential button
        IconButton(
          tooltip: 'Add Credential',
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.accent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
          ),
          onPressed: _openAddCredentialDialog,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  PreferredSizeWidget _buildSelectionAppBar() {
    final count = _selectedIds.length;
    final allSelected =
        _credentials.isNotEmpty && _selectedIds.length == _credentials.length;

    return AppBar(
      leading: IconButton(
        tooltip: 'Close selection',
        icon: const Icon(Icons.close_rounded, color: AppTheme.primaryText),
        onPressed: _exitSelectionMode,
      ),
      title: Text(
        '$count Selected',
        style: const TextStyle(
          color: AppTheme.primaryText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _toggleSelectAll,
          child: Text(
            allSelected ? 'Deselect All' : 'Select All',
            style: const TextStyle(
              color: AppTheme.accentLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Move selected to Bin',
          icon: Icon(
            Icons.delete_outline_rounded,
            color: count > 0 ? AppTheme.danger : AppTheme.secondaryText,
          ),
          onPressed: count > 0 ? _moveSelectedToBin : null,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
