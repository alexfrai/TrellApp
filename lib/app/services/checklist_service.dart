// ignore_for_file: public_member_api_docs, always_specify_types

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChecklistService {
  final String apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'] ?? 'DEFAULT_KEY';
  final String apiToken =
      dotenv.env['NEXT_PUBLIC_API_TOKEN'] ?? 'DEFAULT_TOKEN';

  Future<bool> createChecklist(String cardId, String name) async {
    final String url =
        'https://api.trello.com/1/checklists?idCard=$cardId&key=$apiKey&token=$apiToken';
    try {
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"idCard": cardId, "name": name}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true; // Succès
      } else {
        throw Exception(
          '❌ Erreur API: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (error) {
      print('❌ Erreur lors de la création de la checklist : $error');
      return false; // Échec
    }
  }

  Future getChecklist(String cardId) async {
    final String url =
        'https://api.trello.com/1/cards/$cardId?key=$apiKey&token=$apiToken';
    try {
      final http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Retourne les checklists
      } else {
        throw Exception(
          '❌ Erreur API: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (error) {
      print('❌ Erreur lors de la récupération des checklists : $error');
      return []; // Retourne une liste vide en cas d'erreur
    }
  }
}
