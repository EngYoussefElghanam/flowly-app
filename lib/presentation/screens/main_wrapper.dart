import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Screens
import 'package:flowly/presentation/screens/home_screen.dart';
import 'package:flowly/presentation/screens/pos_screen.dart';
import 'package:flowly/presentation/screens/inventory_screen.dart';
import 'package:flowly/presentation/screens/customer_screen.dart';
import 'package:flowly/presentation/screens/growth_page.dart'; // ✅ Imported
import 'package:flowly/presentation/screens/menu_screen.dart';

// Logic & Navigation
import '../../logic/cubits/auth_cubit.dart';
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

    // 🛡️ Guard
    if (authState is! AuthSuccess) {
      return;
    }

    final user = authState.user;
    final role = user.role;

    // ✅ EXPLICIT LISTS (No confusing shortcuts)
    if (role == 'OWNER') {
      // 👑 OWNER: Overview + Everything else
      _tabs = [
        const NavItem(
          page: HomeScreen(),
          label: "Overview",
          icon: Icons.dashboard_outlined,
        ),
        const NavItem(
          page: PosScreen(), // Owner can sell too
          label: "Sell",
          icon: Icons.point_of_sale,
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
        const NavItem(
          page: GrowthPage(),
          label: "Growth",
          icon: Icons.auto_graph,
        ),
        const NavItem(page: MenuScreen(), label: "Menu", icon: Icons.menu),
      ];
    } else {
      // 👷 EMPLOYEE: Everything except Overview
      _tabs = [
        const NavItem(
          page: PosScreen(),
          label: "Sell",
          icon: Icons.point_of_sale,
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
        const NavItem(
          page: GrowthPage(),
          label: "Growth",
          icon: Icons.auto_graph,
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

    final theme = Theme.of(context);

    return Scaffold(
      // IndexedStack preserves state (Good for POS/Inventory not reloading)
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs.map((tab) => tab.page).toList(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),

          // Styling
          backgroundColor: theme.colorScheme.surface,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.5),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed, // Required for 4+ tabs
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
