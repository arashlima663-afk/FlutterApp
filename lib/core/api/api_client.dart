import 'package:cryptography/cryptography.dart';
import 'package:dio/dio.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// create an class with method to get instances
class ApiClient {
  Dio getDio() {
    Dio dio = Dio();
    dio.options.baseUrl = 'https://dummyjson.com/';

    return dio;
  }

  InternetConnectionChecker getChecker() {
    InternetConnectionChecker internetConnectionChecker =
        InternetConnectionChecker.createInstance(
          checkInterval: const Duration(seconds: 5),

          addresses: [
            AddressCheckOption(uri: Uri.parse('https://www.google.com')),
            AddressCheckOption(uri: Uri.parse('https://www.yahoo.com')),
          ],

          slowConnectionConfig: SlowConnectionConfig(
            enableToCheckForSlowConnection: true,
            slowConnectionThreshold: const Duration(milliseconds: 2000),
          ),
          requireAllAddressesToRespond: true,
        );
    return internetConnectionChecker;
  }

  Future<Database> getSql() async {
    Database db = await openDatabase(
      version: 1,
      join(await getDatabasesPath(), 'info_database.db'),
    );
    return db;
  }

  X25519 getX25519() {
    final X25519 x25519 = X25519();

    return x25519;
  }

  AesGcm getAes() {
    final aes = AesGcm.with256bits();

    return aes;
  }
}
