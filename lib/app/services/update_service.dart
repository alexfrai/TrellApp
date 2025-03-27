// ignore_for_file: public_member_api_docs

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// API KEYS
final String apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'] ?? 'DEFAULT_KEY';
final String apiToken = dotenv.env['NEXT_PUBLIC_API_TOKEN'] ?? 'DEFAULT_TOKEN';

class UpdateService {
  static Future<bool> updateCardFields(String cardId, Map<String, String> fieldsToUpdate) async {
  final String url = 'https://api.trello.com/1/cards/$cardId?key=$apiKey&token=$apiToken';

  try {
    final http.Response response = await http.put(
      Uri.parse(url),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(fieldsToUpdate),
    );

    return response.statusCode == 200;
  } catch (error) {
    return false;
  }
}

}
