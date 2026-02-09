import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flowly/data/models/product_model.dart';
import 'package:flowly/data/repositories/auth_repository.dart';
import 'package:flowly/data/repositories/customer_repository.dart';
import 'package:flowly/data/repositories/dashboard_repository.dart';
import 'package:flowly/data/repositories/marketing_repository.dart';
import 'package:flowly/data/repositories/order_repository.dart';
import 'package:flowly/data/repositories/product_repository.dart';
import 'package:flowly/logic/cubits/add_customer_cubit.dart';
import 'package:flowly/logic/cubits/add_product_cubit.dart';
import 'package:flowly/logic/cubits/auth_cubit.dart';
import 'package:flowly/logic/cubits/checkout_cubit.dart';
import 'package:flowly/logic/cubits/customer_cubit.dart';
import 'package:flowly/logic/cubits/customer_details_cubit.dart';
import 'package:flowly/logic/cubits/customer_stats_cubit.dart';
import 'package:flowly/logic/cubits/dashboard_cubit.dart';
import 'package:flowly/logic/cubits/inventory_cubit.dart';
import 'package:flowly/logic/cubits/marketing_cubit.dart';
import 'package:flowly/logic/cubits/order_details_cubit.dart';
import 'package:flowly/logic/cubits/staff_cubit.dart';
import 'package:flowly/presentation/screens/account_screen.dart';
import 'package:flowly/presentation/screens/add_customer_screen.dart';
import 'package:flowly/presentation/screens/add_product_screen.dart';
import 'package:flowly/presentation/screens/add_staff_screen.dart';
import 'package:flowly/presentation/screens/checkout_sheet.dart';
import 'package:flowly/presentation/screens/customer_details_screen.dart';
import 'package:flowly/presentation/screens/customer_screen.dart';
import 'package:flowly/presentation/screens/growth_page.dart';
import 'package:flowly/presentation/screens/inventory_screen.dart';
import 'package:flowly/presentation/screens/login_screen.dart';
import 'package:flowly/presentation/screens/main_wrapper.dart';
import 'package:flowly/presentation/screens/order_details_screen.dart';
import 'package:flowly/presentation/screens/pos_screen.dart';
import 'package:flowly/presentation/screens/signup_screen.dart';
import 'package:flowly/presentation/screens/staff_management_screen.dart';
import 'package:flowly/presentation/screens/verification_screen.dart';

class Routes {
  static const root = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const main = '/main';
  static const inventory = '/inventory';
  static const productForm = '/inventory/product';
  static const customers = '/customers';
  static const addCustomer = '/customers/add';
  static const customerDetails = '/customers/details';
  static const orderDetails = '/orders/details';
  static const pos = '/pos';
  static const growth = '/growth';
  static const staff = '/staff';
  static const addStaff = '/staff/add';
  static const account = '/account';
  static const verification = '/verification';
}

class ProductFormArgs {
  final InventoryCubit inventoryCubit;
  final ProductModel? product;

  const ProductFormArgs({required this.inventoryCubit, this.product});
}

class CustomerDetailsArgs {
  final int customerId;
  final String customerName;

  const CustomerDetailsArgs({
    required this.customerId,
    required this.customerName,
  });
}

class OrderDetailsArgs {
  final int orderId;

  const OrderDetailsArgs({required this.orderId});
}

class VerificationArgs {
  final String email;
  final VerificationMode mode;
  final StaffCubit? staffCubit;

