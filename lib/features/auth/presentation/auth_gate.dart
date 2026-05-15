import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../customers/presentation/dashboard_page.dart';
import '../logic/auth_cubit.dart';
import '../logic/auth_state.dart';
import 'login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state.status == AuthStatus.initial ||
            state.status == AuthStatus.loading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state.status == AuthStatus.authenticated && state.session != null) {
          return const DashboardPage();
        }

        return LoginPage(
          errorMessage: state.errorMessage,
        );
      },
    );
  }
}
