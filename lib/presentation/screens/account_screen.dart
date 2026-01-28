import 'package:flowly/logic/cubits/auth_cubit.dart';
import 'package:flowly/logic/cubits/theme_cubit.dart'; // Import ThemeCubit
import 'package:flowly/presentation/screens/add_stuff_screen.dart'; // Correct Import
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Needed for Clipboard
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    // Watch ThemeCubit to update the switch UI
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
              subtitle: Text("ID: ${user.userId}"), // Use user.id
              trailing: IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: () async {
                  // ✅ Copy logic
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
                // ✅ Navigation works now
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddStaffScreen()),
                );
              },
            ),
            const Divider(),
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
                // ✅ Toggle Theme logic
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
          Center(
            child: Text("Version 1.0.0", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
