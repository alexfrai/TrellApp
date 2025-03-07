import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CreateMemberCard {
  final String apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'] ?? 'DEFAULT_KEY';
  final String apiToken = dotenv.env['NEXT_PUBLIC_API_TOKEN'] ?? 'DEFAULT_TOKEN';

  Future<bool> _isMemberAlreadyAssigned(String cardId, String memberId) async {
    final String url =
        'https://api.trello.com/1/cards/$cardId/members?key=$apiKey&token=$apiToken';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> members = json.decode(response.body);
        return members.any((member) => member['id'] == memberId);
      } else {
        print('❌ Erreur API (GET membres): ${response.statusCode}');
        return false;
      }
    } catch (error) {
      print('❌ Erreur lors de la récupération des membres: $error');
      return false;
    }
  }

  Future<void> assignMemberToCard(String cardId, String memberId) async {
    if (await _isMemberAlreadyAssigned(cardId, memberId)) {
      print('⚠️ Le membre est déjà assigné à cette carte.');
      return;
    }

    final String url =
        'https://api.trello.com/1/cards/$cardId/idMembers?key=$apiKey&token=$apiToken';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {'value': memberId},
      );

      if (response.statusCode == 200) {
        print('✅ Membre assigné avec succès à la carte !');
      } else {
        throw Exception('❌ Erreur API: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      print('❌ Erreur lors de l\'assignation du membre : $error');
    }
  }
}
