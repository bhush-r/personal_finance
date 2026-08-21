import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/currency_constants.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is SettingsLoaded) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionTitle(context, 'Profile'),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Iconsax.user,
                          color: Colors.blue,
                        ),
                        title: const Text('Name'),
                        subtitle: Text(
                          state.preferences.userName?.isNotEmpty == true
                              ? state.preferences.userName!
                              : 'Not set',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showEditNameDialog(state),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(
                          Iconsax.sms,
                          color: Colors.blue,
                        ),
                        title: const Text('Email'),
                        subtitle: Text(
                          state.preferences.userEmail?.isNotEmpty == true
                              ? state.preferences.userEmail!
                              : 'Not set',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showEditEmailDialog(state),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Appearance'),
                Card(
                  child: SwitchListTile(
                    secondary: const Icon(
                      Iconsax.moon,
                      color: Colors.blue,
                    ),
                    title: const Text('Dark Mode'),
                    subtitle: Text(
                      state.darkMode ? 'Enabled' : 'Disabled',
                    ),
                    value: state.darkMode,
                    onChanged: (value) {
                      context.read<SettingsCubit>().toggleDarkMode(value);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Finance'),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Iconsax.money,
                      color: Colors.blue,
                    ),
                    title: const Text('Currency'),
                    subtitle: Text(state.preferences.currency),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showCurrencySelector(state),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showLogoutDialog,
                    icon: const Icon(Iconsax.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          }

          return const Center(
            child: Text('Error loading settings'),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _showEditNameDialog(SettingsLoaded state) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _EditNameDialog(
        initialValue: state.preferences.userName ?? '',
        onSave: (newName) {
          final updated = state.preferences.copyWith(userName: newName);
          context.read<SettingsCubit>().updatePreferences(updated);
        },
      ),
    );
  }

  void _showEditEmailDialog(SettingsLoaded state) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _EditEmailDialog(
        initialValue: state.preferences.userEmail ?? '',
        onSave: (newEmail) {
          final updated = state.preferences.copyWith(userEmail: newEmail);
          context.read<SettingsCubit>().updatePreferences(updated);
        },
      ),
    );
  }

  void _showCurrencySelector(SettingsLoaded state) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Select Currency'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: CurrencyConstants.supportedCurrencies.length,
              itemBuilder: (context, index) {
                final currency = CurrencyConstants.supportedCurrencies[index];
                final isSelected = state.preferences.currency == currency.code;

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      currency.symbol,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(currency.name),
                  subtitle: Text(currency.country),
                  trailing: isSelected
                      ? const Icon(
                    Iconsax.tick_circle,
                    color: Colors.green,
                  )
                      : null,
                  selected: isSelected,
                  onTap: () {
                    context
                        .read<SettingsCubit>()
                        .updateCurrency(currency.code);
                    Navigator.pop(ctx);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Logout?'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<AuthBloc>().add(const AuthSignOutRequested());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

// ----------------------------------------------------------------------------
// SAFE EDIT NAME DIALOG WIDGET
// ----------------------------------------------------------------------------
class _EditNameDialog extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onSave;

  const _EditNameDialog({
    required this.initialValue,
    required this.onSave,
  });

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Name'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          labelText: 'Name',
          hintText: 'Enter your name',
          prefixIcon: Icon(Iconsax.user),
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_controller.text.trim());
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------------------
// SAFE EDIT EMAIL DIALOG WIDGET
// ----------------------------------------------------------------------------
class _EditEmailDialog extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onSave;

  const _EditEmailDialog({
    required this.initialValue,
    required this.onSave,
  });

  @override
  State<_EditEmailDialog> createState() => _EditEmailDialogState();
}

class _EditEmailDialogState extends State<_EditEmailDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Email'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          labelText: 'Email',
          hintText: 'Enter your email',
          prefixIcon: Icon(Iconsax.sms),
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_controller.text.trim());
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}