  const VerificationArgs({
    required this.email,
    this.mode = VerificationMode.ownerSignup,
    this.staffCubit,
  });
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.root:
        return MaterialPageRoute(builder: _buildAuthGate);
      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Routes.signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case Routes.main:
        return MaterialPageRoute(builder: _buildMainWrapper);
      case Routes.inventory:
        return MaterialPageRoute(builder: _buildInventoryScreen);
      case Routes.productForm:
        return _buildProductFormRoute(settings.arguments);
      case Routes.customers:
        return MaterialPageRoute(builder: _buildCustomersScreen);
      case Routes.addCustomer:
        return MaterialPageRoute(builder: _buildAddCustomerScreen);
      case Routes.customerDetails:
        return _buildCustomerDetailsRoute(settings.arguments);
      case Routes.orderDetails:
        return _buildOrderDetailsRoute(settings.arguments);
      case Routes.pos:
        return MaterialPageRoute(builder: _buildPosScreen);
      case Routes.growth:
        return MaterialPageRoute(builder: _buildGrowthScreen);
      case Routes.staff:
        return MaterialPageRoute(builder: _buildStaffManagementScreen);
      case Routes.addStaff:
        return MaterialPageRoute(builder: _buildAddStaffScreen);
      case Routes.account:
        return MaterialPageRoute(builder: (_) => const AccountScreen());
      case Routes.verification:
        return _buildVerificationRoute(settings.arguments);
      default:
        return _unknownRoute(settings.name);
    }
  }

  static Future<T?> showCheckoutSheet<T>(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final token = (authState is AuthSuccess) ? authState.user.token : '';

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                CustomerCubit(CustomerRepository())..getCustomers(token),
          ),
          BlocProvider(create: (_) => CheckoutCubit(OrderRepository())),
        ],
        child: const CheckoutSheet(),
      ),
    );
  }

  static Widget _buildAuthGate(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator.adaptive()),
          );
        }
        if (state is AuthSuccess) {
          return _buildMainWrapper(context);
        }
        return const LoginScreen();
      },
    );
  }

  static Widget _buildMainWrapper(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthSuccess) {
      return const LoginScreen();
    }

    final token = authState.user.token;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              InventoryCubit(ProductRepository())..getProducts(token),
        ),
        BlocProvider(
          create: (_) =>
              CustomerCubit(CustomerRepository())..getCustomers(token),
        ),
        BlocProvider(
          create: (_) =>
              DashboardCubit(DashboardRepository())..getStats(token),
        ),
        BlocProvider(
          create: (_) =>
              MarketingCubit(MarketingRepository())..loadOpportunities(token),
        ),
        BlocProvider(create: (_) => StaffCubit(AuthRepository())),
      ],
      child: const MainWrapper(),
    );
  }

  static Widget _buildInventoryScreen(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthSuccess) {
      return const LoginScreen();
    }

    final token = authState.user.token;
    return BlocProvider(
      create: (_) => InventoryCubit(ProductRepository())..getProducts(token),
      child: const InventoryScreen(),
    );
  }

  static Widget _buildCustomersScreen(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthSuccess) {
      return const LoginScreen();
    }

    final token = authState.user.token;
    return BlocProvider(
      create: (_) => CustomerCubit(CustomerRepository())..getCustomers(token),
      child: const CustomersScreen(),
    );
  }

  static Widget _buildAddCustomerScreen(BuildContext context) {
    return BlocProvider(
      create: (_) => AddCustomerCubit(CustomerRepository()),
      child: const AddCustomerScreen(),
    );
  }

  static Route<dynamic> _buildProductFormRoute(Object? args) {
    if (args is! ProductFormArgs) {
      return _invalidArgsRoute(Routes.productForm);
    }

    return MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: args.inventoryCubit),
          BlocProvider(create: (_) => AddProductCubit(ProductRepository())),
        ],
        child: AddProductScreen(productToEdit: args.product),
      ),
    );
  }

  static Route<dynamic> _buildCustomerDetailsRoute(Object? args) {
    if (args is! CustomerDetailsArgs) {
      return _invalidArgsRoute(Routes.customerDetails);
    }

    final customerRepository = CustomerRepository();

    return MaterialPageRoute(
      builder: (context) {
        final token = _tokenFromAuth(context);
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => CustomerDetailsCubit(customerRepository)
                ..getCustomerDetails(args.customerId, token),
            ),
            BlocProvider(
              create: (_) => CustomerStatsCubit(customerRepository)
                ..loadStats(args.customerId, token),
            ),
          ],
          child: CustomerDetailsScreen(
            customerId: args.customerId,
            customerName: args.customerName,
          ),
        );
      },
    );
  }

  static Route<dynamic> _buildOrderDetailsRoute(Object? args) {
    if (args is! OrderDetailsArgs) {
      return _invalidArgsRoute(Routes.orderDetails);
    }

    return MaterialPageRoute(
      builder: (context) {
        final token = _tokenFromAuth(context);
        return BlocProvider(
          create: (_) => OrderDetailsCubit(OrderRepository())
            ..getDetails(token, args.orderId),
          child: OrderDetailsScreen(orderId: args.orderId),
        );
      },
    );
  }

  static Widget _buildPosScreen(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthSuccess) {
      return const LoginScreen();
    }

    final token = authState.user.token;
    return BlocProvider(
      create: (_) => InventoryCubit(ProductRepository())..getProducts(token),
      child: const PosScreen(),
    );
  }

  static Widget _buildGrowthScreen(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthSuccess) {
      return const LoginScreen();
    }

    final token = authState.user.token;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              MarketingCubit(MarketingRepository())..loadOpportunities(token),
        ),
        BlocProvider(
          create: (_) =>
              DashboardCubit(DashboardRepository())..getStats(token),
        ),
      ],
      child: const GrowthPage(),
    );
  }

  static Widget _buildStaffManagementScreen(BuildContext context) {
    return BlocProvider(
      create: (_) => StaffCubit(AuthRepository()),
      child: const StaffManagementScreen(),
    );
  }

  static Widget _buildAddStaffScreen(BuildContext context) {
    return BlocProvider(
      create: (_) => StaffCubit(AuthRepository()),
      child: const AddStaffScreen(),
    );
  }

  static Route<dynamic> _buildVerificationRoute(Object? args) {
    if (args is! VerificationArgs) {
      return _invalidArgsRoute(Routes.verification);
    }

    return MaterialPageRoute(
      builder: (context) {
        if (args.staffCubit != null) {
          return BlocProvider.value(
            value: args.staffCubit!,
            child: VerificationScreen(
              email: args.email,
              mode: args.mode,
            ),
          );
        }
        return BlocProvider(
          create: (_) => StaffCubit(AuthRepository()),
          child: VerificationScreen(
            email: args.email,
            mode: args.mode,
          ),
        );
      },
    );
  }

  static Widget _buildFallbackScreen(String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation Error')),
      body: Center(child: Text(message)),
    );
  }

  static Route<dynamic> _invalidArgsRoute(String routeName) {
    return MaterialPageRoute(
      builder: (_) => _buildFallbackScreen(
        'Missing or invalid arguments for $routeName.',
      ),
    );
  }

  static Route<dynamic> _unknownRoute(String? routeName) {
    return MaterialPageRoute(
      builder: (_) => _buildFallbackScreen(
        'Route not found${routeName == null ? '' : ': $routeName'}.',
      ),
    );
  }

  static String _tokenFromAuth(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    return (authState is AuthSuccess) ? authState.user.token : '';
  }
}
