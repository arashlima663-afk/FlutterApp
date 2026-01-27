import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:io';

Future<Map<String, dynamic>> encryptForServer({
  required List<int> message,
  required String serverPubKeyString,
  required SimpleKeyPair clientKeyPair,
}) async {
  final aes = AesGcm.with256bits();
  final x25519 = X25519();
  final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);

  // 1️⃣ Generate client ephemeral key pair
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

  // 4️⃣ Derive AES key (NO salt unless server also uses it)
  final aesKey = await hkdf.deriveKey(secretKey: sharedSecret);

  // 5️⃣ Encrypt
  final nonce = aes.newNonce();
  final secretBox = await aes.encrypt(message, secretKey: aesKey, nonce: nonce);

  // 6️⃣ Return payload for server
  return {
    "client_pub": base64Encode(clientPublicKey.bytes),
    "nonce": base64Encode(nonce),
    "ciphertext": base64Encode(secretBox.cipherText),
    "tag": base64Encode(secretBox.mac.bytes),
  };
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

Future<void> upload(Uint8List value) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('http://localhost:5000/data'),
  );

  request.fields['title'] = 'title';

  request.files.add(
    http.MultipartFile.fromBytes(
      'img', // must match FastAPI parameter
      value, // raw bytes
      filename: 'data.bin',
    ),
  );

  var response = await request.send();

  final resBytes = await response.stream.toBytes();
  final result = utf8.decode(resBytes);

  print(result);
}
