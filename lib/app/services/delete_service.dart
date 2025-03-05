// ignore_for_file: public_member_api_docs

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// API KEYS
final String apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'] ?? 'DEFAULT_KEY';
final String apiToken = dotenv.env['NEXT_PUBLIC_API_TOKEN'] ?? 'DEFAULT_TOKEN';

class DeleteService {
  static Future<bool> deleteCard(String cardId) async {
    final String url = 'https://api.trello.com/1/cards/$cardId?key=$apiKey&token=$apiToken';

    try {
      final http.Response response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        return true; // Succès
      } else {
        throw Exception('❌ Erreur API: ${response.statusCode}');
      }
    } catch (error) {
      // print('❌ Erreur lors de la suppression : $error');
      return false; // Échec
    }
  }
}
