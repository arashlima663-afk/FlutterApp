import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Info {
  final String? ownerId;
  final List<int>? clientPublicKeybytes;
  final List<int>? hkdfNonce;
  final List<int>? aesNonce;

  final String? pubKey;
  final String? jwt;

  Info({
    this.ownerId,
    this.clientPublicKeybytes,
    this.hkdfNonce,
    this.aesNonce,
    this.pubKey,
    this.jwt,
  });

  Map<String, Object?> toJson() {
    return {
      'ownerId': ownerId,
      'clientPublicKeybytes': clientPublicKeybytes,
      'hkdfNonce': hkdfNonce,
      'aesNonce': aesNonce,
      'pubKey': pubKey,
      'jwt': jwt,
    };
  }

  factory Info.fromJson(Map<String, dynamic> json) {
    return Info(
      ownerId: json['ownerId'],
      clientPublicKeybytes: json['clientPublicKeybytes'],
      hkdfNonce: json['hkdfNonce'],
      aesNonce: json['aesNonce'],
      pubKey: json['pubKey'],
      jwt: json['jwt'],
    );
  }

  @override
  String toString() {
    return 'Info('
        'ownerId: $ownerId, '
        'clientPublicKeybytes: $clientPublicKeybytes, '
        'hkdfNonce: $hkdfNonce, '
        'aesNonce: $aesNonce, '
        'pubKey: $pubKey, '
        'jwt: $jwt'
        ')';
  }
}
