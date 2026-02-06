import 'dart:math';

String randomstr({int length = 7}) {
  const String chars =
      '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!"#\$%&\'()*+,-./:;<=>?[\\]^_`{|}~ ';
  Random random = Random();

  final randomString = String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ),
  );
  return randomString;
}

List<int> generateHkdfNonce() {
  final List<int> hkdfNonce = [];

  for (int i = 0; i < 16; i++) {
    hkdfNonce.add(Random.secure().nextInt(256));
  }
  return hkdfNonce;
}
