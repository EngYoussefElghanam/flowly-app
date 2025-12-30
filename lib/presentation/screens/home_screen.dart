import 'package:flowly/presentation/screens/dashboard_view.dart';
import 'package:flowly/presentation/screens/employee_home_view.dart';
import 'package:flowly/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubits/auth_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;

    if (authState is! AuthSuccess) {
      return const LoginScreen();
    }

    final user = authState.user;
    final isOwner = user.role == 'OWNER';
    final theme = Theme.of(context); // 🎨 Capture Theme

    // ⚠️ Note: We REMOVED BlocProvider<DashboardCubit> here.
    // Why? Because 'DashboardView' now handles its own Cubit internally.
    // This prevents fetching data twice!

    return Scaffold(
      // Background color is handled by AppTheme
      appBar: AppBar(
        toolbarHeight: 80,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome back,",
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            // 🎨 Use Theme Error Color (Red)
            icon: Icon(Icons.logout, color: theme.colorScheme.error),
            onPressed: () => context.read<AuthCubit>().logout(),
          ),
        ],
      ),
      body: isOwner ? const DashboardView() : const EmployeeHomeView(),
    );
  }
}
