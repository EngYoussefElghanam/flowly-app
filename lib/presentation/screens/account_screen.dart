import 'package:flowly/logic/cubits/auth_cubit.dart';
import 'package:flowly/logic/cubits/theme_cubit.dart';
import 'package:flowly/logic/cubits/settings_cubit.dart'; // ✅ Import SettingsCubit
import 'package:flowly/presentation/screens/add_stuff_screen.dart';
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
          // --- PROFILE CARD (Unchanged) ---
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddStaffScreen()),
                );
              },
            ),
            const Divider(),

            // ✅ NEW AI SLIDERS SECTION
            const SizedBox(height: 16),
            // We pass the token to the sub-widget so it can save data
            _AiConfigurationSection(token: user.token),
            const SizedBox(height: 24),
          ],

          // --- GENERAL SETTINGS (Unchanged) ---
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
          const SizedBox(height: 40),
          const Center(
            child: Text("Version 1.0.0", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}

// 🧠 NEW WIDGET: Handles the Sliders Logic
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
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Load fresh settings when this widget appears
    context.read<SettingsCubit>().getSettings(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state is SettingsLoaded && !_isInitialized) {
          // Sync sliders only once on load
          setState(() {
            _inactiveDays = state.settings['inactiveThreshold']!.toDouble();
            _vipOrders = state.settings['vipOrderThreshold']!.toDouble();
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
        // Defaults if loading
        final currentInactive = _inactiveDays ?? 30.0;
        final currentVip = _vipOrders ?? 5.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.purple, size: 20),
                SizedBox(width: 8),
                Text(
                  "AI Growth Engine",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Customize how Flowly identifies opportunities.",
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 20),

            // --- SLIDER 1 ---
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
                // Auto-save when user releases the slider 💾
                context.read<SettingsCubit>().updateSettings(
                  widget.token,
                  val.round(),
                  currentVip.round(),
                );
              },
            ),

            // --- SLIDER 2 ---
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
                // Auto-save when user releases the slider 💾
                context.read<SettingsCubit>().updateSettings(
                  widget.token,
                  currentInactive.round(),
                  val.round(),
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
