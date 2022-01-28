import 'dart:convert';
import 'package:crypto/crypto.dart';

class CryptoHelper {
  static String generateMd5(String value) {
    final digest = md5.convert(utf8.encode(value));
    return digest.toString();
  }
}
