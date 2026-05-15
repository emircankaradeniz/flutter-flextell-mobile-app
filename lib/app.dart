import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/account/data/account_repository.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/data/token_storage.dart';
import 'features/auth/logic/auth_cubit.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'features/customers/data/customers_repository.dart';

class FlextellApp extends StatelessWidget {
  const FlextellApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tokenStorage = TokenStorage();
    final authRepository = AuthRepository(tokenStorage: tokenStorage);
    final accountRepository = AccountRepository(authRepository: authRepository);
    final customersRepository =
        CustomersRepository(authRepository: authRepository);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<TokenStorage>.value(value: tokenStorage),
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<AccountRepository>.value(value: accountRepository),
        RepositoryProvider<CustomersRepository>.value(
            value: customersRepository),
      ],
      child: BlocProvider(
        create: (_) => AuthCubit(authRepository)..hydrate(),
        child: MaterialApp(
          title: 'Flextell Case Study',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2563EB),
            ),
            scaffoldBackgroundColor: const Color(0xFFF6F8FB),
            appBarTheme: const AppBarTheme(
              centerTitle: false,
              backgroundColor: Color(0xFFF6F8FB),
              surfaceTintColor: Color(0xFFF6F8FB),
              elevation: 0,
            ),
          ),
          home: const AuthGate(),
        ),
      ),
    );
  }
}
