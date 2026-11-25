import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/network/api_client.dart';
import 'core/services/photo_picker_service.dart';
import 'core/storage/token_storage.dart';
import 'features/admin/data/datasources/admin_local_datasource.dart';
import 'features/admin/data/repositories/admin_repository_impl.dart';
import 'features/admin/domain/repositories/admin_repository.dart';
import 'features/admin/domain/usecases/admin_usecases.dart';
import 'features/admin/presentation/cubit/admin_cubit.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/login.dart';
import 'features/auth/domain/usecases/logout.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/profile/data/datasources/profile_local_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/get_profile.dart';
import 'features/profile/domain/usecases/update_profile.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ---------- External ----------
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  // ---------- Core ----------
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl()));
  sl.registerLazySingleton<PhotoPickerService>(() => PhotoPickerServiceImpl());
  sl.registerLazySingleton<LocalStorage>(() => LocalStorageImpl(sl()));

  // ---------- Feature: Auth ----------
  _initAuth();

  // ---------- Feature: Profile ----------
  _initProfile();

  // ---------- Feature: Admin ----------
  _initAdmin();
}

void _initAdmin() {
  // Singleton so users created in this session stay in the mock list.
  sl.registerLazySingleton<AdminLocalDataSource>(() => AdminLocalDataSourceImpl());
  sl.registerLazySingleton<AdminRepository>(() => AdminRepositoryImpl(local: sl()));
  sl.registerLazySingleton(() => GetUsers(sl()));
  sl.registerLazySingleton(() => CreateUser(sl()));
  sl.registerLazySingleton(() => UpdateUser(sl()));
  sl.registerLazySingleton(() => ApproveDevice(sl()));
  sl.registerLazySingleton(() => SetUserDisabled(sl()));
  sl.registerLazySingleton(() => GetConfigSettings(sl()));
  sl.registerLazySingleton(() => UpdateConfigSetting(sl()));
  sl.registerLazySingleton(() => GetAuditLog(sl()));
  sl.registerFactory(() => AdminCubit(
        getUsers: sl(),
        createUser: sl(),
        updateUser: sl(),
        approveDevice: sl(),
        setUserDisabled: sl(),
        getConfigSettings: sl(),
        updateConfigSetting: sl(),
        getAuditLog: sl(),
      ));
}

void _initProfile() {
  sl.registerLazySingleton<ProfileLocalDataSource>(() => ProfileLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(local: sl()));
  sl.registerLazySingleton(() => GetProfile(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));
  sl.registerFactory(() => ProfileCubit(getProfile: sl(), updateProfile: sl()));
}

void _initAuth() {
  //Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remote: sl(), local: sl()));

  // Use cases
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));

  // Bloc (factory: new instance each time it's requested)
  sl.registerFactory(() => AuthBloc(login: sl(), logout: sl(), getCurrentUser: sl()));
}