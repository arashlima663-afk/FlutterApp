import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cryptography/cryptography.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_1/core/functions.dart';
import 'package:flutter_application_3/features/users/domain/model/user_model.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:sqflite/sqflite.dart';

class UsersRemoteDatasource {
  final Dio dio;

  UsersRemoteDatasource({required this.dio});

  Future<List<UserModel>> getUsers() async {
    var result = await dio.get('users');
    return (result.data['users'] as List)
        .map((e) => UserModel.fromJson(e))
        .toList();
  }
}

class IsConnectedRemoteDatasource {
  final Database db;
  final Dio dio;
  final X25519 x25519;
  final AesGcm aes;

  final InternetConnectionChecker internetConnectionChecker;

  IsConnectedRemoteDatasource({
    required this.internetConnectionChecker,
    required this.dio,
    required this.db,
  });

  Stream<String> isConnected() {
    return internetConnectionChecker.onStatusChange.map((status) {
      switch (status) {
        case InternetConnectionStatus.connected:
          return 'true';
        case InternetConnectionStatus.disconnected:
          return 'false';
        case InternetConnectionStatus.slow:
          return 'slow';
      }
    });
  }

  dynamic fetchKey() async {
    final List<int> hkdfNonce = generateHkdfNonce();
    final List<int> aesNonce = aes.newNonce();

    final SimpleKeyPair clientKeyPair = await x25519.newKeyPair();
    await Future.delayed(const Duration(milliseconds: 2000));
    final SimplePublicKey clientPublicKey = await clientKeyPair
        .extractPublicKey();
    final clientPublicKeybytes = clientPublicKey.bytes;

    String rndstr = randomstr();

    BaseOptions(
      headers: {
        'Content-Type': 'application/json',
        'ownerId': rndstr,
        'clientPublicKeybytes': clientPublicKeybytes,
        'hkdfNonce': hkdfNonce,
        'aesNonce': aesNonce,
        'Authorization': 'Bearer YOUR_TOKEN',
      },
    );
    final Response<dynamic> result = await dio.get('key');
    return 
  }
}
