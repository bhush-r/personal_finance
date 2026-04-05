import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/currency_constants.dart';
import '../../../../core/theme/theme_provider.dart';
import 'package:provider/provider.dart';
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
                  // ✨ PROFILE SECTION
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

                  // ✨ APPEARANCE SECTION
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
                        const Divider(),
                        _buildTile(
                          icon: Iconsax.global,
                          title: "Language",
                          subtitle: "English",
                          trailing: Icon(Iconsax.arrow_right_3,
                              color: Colors.grey.shade400, size: 18),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ✨ CURRENCY & FINANCE SECTION
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
                  const SizedBox(height: 20),

                  // ✨ NOTIFICATIONS & REMINDERS
                  _buildSectionHeader("Notifications"),
                  _buildCard(
                    child: Column(
                      children: [
                        _buildToggleTile(
                          icon: Iconsax.notification,
                          title: "Push Notifications",
                          value: state.notificationsEnabled,
                          onChanged: (v) {
                            context
                                .read<SettingsCubit>()
                                .toggleNotifications(v);
                          },
                        ),
                        const Divider(),
                        _buildToggleTile(
                          icon: Iconsax.alarm,
                          title: "Reminders",
                          value: state.preferences.enableReminders,
                          onChanged: (v) {
                            context.read<SettingsCubit>().toggleReminders(v);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ✨ SECURITY SECTION
                  _buildSectionHeader("Security"),
                  _buildCard(
                    child: Column(
                      children: [
                        _buildToggleTile(
                          icon: Iconsax.finger_cricle,
                          title: "Biometric Lock",
                          value: state.biometricEnabled,
                          onChanged: (v) {
                            context.read<SettingsCubit>().toggleBiometric(v);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ✨ DATA SECTION
                  _buildSectionHeader("Data"),
                  _buildCard(
                    child: Column(
                      children: [
                        _buildTile(
                          icon: Iconsax.export,
                          title: "Export Data",
                          subtitle: state.preferences.lastDataExport != null
                              ? "Last: ${state.preferences.lastDataExport!.toString().split(' ')[0]}"
                              : "Never",
                          trailing: Icon(Iconsax.arrow_right_3,
                              color: Colors.grey.shade400, size: 18),
                          onTap: () => _showExportDialog(state),
                        ),
                        const Divider(),
                        _buildTile(
                          icon: Iconsax.trash,
                          title: "Clear Data",
                          subtitle: "Permanently delete all data",
                          trailing: Icon(Iconsax.arrow_right_3,
                              color: Colors.grey.shade400, size: 18),
                          onTap: () => _showClearDataDialog(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ✨ ABOUT SECTION
                  _buildSectionHeader("About"),
                  _buildCard(
                    child: Column(
                      children: [
                        _buildTile(
                          icon: Iconsax.info_circle,
                          title: "Version",
                          subtitle: "1.0.0",
                        ),
                        const Divider(),
                        _buildTile(
                          icon: Iconsax.shield_tick,
                          title: "Privacy Policy",
                          trailing: Icon(Iconsax.arrow_right_3,
                              color: Colors.grey.shade400, size: 18),
                        ),
                        const Divider(),
                        _buildTile(
                          icon: Iconsax.document_text,
                          title: "Terms of Service",
                          trailing: Icon(Iconsax.arrow_right_3,
                              color: Colors.grey.shade400, size: 18),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ✨ LOGOUT BUTTON
                  ElevatedButton.icon(
                    onPressed: () => _showLogoutDialog(),
                    icon: const Icon(Iconsax.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
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
      subtitle:
      subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12))
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
              final currency =
              CurrencyConstants.supportedCurrencies[index];
              final isSelected =
                  state.preferences.currency == currency.code;

              return ListTile(
                leading: Text(
                  currency.symbol,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                title: Text(currency.name),
                subtitle: Text(currency.country, style: const TextStyle(fontSize: 11)),
                trailing: isSelected
                    ? const Icon(Iconsax.tick_circle, color: Colors.green)
                    : null,
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
      ),
    );
  }

  void _showExportDialog(SettingsLoaded state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Export Data"),
        content: const Text(
          "Export all your financial data as CSV? This includes transactions, goals, and insights.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement data export functionality
              context.read<SettingsCubit>().updateLastExportDate();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Data exported successfully"),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text("Export"),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Clear All Data?"),
        content: const Text(
          "This will permanently delete all your financial data. This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement data clearing
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("All data cleared"),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              "Clear",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
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
              context.read<SettingsCubit>().logout();
              Navigator.pop(ctx);
              // TODO: Navigate to login screen
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