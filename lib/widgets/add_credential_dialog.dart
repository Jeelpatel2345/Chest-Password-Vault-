import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/password_item.dart';
import '../theme/app_theme.dart';

/// Modal dialog for creating or editing a credential entry.
class AddCredentialDialog extends StatefulWidget {
  final PasswordItem? initialItem;

  const AddCredentialDialog({super.key, this.initialItem});

  @override
  State<AddCredentialDialog> createState() => _AddCredentialDialogState();
}

class _AddCredentialDialogState extends State<AddCredentialDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _appNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  bool _isPasswordObscured = true;

  bool get _isEditing => widget.initialItem != null;

  @override
  void initState() {
    super.initState();
    _appNameController = TextEditingController(
      text: widget.initialItem?.appName ?? '',
    );
    _usernameController = TextEditingController(
      text: widget.initialItem?.username ?? '',
    );
    _passwordController = TextEditingController(
      text: widget.initialItem?.password ?? '',
    );
  }

  @override
  void dispose() {
    _appNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final PasswordItem result;
    if (_isEditing) {
      result = widget.initialItem!.copyWith(
        appName: _appNameController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      result = PasswordItem(
        id: const Uuid().v4(),
        appName: _appNameController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        createdAt: DateTime.now(),
      );
    }

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.elevatedSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppTheme.border, width: 1),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.border, width: 1),
                      ),
                      child: Icon(
                        _isEditing
                            ? Icons.edit_note_rounded
                            : Icons.add_moderator_rounded,
                        color: AppTheme.accent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isEditing ? 'Edit Credential' : 'Add Credential',
                        style: const TextStyle(
                          color: AppTheme.primaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // App / Website Name Field
                const Text(
                  'App / Website Name',
                  style: TextStyle(
                    color: AppTheme.secondaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _appNameController,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    color: AppTheme.primaryText,
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'e.g., GitHub, Google, Netflix',
                    prefixIcon: Icon(
                      Icons.web_rounded,
                      size: 18,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the app or website name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ID / Username / Email Field
                const Text(
                  'ID / Username / Email',
                  style: TextStyle(
                    color: AppTheme.secondaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _usernameController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                    color: AppTheme.primaryText,
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'e.g., username or name@example.com',
                    prefixIcon: Icon(
                      Icons.person_outline_rounded,
                      size: 18,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the username or email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field
                const Text(
                  'Password',
                  style: TextStyle(
                    color: AppTheme.secondaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isPasswordObscured,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _onSave(),
                  style: const TextStyle(
                    color: AppTheme.primaryText,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter password',
                    prefixIcon: const Icon(
                      Icons.key_rounded,
                      size: 18,
                      color: AppTheme.secondaryText,
                    ),
                    suffixIcon: IconButton(
                      tooltip: _isPasswordObscured
                          ? 'Show password'
                          : 'Hide password',
                      icon: Icon(
                        _isPasswordObscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: AppTheme.secondaryText,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordObscured = !_isPasswordObscured;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Action Buttons (Wrap guarantees zero RenderFlex overflow on any screen width)
                Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: _onSave,
                      child: Text(
                        _isEditing ? 'Update Credential' : 'Save Credential',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
