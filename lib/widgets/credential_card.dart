import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/password_item.dart';
import '../theme/app_theme.dart';

/// Card widget to display a single saved credential with reveal toggle,
/// copy options, long-press actions (Edit / Remove), and multi-selection support.
class CredentialCard extends StatefulWidget {
  final PasswordItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isSelectionMode;
  final bool isSelected;
  final ValueChanged<bool>? onSelectChanged;
  final VoidCallback? onStartSelection;

  const CredentialCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelectChanged,
    this.onStartSelection,
  });

  @override
  State<CredentialCard> createState() => _CredentialCardState();
}

enum _CardAction { edit, delete, select }

class _CredentialCardState extends State<CredentialCard> {
  bool _isPasswordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showActionSheet() async {
    final action = await showModalBottomSheet<_CardAction>(
      context: context,
      backgroundColor: AppTheme.elevatedSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AppTheme.border, width: 1),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                // Header info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.border, width: 1),
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          size: 18,
                          color: AppTheme.accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item.appName,
                              style: const TextStyle(
                                color: AppTheme.primaryText,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              widget.item.username,
                              style: const TextStyle(
                                color: AppTheme.secondaryText,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.edit_outlined,
                    color: AppTheme.primaryText,
                  ),
                  title: const Text(
                    'Edit Credential',
                    style: TextStyle(color: AppTheme.primaryText),
                  ),
                  subtitle: const Text(
                    'Modify website name, username or password',
                    style: TextStyle(
                      color: AppTheme.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  onTap: () => Navigator.of(sheetContext).pop(_CardAction.edit),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppTheme.danger,
                  ),
                  title: const Text(
                    'Move to Bin',
                    style: TextStyle(color: AppTheme.danger),
                  ),
                  subtitle: const Text(
                    'Item can be restored later from the bin',
                    style: TextStyle(
                      color: AppTheme.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  onTap: () =>
                      Navigator.of(sheetContext).pop(_CardAction.delete),
                ),
                if (widget.onStartSelection != null)
                  ListTile(
                    leading: const Icon(
                      Icons.checklist_rounded,
                      color: AppTheme.accent,
                    ),
                    title: const Text(
                      'Select Multiple',
                      style: TextStyle(color: AppTheme.primaryText),
                    ),
                    subtitle: const Text(
                      'Choose multiple items to bin together',
                      style: TextStyle(
                        color: AppTheme.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                    onTap: () =>
                        Navigator.of(sheetContext).pop(_CardAction.select),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || action == null) return;

    switch (action) {
      case _CardAction.edit:
        widget.onEdit();
        break;
      case _CardAction.delete:
        widget.onDelete();
        break;
      case _CardAction.select:
        widget.onStartSelection?.call();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final maskedPassword = '•' * (widget.item.password.length.clamp(8, 16));

    return Card(
      color: widget.isSelected
          ? AppTheme.accent.withValues(alpha: 0.12)
          : AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: widget.isSelected ? AppTheme.accent : AppTheme.border,
          width: widget.isSelected ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: widget.isSelectionMode
            ? () => widget.onSelectChanged?.call(!widget.isSelected)
            : null,
        onLongPress: widget.isSelectionMode ? null : _showActionSheet,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Row: Checkbox (if in selection mode) + App Icon & Name + Actions
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.isSelectionMode) ...[
                    Checkbox(
                      value: widget.isSelected,
                      activeColor: AppTheme.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          widget.onSelectChanged?.call(val);
                        }
                      },
                    ),
                    const SizedBox(width: 4),
                  ],
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.border, width: 1),
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      size: 18,
                      color: AppTheme.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.item.appName,
                      style: const TextStyle(
                        color: AppTheme.primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!widget.isSelectionMode) ...[
                    // Password reveal toggle
                    IconButton(
                      tooltip: _isPasswordVisible
                          ? 'Hide password'
                          : 'Show password',
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: _isPasswordVisible
                            ? AppTheme.accent
                            : AppTheme.secondaryText,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                    // More / Actions button (Edit / Remove popup)
                    IconButton(
                      tooltip: 'Options (Edit / Remove)',
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        size: 20,
                        color: AppTheme.secondaryText,
                      ),
                      onPressed: _showActionSheet,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),

              // Username / ID Field
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
                      widget.item.username,
                      style: const TextStyle(
                        color: AppTheme.secondaryText,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!widget.isSelectionMode)
                    IconButton(
                      tooltip: 'Copy username',
                      icon: const Icon(
                        Icons.copy_rounded,
                        size: 16,
                        color: AppTheme.secondaryText,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () =>
                          _copyToClipboard(widget.item.username, 'Username'),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Password Field
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
                      _isPasswordVisible
                          ? widget.item.password
                          : maskedPassword,
                      style: TextStyle(
                        color: _isPasswordVisible
                            ? AppTheme.primaryText
                            : AppTheme.secondaryText,
                        fontSize: _isPasswordVisible ? 14 : 16,
                        fontWeight: _isPasswordVisible
                            ? FontWeight.w500
                            : FontWeight.w700,
                        letterSpacing: _isPasswordVisible ? 0.2 : 2.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!widget.isSelectionMode)
                    IconButton(
                      tooltip: 'Copy password',
                      icon: const Icon(
                        Icons.copy_rounded,
                        size: 16,
                        color: AppTheme.secondaryText,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () =>
                          _copyToClipboard(widget.item.password, 'Password'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
