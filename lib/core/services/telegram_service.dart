import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:printing/printing.dart';
import 'package:http_parser/http_parser.dart';

class TelegramService {
  static const String _telegramEnableKey = 'telegram_backup_enabled';
  static const String _telegramTokenKey = 'telegram_bot_token';
  static const String _telegramChatIdKey = 'telegram_chat_id';

  /// Saves the Telegram configuration.
  static Future<void> saveConfig({
    required bool enabled,
    required String token,
    required String chatId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_telegramEnableKey, enabled);
    await prefs.setString(_telegramTokenKey, token);
    await prefs.setString(_telegramChatIdKey, chatId);
  }

  /// Retrieves the current Telegram configuration.
  static Future<Map<String, dynamic>> getConfig() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'enabled': prefs.getBool(_telegramEnableKey) ?? false,
      'token': prefs.getString(_telegramTokenKey) ?? '',
      'chatId': prefs.getString(_telegramChatIdKey) ?? '',
    };
  }

  /// Sends the receipt as an image to the configured Telegram bot.
  /// Converts the [pdfBytes] to a PNG image before sending.
  /// Runs in a background isolate/future.
  static Future<void> sendReceiptBackup(Uint8List pdfBytes, String receiptId) async {
    try {
      final config = await getConfig();
      final bool isEnabled = config['enabled'];
      final String token = config['token'];
      final String chatId = config['chatId'];

      if (!isEnabled || token.isEmpty || chatId.isEmpty) {
        return; // Backup not enabled or configured
      }

      // 1. Rasterize the first page of the PDF to a PNG image
      Uint8List? pngBytes;
      await for (final page in Printing.raster(pdfBytes, pages: [0], dpi: 200)) {
        pngBytes = await page.toPng();
        break; // Only need the first page for the receipt
      }

      if (pngBytes == null) {
        throw Exception('Failed to rasterize PDF to image');
      }

      // 2. Send to Telegram using multipart request
      final uri = Uri.parse('https://api.telegram.org/bot$token/sendPhoto');
      final request = http.MultipartRequest('POST', uri)
        ..fields['chat_id'] = chatId
        ..fields['caption'] = 'Backup Receipt #$receiptId'
        ..files.add(http.MultipartFile.fromBytes(
          'photo',
          pngBytes,
          filename: 'receipt_$receiptId.png',
          contentType: MediaType('image', 'png'),
        ));

      final response = await request.send();
      if (response.statusCode != 200) {
        final respStr = await response.stream.bytesToString();
        print('Telegram Backup Failed: ${response.statusCode} - $respStr');
      } else {
        print('Telegram Backup Success for Receipt #$receiptId');
      }
    } catch (e) {
      print('Error sending telegram backup: $e');
    }
  }
}
