import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptUtil {
  static const String SECRET_KEY = 'purchas-crypto-key-0725'; // 使用您的密钥
  static const String FALLBACK_KEY = 'purchas-crypto-key-0725'; // 备用密钥设置为相同值

  static String encryptText(String text) {
    // 生成32字节的密钥
    final keyString = SECRET_KEY.isNotEmpty ? SECRET_KEY : FALLBACK_KEY;
    final keyBytes = sha256.convert(utf8.encode(keyString)).bytes;
    final key = encrypt.Key(Uint8List.fromList(keyBytes));

    // 使用固定的IV（16字节的0）
    final iv = encrypt.IV(Uint8List(16));

    // 创建AES加密器
    final encrypter = encrypt.Encrypter(
      encrypt.AES(
        key,
        mode: encrypt.AESMode.cbc,
        padding: 'PKCS7',
      ),
    );

    // 加密
    final encrypted = encrypter.encrypt(text, iv: iv);

    return encrypted.base64;
  }

  // 如果需要解密功能
  static String decryptText(String encryptedText) {
    final keyString = SECRET_KEY.isNotEmpty ? SECRET_KEY : FALLBACK_KEY;
    final keyBytes = sha256.convert(utf8.encode(keyString)).bytes;
    final key = encrypt.Key(Uint8List.fromList(keyBytes));

    final iv = encrypt.IV(Uint8List(16));

    final encrypter = encrypt.Encrypter(
      encrypt.AES(
        key,
        mode: encrypt.AESMode.cbc,
        padding: 'PKCS7',
      ),
    );

    final encrypted = encrypt.Encrypted.fromBase64(encryptedText);
    return encrypter.decrypt(encrypted, iv: iv);
  }
}
