import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import '../../../../core/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ FIXED: Use WidgetsBinding to delay Cubit access
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SettingsCubit>().loadPreferences();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: BlocListener<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state is SettingsSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                duration: const Duration(seconds: 2),
              ),
            );
          }
          if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            if (state is SettingsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SettingsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.warning_2,
                      size: 64,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<SettingsCubit>().loadPreferences();
                      },
                      icon: const Icon(Iconsax.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (state is SettingsLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Appearance Section
                    _buildSectionTitle(context, 'Appearance'),
                    _buildThemeToggle(context, state),
                    const SizedBox(height: 24),

                    // Notifications Section
                    _buildSectionTitle(context, 'Notifications'),
                    _buildNotificationToggle(context, state),
                    const SizedBox(height: 24),

                    // Security Section
                    _buildSectionTitle(context, 'Security'),
                    _buildBiometricToggle(context, state),
                    const SizedBox(height: 24),

                    // Preferences Section
                    _buildSectionTitle(context, 'Preferences'),
                    _buildCurrencySelector(context, state),
                    const SizedBox(height: 24),

                    // About Section
                    _buildSectionTitle(context, 'About'),
                    _buildAboutTile(context),
                    const SizedBox(height: 24),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showLogoutConfirmation(context);
                        },
                        icon: const Icon(Iconsax.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  /// Build section title
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Build theme toggle
  Widget _buildThemeToggle(BuildContext context, SettingsLoaded state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.moon,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dark Mode',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Use dark theme',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // ✅ FIXED: Use getter instead of property
          Switch(
            value: state.darkMode,
            onChanged: (value) {
              context.read<SettingsCubit>().toggleDarkMode(value);
            },
          ),
        ],
      ),
    );
  }

  /// Build notification toggle
  Widget _buildNotificationToggle(BuildContext context, SettingsLoaded state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.notification,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Push Notifications',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Receive spending alerts',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // ✅ FIXED: Use getter instead of property
          Switch(
            value: state.notificationsEnabled,
            onChanged: (value) {
              context.read<SettingsCubit>().toggleNotifications(value);
            },
          ),
        ],
      ),
    );
  }

  /// Build biometric toggle
  Widget _buildBiometricToggle(BuildContext context, SettingsLoaded state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.shield_tick,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Biometric Login',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Use fingerprint or face ID',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // ✅ FIXED: Use getter instead of property
          Switch(
            value: state.biometricEnabled,
            onChanged: (value) {
              context.read<SettingsCubit>().toggleBiometric(value);
            },
          ),
        ],
      ),
    );
  }

  /// Build currency selector
  Widget _buildCurrencySelector(BuildContext context, SettingsLoaded state) {
    return GestureDetector(
      onTap: () {
        _showCurrencyPicker(context, state);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Iconsax.dollar_circle,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Currency',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // ✅ FIXED: Use getter instead of property
                    Text(
                      state.currency,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Icon(Iconsax.arrow_right_3, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  /// Show currency picker
  void _showCurrencyPicker(BuildContext context, SettingsLoaded state) {
    final currencies = ['₹ INR', '\$ USD', '€ EUR', '£ GBP'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Currency'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: currencies
                .map(
                  (currency) => RadioListTile<String>(
                title: Text(currency),
                value: currency,
                groupValue: state.currency,
                onChanged: (value) {
                  if (value != null) {
                    context.read<SettingsCubit>().updateCurrency(value);
                    Navigator.pop(ctx);
                  }
                },
              ),
            )
                .toList(),
          ),
        ),
      ),
    );
  }

  /// Build about tile
  Widget _buildAboutTile(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.info_circle,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About App',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Version 1.0.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Icon(Iconsax.arrow_right_3, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  /// Show logout confirmation
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // ✅ FIXED: Call logout method
              context.read<SettingsCubit>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}