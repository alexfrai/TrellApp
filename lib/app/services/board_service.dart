// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>?> getAllWorkspaces(
  String userId,
  String apiKey,
  String apiToken,
) async {
  final String url =
      'https://api.trello.com/1/members/$userId/organizations?key=$apiKey&token=$apiToken';

  try {
    final http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Retourne la liste des workspaces
    } else {
      throw Exception(
        'Erreur HTTP: ${response.statusCode} ${response.reasonPhrase}',
      );
    }
  } catch (error) {
    // print("❌ Erreur dans getAllWorkspaces : $error");
    return null;
  }
}
