// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GetMemberService {
  final String apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'] ?? 'DEFAULT_KEY';
  final String apiToken = dotenv.env['NEXT_PUBLIC_API_TOKEN'] ?? 'DEFAULT_TOKEN';

  /// 🔹 Récupère les informations d'un membre spécifique Trello
  Future<Map<String, dynamic>?> getMember(String memberId) async {
    final String url =
        'https://api.trello.com/1/members/$memberId?key=$apiKey&token=$apiToken';

    try {
      final http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // print('✅ Membre trouvé : ${data['fullName']}');
        return data;
      } else {
        // print('❌ Erreur API pour le membre $memberId : ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // print('❌ Erreur lors de la récupération du membre $memberId: $e');
      return null;
    }
  }

  /// 🔹 Récupère tous les membres d'un board Trello
  Future<List<Map<String, dynamic>>> getAllMembers(String boardId) async {
    final String url =
        'https://api.trello.com/1/boards/$boardId/members?key=$apiKey&token=$apiToken';
    final List<Map<String, dynamic>> members = <Map<String, dynamic>>[];

    try {
      final http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        for (final member in data) {
          members.add(<String, dynamic>{
            'id': member['id'],
            'fullName': member['fullName'],
            'username': member['username'],
          });
        }
        // print('✅ ${members.length} membres récupérés pour le board $boardId');
      } else {
        // print('❌ Erreur API pour le board $boardId : ${response.statusCode}');
      }
    } catch (e) {
      // print('❌ Erreur lors de la récupération des membres du board $boardId: $e');
    }

    return members;
  }
}
