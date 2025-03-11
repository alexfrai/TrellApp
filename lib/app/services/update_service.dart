import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API KEYS
final String apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'] ?? 'DEFAULT_KEY';
final String apiToken = dotenv.env['NEXT_PUBLIC_API_TOKEN'] ?? 'DEFAULT_TOKEN';

class UpdateService {
  /// 🔹 Met à jour UNIQUEMENT la description d'une carte
  static Future<bool> updateCardDescription(String cardId, String description) async {
    final String url = 'https://api.trello.com/1/cards/$cardId?key=$apiKey&token=$apiToken';

    try {
      final http.Response response = await http.put(
        Uri.parse(url),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{'desc': description}), // ✅ Met à jour uniquement `desc`
      );

      if (response.statusCode == 200) {
        print("✅ Description mise à jour avec succès !");
        return true;
      } else {
        print("❌ Erreur API: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (error) {
      print("❌ Exception lors de la mise à jour de la description : $error");
      return false;
    }
  }

  static Future<bool> updateCardName(String cardId, String name) async {
    final String url = 'https://api.trello.com/1/cards/$cardId?key=$apiKey&token=$apiToken';

    try {
      final http.Response response = await http.put(
        Uri.parse(url),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{'name': name}), // ✅ Met à jour uniquement `desc`
      );

      if (response.statusCode == 200) {
        print("✅ Description mise à jour avec succès !");
        return true;
      } else {
        print("❌ Erreur API: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (error) {
      print("❌ Exception lors de la mise à jour de la description : $error");
      return false;
    }
  }
}
