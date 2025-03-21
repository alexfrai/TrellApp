import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CheckItemService {
  final String apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'] ?? '';
  final String apiToken = dotenv.env['NEXT_PUBLIC_API_TOKEN'] ?? '';

  Future<List<Map<String, dynamic>>> getCheckItems(String checklistId) async {
    final Uri url = Uri.parse('https://api.trello.com/1/checklists/$checklistId/checkItems?key=$apiKey&token=$apiToken');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(res.body));
    } else {
      return [];
    }
  }

  Future<bool> createCheckItem(String checklistId, String name) async {
    final Uri url = Uri.parse('https://api.trello.com/1/checklists/$checklistId/checkItems?name=$name&pos=bottom&checked=false&key=$apiKey&token=$apiToken');
    final res = await http.post(url);
    return res.statusCode == 200;
  }

  Future<bool> updateCheckItem(String cardId, String checkItemId, String newName, bool checked) async {
    final Uri url = Uri.parse('https://api.trello.com/1/cards/$cardId/checkItem/$checkItemId?state=${checked ? 'complete' : 'incomplete'}&key=$apiKey&token=$apiToken');
    final res = await http.put(url);
    return res.statusCode == 200;
  }

  Future<bool> deleteCheckItem(String checklistId, String checkItemId) async {
    final Uri url = Uri.parse('https://api.trello.com/1/checklists/$checklistId/checkItems/$checkItemId?key=$apiKey&token=$apiToken');
    final res = await http.delete(url);
    return res.statusCode == 200;
  }
}
