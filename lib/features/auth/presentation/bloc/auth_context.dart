import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/user_role.dart';
import '../../domain/entities/user.dart';
import 'auth_bloc.dart';

/// Shortcuts for role-based UI (§11.6, Annex E §1: "UI template may be
/// filtered to show only relevant icons to different users as per their role").
extension AuthContext on BuildContext {
  /// The signed-in user's role; rebuilds the widget when it changes.
  /// Call only inside `build`.
  UserRole watchRole() => select((AuthBloc b) => b.state.role);

  /// The signed-in user; rebuilds the widget when it changes. Call only inside `build`.
  User? watchUser() => select((AuthBloc b) => b.state.currentUser);
}
