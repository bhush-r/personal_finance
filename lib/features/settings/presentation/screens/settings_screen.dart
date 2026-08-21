import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/currency_constants.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    context.read<SettingsCubit>().loadPreferences();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SettingsLoaded) {
            return FadeTransition(
              opacity: _animationController,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSectionHeader("Profile"),
                  _buildCard(
                    child: Column(
                      children: [
                        _buildTile(
                          icon: Iconsax.user,
                          title: "Name",
                          subtitle: state.preferences.userName ?? "Not set",
                          onTap: () => _showEditNameDialog(state),
                        ),
                        const Divider(),
                        _buildTile(
                          icon: Iconsax.sms,
                          title: "Email",
                          subtitle: state.preferences.userEmail ?? "Not set",
                          onTap: () => _showEditEmailDialog(state),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionHeader("Appearance"),
                  _buildCard(
                    child: Column(
                      children: [
                        _buildToggleTile(
                          icon: Iconsax.moon,
                          title: "Dark Mode",
                          value: state.darkMode,
                          onChanged: (v) {
                            context.read<SettingsCubit>().toggleDarkMode(v);
                            context.read<ThemeProvider>().toggleDarkMode(v);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionHeader("Finance"),
                  _buildCard(
                    child: Column(
                      children: [
                        _buildTile(
                          icon: Iconsax.money,
                          title: "Currency",
                          subtitle: state.preferences.currency,
                          trailing: Icon(Iconsax.arrow_right_3,
                              color: Colors.grey.shade400, size: 18),
                          onTap: () => _showCurrencySelector(state),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _showLogoutDialog,
                    icon: const Icon(Iconsax.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          }
          return const Center(
            child: Text("Error loading settings"),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          letterSpacing: 0.5,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 12))
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  void _showEditNameDialog(SettingsLoaded state) {
    final controller = TextEditingController(
      text: state.preferences.userName ?? '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Name"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter your name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final updated =
              state.preferences.copyWith(userName: controller.text);
              context.read<SettingsCubit>().updatePreferences(updated);
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showEditEmailDialog(SettingsLoaded state) {
    final controller = TextEditingController(
      text: state.preferences.userEmail ?? '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Email"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter your email"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final updated =
              state.preferences.copyWith(userEmail: controller.text);
              context.read<SettingsCubit>().updatePreferences(updated);
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showCurrencySelector(SettingsLoaded state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Select Currency"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: CurrencyConstants.supportedCurrencies.length,
            itemBuilder: (context, index) {
              final currency = CurrencyConstants.supportedCurrencies[index];
              final isSelected = state.preferences.currency == currency.code;
              return ListTile(
                leading: Text(
                  currency.symbol,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
                title: Text(currency.name),
                subtitle: Text(currency.country,
                    style: const TextStyle(fontSize: 11)),
                trailing: isSelected
                    ? const Icon(Iconsax.tick_circle, color: Colors.green)
                    : null,
                onTap: () {
                  context.read<SettingsCubit>().updateCurrency(currency.code);
                  Navigator.pop(ctx);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout?"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}