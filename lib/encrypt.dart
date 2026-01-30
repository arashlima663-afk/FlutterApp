import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_application_1/encrypt.dart';
import 'package:flutter_application_1/Picture.dart';
import 'package:flutter_application_1/flags.dart';
import 'dart:typed_data';
import 'dart:math';

List<int> m = [12, 13, 14, 15];
final controller = StreamController<List<int>>();

Stream<List<int>> encrypt({
  required Stream<List<int>> stream,
  String serverPubKeyString = '6INp7B55Fe3EGZEH9TZsIFGzrItNIODSl88uHaVvgSE=',
}) async* {
  final aes = AesGcm.with256bits();
  final x25519 = X25519();

  // 1️⃣ Generate client ephemeral key pair
  final clientKeyPair = await x25519.newKeyPair();
  final clientPublicKey = await clientKeyPair.extractPublicKey();

  // 2️⃣ Decode server public key
  final serverPubKeyBytes = base64Decode(serverPubKeyString);
  final serverPublicKey = SimplePublicKey(
    serverPubKeyBytes,
    type: KeyPairType.x25519,
  );

  // 3️⃣ Compute shared secret
  final sharedSecret = await x25519.sharedSecretKey(
    keyPair: clientKeyPair,
    remotePublicKey: serverPublicKey,
  );

  // 4️⃣ Derive key for sign the Client AES
  final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
  final random = Random.secure();
  final hkdfNonce = <int>[];
  for (int i = 0; i < 16; i++) {
    hkdfNonce.add(random.nextInt(256));
  }
  final key = await hkdf.deriveKey(secretKey: sharedSecret, nonce: hkdfNonce);

  // 5️⃣ Encrypt
  Mac? mac;
  final aesNonce = aes.newNonce();
  final secretBox = aes.encryptStream(
    stream,
    secretKey: key,
    nonce: aesNonce,
    onMac: (m) {
      mac = m;
    },
  );
  print({
    "client_pub": base64Encode(clientPublicKey.bytes),
    'shared-secret': base64Encode(await sharedSecret.extractBytes()),
    "hkdfNonce": base64Encode(hkdfNonce),
    "aes": base64Encode(key.bytes),
    "aesNonce": base64Encode(aesNonce),
    // "ciphertext": base64Encode(secretBox.cipherText),
    "mac": base64Encode(mac!.bytes),
  });
  yield* secretBox;
}

/// Sends a stream of bytes to the server using StreamedRequest
Future<http.StreamedResponse> upload({
  required Stream<List<int>> byteStream,
}) async {
  final request = http.StreamedRequest(
    'POST',
    Uri.parse('http://localhost:5000/data'),
  );
  request.headers['title'] = 'Upload';

  // Pipe the byteStream into the request's sink
  await for (final chunk in byteStream) {
    request.sink.add(chunk);
  }

  // Close the sink to finish sending
  request.sink.close();

  // Send the request and get the response
  final response = await request.send();
  return response;
}

String generateRandomString(int length) {
  const String chars =
      '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!"#\$%&\'()*+,-./:;<=>?[\\]^_`{|}~ ';
  Random random = Random();

  return String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ),
  );
}
