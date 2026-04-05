import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoaded) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _card(child: _tile("Dark Mode", state.darkMode, (v) {
                  context.read<SettingsCubit>().toggleDarkMode(v);
                })),

                const SizedBox(height: 16),

                _card(child: _tile("Notifications", state.notificationsEnabled, (v) {
                  context.read<SettingsCubit>().toggleNotifications(v);
                })),

                const SizedBox(height: 16),

                _card(child: _tile("Biometric", state.biometricEnabled, (v) {
                  context.read<SettingsCubit>().toggleBiometric(v);
                })),
              ],
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _tile(String title, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}