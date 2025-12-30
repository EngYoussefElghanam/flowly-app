import 'package:flowly/presentation/screens/customer_screen.dart';
import 'package:flowly/presentation/screens/menu_screen.dart';
import 'package:flowly/presentation/screens/home_screen.dart'; // 1. Import HomeScreen
import 'package:flowly/presentation/screens/pos_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubits/auth_cubit.dart';
import 'inventory_screen.dart';
import '../navigation/nav_item.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  List<NavItem> _tabs = [];

  @override
  void initState() {
    super.initState();
    _setupTabs();
  }

  void _setupTabs() {
    final authState = context.read<AuthCubit>().state;

    // 🛡️ GUARD
    if (authState is! AuthSuccess) {
      return;
    }

    final user = authState.user;
    final role = user.role;

    if (role == 'OWNER') {
      _tabs = [
        // 2. CLEANER: Use the HomeScreen we built earlier!
        // It already has the Gradient AppBar and DashboardView inside.
        const NavItem(
          page: HomeScreen(),
          label: "Overview",
          icon: Icons.dashboard_outlined,
        ),
        const NavItem(
          page: InventoryScreen(),
          label: "Inventory",
          icon: Icons.inventory_2_outlined,
        ),
        const NavItem(
          page: CustomersScreen(),
          label: "Customers",
          icon: Icons.people_outline,
        ),
        const NavItem(page: MenuScreen(), label: "Menu", icon: Icons.menu),
      ];
    } else {
      // EMPLOYEE VIEW
      _tabs = [
        NavItem(page: PosScreen(), label: "Sell", icon: Icons.point_of_sale),
        const NavItem(
          page: InventoryScreen(),
          label: "Inventory",
          icon: Icons.inventory_2_outlined,
        ),
        const NavItem(
          page: CustomersScreen(),
          label: "Customers",
          icon: Icons.people_outline,
        ),
        const NavItem(page: MenuScreen(), label: "Menu", icon: Icons.menu),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_tabs.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 3. Capture Theme
    final theme = Theme.of(context);

    return Scaffold(
      // The body handles the AppBar, so we just show the page
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs.map((tab) => tab.page).toList(),
      ),

      // 4. THEMED BOTTOM NAVIGATION BAR
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          // Use Surface color (White/DarkGrey) instead of hardcoded white
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // Subtle shadow
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),

          // DYNAMIC COLORS
          backgroundColor:
              theme.colorScheme.surface, // ⬜ White (Light) / ⬛ Dark Grey (Dark)
          selectedItemColor:
              theme.colorScheme.primary, // ⚫ Black (Light) / ⚪ White (Dark)
          unselectedItemColor: theme.colorScheme.onSurface.withOpacity(
            0.5,
          ), // 🔘 Grey

          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: _tabs.map((tab) {
            return BottomNavigationBarItem(
              icon: Icon(tab.icon),
              label: tab.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}
