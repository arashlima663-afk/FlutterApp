import 'package:flutter_application_1/core/api/api_client.dart';
import 'package:get_it/get_it.dart';

var getIt = GetIt.instance;

void setup() {
  getIt.registerSingleton(ApiClient());
  getIt.registerSingleton(getIt<ApiClient>().getDio());
  getIt.registerSingleton(getIt<ApiClient>().getChecker());
  getIt.registerSingleton(getIt<ApiClient>().getSql());
  getIt.registerSingleton(getIt<ApiClient>().getX25519());
  getIt.registerSingleton(getIt<ApiClient>().getX25519());
}
