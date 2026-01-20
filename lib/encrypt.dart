import 'dart:convert';
import 'package:cryptography/cryptography.dart';

Future<Map<String, String>> encryptForServer({
  required List<int> message,
  required String serverPubKeyString,
}) async {
  final aes = AesGcm.with256bits();
  final x25519 = X25519();
  final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);

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
