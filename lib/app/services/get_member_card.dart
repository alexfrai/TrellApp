import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GetMemberCardService {
  final String apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'] ?? 'DEFAULT_KEY';
  final String apiToken = dotenv.env['NEXT_PUBLIC_API_TOKEN'] ?? 'DEFAULT_TOKEN';

  Future<List<Map<String, dynamic>>> getMembersCard(String cardId) async {
    final String url = 'https://api.trello.com/1/cards/$cardId/members?fields=username&key=$apiKey&token=$apiToken';

    try {
      final http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((member) => {
          'id': member['id'],
          'username': member['username'],
        }).toList();
      } else {
        print('Erreur API: ${response.statusCode}');
        return [];
      }
    } catch (error) {
      print('Erreur lors de la récupération des membres: $error');
      return [];
    }
  }
}
