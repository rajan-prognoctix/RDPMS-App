import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/auth/jurisdiction.dart';
import 'core/constants/app_constants.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
import 'injection_container.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthBloc>()..add(const CurrentUserRequested())),
        BlocProvider(create: (_) => sl<ProfileCubit>()..load()),
      ],
      // Every screen's Zone / Division / Station pickers follow the signed-in
      // user's jurisdiction (§11.6, Annex G note 2).
      child: BlocSelector<AuthBloc, AuthState, Jurisdiction>(
        selector: (s) => Jurisdiction.forUser(s.role, s.currentUser?.data?.jurisdiction),
        builder: (_, jurisdiction) => JurisdictionScope(
          jurisdiction: jurisdiction,
          child: MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            routerConfig: appRouter,
          ),
        ),
      ),
    );
  }
}
