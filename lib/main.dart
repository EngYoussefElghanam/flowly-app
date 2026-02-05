import 'package:flowly/core/app_theme.dart';
import 'package:flowly/data/repositories/customer_repository.dart';
import 'package:flowly/data/repositories/marketing_repository.dart';
import 'package:flowly/data/repositories/settings_repository.dart';
import 'package:flowly/logic/cubits/auth_cubit.dart';
import 'package:flowly/logic/cubits/cart_cubit.dart';
import 'package:flowly/logic/cubits/customer_stats_cubit.dart';
import 'package:flowly/logic/cubits/marketing_cubit.dart';
import 'package:flowly/logic/cubits/settings_cubit.dart';
import 'package:flowly/logic/cubits/staff_cubit.dart';
import 'package:flowly/logic/cubits/theme_cubit.dart';
import 'package:flowly/presentation/screens/login_screen.dart';
import 'package:flowly/presentation/screens/main_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'data/repositories/auth_repository.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(AuthRepository())..checkStatus(),
        ),
        BlocProvider(create: (context) => ThemeCubit()),
        BlocProvider(create: (context) => CartCubit()),
        BlocProvider(create: (context) => StaffCubit(AuthRepository())),
        BlocProvider(
          create: (context) => CustomerStatsCubit(CustomerRepository()),
        ),
        BlocProvider(
          create: (context) => MarketingCubit(MarketingRepository()),
          child: Container(),
        ),
        BlocProvider(create: (_) => SettingsCubit(SettingsRepository())),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flowly Seller',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state,
            home: const AppNavigator(),
          );
        },
      ),
    );
  }
}

class AppNavigator extends StatelessWidget {
  const AppNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(body: CircularProgressIndicator.adaptive());
        } else if (state is AuthSuccess) {
          return const MainWrapper();
        }
        return const LoginScreen();
      },
    );
  }
}
