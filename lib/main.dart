import 'package:flowly/core/app_theme.dart';
import 'package:flowly/data/repositories/settings_repository.dart';
import 'package:flowly/core/routing/app_router.dart';
import 'package:flowly/logic/cubits/auth_cubit.dart';
import 'package:flowly/logic/cubits/cart_cubit.dart';
import 'package:flowly/logic/cubits/settings_cubit.dart';
import 'package:flowly/logic/cubits/theme_cubit.dart';
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
            initialRoute: Routes.root,
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}
