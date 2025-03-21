import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChecklistService {
  final String apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'] ?? '';
  final String apiToken = dotenv.env['NEXT_PUBLIC_API_TOKEN'] ?? '';

  Future<Map<String, dynamic>?> getChecklist(String cardId) async {
    final Uri url = Uri.parse('https://api.trello.com/1/cards/$cardId?fields=idChecklists&key=$apiKey&token=$apiToken');
    final res = await http.get(url);

    if (res.statusCode == 200) return json.decode(res.body);
    return null;
  }

  Future<Map<String, dynamic>?> getChecklistDetails(String checklistId) async {
    final Uri url = Uri.parse('https://api.trello.com/1/checklists/$checklistId?key=$apiKey&token=$apiToken');
    final res = await http.get(url);

    if (res.statusCode == 200) return json.decode(res.body);
    return null;
  }

  Future<bool> createChecklist(String cardId, String name) async {
    final Uri url = Uri.parse('https://api.trello.com/1/checklists?name=$name&idCard=$cardId&key=$apiKey&token=$apiToken');
    final res = await http.post(url);
    return res.statusCode == 200;
  }

  Future<bool> updateChecklist(String checklistId, String newName) async {
    final Uri url = Uri.parse('https://api.trello.com/1/checklists/$checklistId?name=$newName&key=$apiKey&token=$apiToken');
    final res = await http.put(url);
    return res.statusCode == 200;
  }

  Future<bool> deleteChecklist(String checklistId) async {
    final Uri url = Uri.parse('https://api.trello.com/1/checklists/$checklistId?key=$apiKey&token=$apiToken');
    final res = await http.delete(url);
    return res.statusCode == 200;
  }
}
