import 'package:flowly/logic/cubits/auth_cubit.dart';
import 'package:flowly/logic/cubits/theme_cubit.dart';
import 'package:flowly/logic/cubits/settings_cubit.dart';
import 'package:flowly/core/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final currentTheme = context.watch<ThemeCubit>().state;
    final isDarkMode = currentTheme == ThemeMode.dark;

    final theme = Theme.of(context);

    if (authState is! AuthSuccess) {
      return const SizedBox();
    }

    final user = authState.user;
    final isOwner = user.role == 'OWNER';

    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- PROFILE CARD ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : "?",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(user.email, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isOwner
                              ? Colors.amber.withOpacity(0.2)
                              : Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          user.role,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isOwner
                                ? Colors.amber[800]
                                : Colors.blue[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // --- BUSINESS SETTINGS (OWNER ONLY) ---
          if (isOwner) ...[
            Text(
              "Business Management",
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.badge_outlined),
              title: const Text("My Owner ID"),
              subtitle: Text("ID: ${user.userId}"),
              trailing: IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: user.userId.toString()),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("ID Copied to clipboard!")),
                    );
                  }
                },
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person_add_alt_1_outlined),
              title: const Text("Add Staff Member"),
              subtitle: const Text("Create account for an employee"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(context, Routes.addStaff);
              },
            ),
            const Divider(),

            // ✅ AI SLIDERS SECTION (Updated below)
            const SizedBox(height: 16),
            _AiConfigurationSection(token: user.token),
            const SizedBox(height: 24),
          ],

          // --- GENERAL SETTINGS ---
          Text(
            "General",
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text("Dark Mode"),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (val) {
                context.read<ThemeCubit>().toggleTheme(val);
              },
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.language),
            title: const Text("Language"),
            subtitle: const Text("English"),
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Coming Soon!")));
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout),
            title: const Text("Log Out"),
            onTap: () {
              context.read<AuthCubit>().logout();
            },
          ),

          // --- DANGER ZONE ---
          if (isOwner) ...[
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
                color: Colors.red.withOpacity(0.05),
              ),
              child: ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text(
                  "Delete Business",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  "Permanently delete account and all staff",
                ),
                onTap: () =>
                    _confirmDeleteBusiness(context, user.token, user.userId),
              ),
            ),
          ],

          const SizedBox(height: 40),
          const Center(
            child: Text("Version 1.0.0", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteBusiness(BuildContext context, String token, int userId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Everything?"),
        content: const Text(
          "⚠️ WARNING: This cannot be undone.\n\n"
          "This will delete your account, your inventory, and ALL your staff accounts permanently.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close Dialog
              // We use pushNamedAndRemoveUntil to effectively "Logout and Reset"
              // The AuthCubit will clear state, but this ensures navigation is clean.
              Navigator.pop(context);
              context.read<AuthCubit>().deleteBusiness(token, userId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("DELETE PERMANENTLY"),
          ),
        ],
      ),
    );
  }
}

// 🧠 AI SLIDERS WIDGET (FULLY FIXED)
class _AiConfigurationSection extends StatefulWidget {
  final String token;
  const _AiConfigurationSection({required this.token});

  @override
  State<_AiConfigurationSection> createState() =>
      _AiConfigurationSectionState();
}

class _AiConfigurationSectionState extends State<_AiConfigurationSection> {
  // Local state for smooth sliding
  double? _inactiveDays;
  double? _vipOrders;
  double? _lowStock; // ✅ 1. Add Variable
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().getSettings(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state is SettingsLoaded && !_isInitialized) {
          setState(() {
            _inactiveDays = state.settings['inactiveThreshold']!.toDouble();
            _vipOrders = state.settings['vipOrderThreshold']!.toDouble();
            _lowStock = (state.settings['lowStockThreshold'] ?? 10).toDouble();
            _isInitialized = true;
          });
        }
        if (state is SettingsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final currentInactive = _inactiveDays ?? 30.0;
        final currentVip = _vipOrders ?? 5.0;
        final currentLow = _lowStock ?? 10.0; // ✅ 3. Default value for UI

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.purple, size: 20),
                SizedBox(width: 8),
                Text(
                  "AI & Automation Engine",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Customize how Flowly works for your business.",
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 20),

            // --- SLIDER 1: Inactivity ---
            _buildSliderHeader(
              "Inactivity Threshold",
              "${currentInactive.round()} Days",
            ),
            Slider(
              value: currentInactive,
              min: 7,
              max: 90,
              divisions: 83,
              label: "${currentInactive.round()} days",
              activeColor: Colors.purple,
              onChanged: (val) {
                setState(() => _inactiveDays = val);
              },
              onChangeEnd: (val) {
                context.read<SettingsCubit>().updateSettings(
                  widget.token,
                  val.round(),
                  currentVip.round(),
                  currentLow.round(),
                );
              },
            ),

            // --- SLIDER 2: VIP ---
            _buildSliderHeader("VIP Threshold", "${currentVip.round()} Orders"),
            Slider(
              value: currentVip,
              min: 1,
              max: 50,
              divisions: 49,
              label: "${currentVip.round()} orders",
              activeColor: Colors.amber,
              onChanged: (val) {
                setState(() => _vipOrders = val);
              },
              onChangeEnd: (val) {
                context.read<SettingsCubit>().updateSettings(
                  widget.token,
                  currentInactive.round(),
                  val.round(),
                  currentLow.round(),
                );
              },
            ),

            // --- SLIDER 3: LOW STOCK (Added) ---
            const SizedBox(height: 10),
            _buildSliderHeader(
              "Low Stock Alert",
              "${currentLow.round()} Units",
            ),
            Slider(
              value: currentLow,
              min: 1,
              max: 50,
              divisions: 49,
              label: "${currentLow.round()} units",
              activeColor: Colors.redAccent, // 🔴 Red for Warning
              onChanged: (val) {
                setState(() => _lowStock = val);
              },
              onChangeEnd: (val) {
                context.read<SettingsCubit>().updateSettings(
                  widget.token,
                  currentInactive.round(),
                  currentVip.round(),
                  val.round(), // ✅ Send new Low Stock value
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSliderHeader(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
