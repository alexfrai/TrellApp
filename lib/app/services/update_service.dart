// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// API KEYS
final String apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'] ?? 'DEFAULT_KEY';
final String apiToken = dotenv.env['NEXT_PUBLIC_API_TOKEN'] ?? 'DEFAULT_TOKEN';

class UpdateService {
  static Future<bool> updateCard(String cardId, String newName) async {
    final String url = 'https://api.trello.com/1/cards/$cardId?key=$apiKey&token=$apiToken';

    try {
      final http.Response response = await http.put(
        Uri.parse(url),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{'name': newName}),
      );

      if (response.statusCode == 200) {
        return true; // Succès
      } else {
        throw Exception('❌ Erreur API: ${response.statusCode}');
      }
    } catch (error) {
      // print('❌ Erreur lors de la mise à jour : $error');
      return false; // Échec
    }
  }
}
