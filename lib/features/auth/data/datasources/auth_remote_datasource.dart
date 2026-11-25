import 'package:rdpms_app/features/auth/data/models/login_request_model.dart';
import 'package:rdpms_app/features/auth/data/models/login_response_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login({required LoginRequestModel request});
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient client;
  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<LoginResponseModel> login({required LoginRequestModel request}) async {
    /*final data = await client.post(ApiEndpoints.login, data: request);
    return LoginResponseModel.fromJson(data as Map<String, dynamic>);*/
    try {
      await client.post(ApiEndpoints.login, data: request);
    } on Exception {}
    return LoginResponseModel.mock(userId: request.userId, password: request.password);
  }

  @override
  Future<void> logout() => client.post(ApiEndpoints.logout);
}
