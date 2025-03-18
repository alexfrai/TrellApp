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
      // print('❌ Erreur lors de la création de la checklist : $error');
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
      // print('❌ Erreur lors de la récupération des checklists : $error');
      return []; // Retourne une liste vide en cas d'erreur
    }
  }

  Future<Map<String, dynamic>?> getChecklistDetails(String checklistId) async {
    final String url =
        'https://api.trello.com/1/checklists/$checklistId?key=$apiKey&token=$apiToken';

    try {
      final response = await http.put(Uri.parse(url));

      if (response.statusCode == 200) {
        // print("✅ Détails de la checklist $checklistId récupérés !");
        return jsonDecode(response.body);
      } else {
        // print("❌ Erreur API: ${response.statusCode}, ${response.body}");
        return null;
      }
    } catch (error) {
      // print("❌ Erreur lors de la récupération de la checklist $checklistId : $error");
      return null;
    }
  }

    Future<bool> updateChecklist(String checklistId, String newName) async {
  final String url =
      'https://api.trello.com/1/checklists/$checklistId?key=$apiKey&token=$apiToken';

  try {
    final http.Response response = await http.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'name': newName, // 🔹 Paramètre conforme à l'API Trello
      }),
    );

    if (response.statusCode == 200) {
      // print("✅ Checklist mise à jour avec succès !");
      return true;
    } else {
      // print("❌ Erreur API: ${response.statusCode} - ${response.body}");
      return false;
    }
  } catch (error) {
    // print("❌ Exception lors de la mise à jour de la checklist : $error");
    return false;
  }
}
}
