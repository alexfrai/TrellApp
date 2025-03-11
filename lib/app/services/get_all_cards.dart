// ignore_for_file: public_member_api_docs, always_specify_types

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Récupération des clés API depuis le fichier .env
final String apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'] ?? 'DEFAULT_KEY';
final String apiToken = dotenv.env['NEXT_PUBLIC_API_TOKEN'] ?? 'DEFAULT_TOKEN';

class CardService {
  /// Récupère toutes les cartes pour une liste de listes Trello
  static Future<List<Map<String, dynamic>>> getAllCards(List<dynamic> lists) async {
    final List<Map<String, dynamic>> allCards = [];

    for (final list in lists) {
      final String listId = list['id'];
      final String url = 'https://api.trello.com/1/lists/$listId/cards?key=$apiKey&token=$apiToken';

      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          for (final card in data) {
            allCards.add({
              'listId': listId,
              'id': card['id'],
              'name': card['name'],
              'desc': card['desc'],
            });
          }
        } else {
          // print('Erreur API pour la liste $listId : ${response.statusCode}');
        }
      } catch (e) {
        // print('Erreur lors de la récupération des cartes pour la liste $listId: $e');
      }
    }

    return allCards;
  }
}
