import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

///Service Class
class WorkspaceService {
  static final String? _apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'];
  static final String? _apiToken = dotenv.env['NEXT_PUBLIC_API_TOKEN'];

  /// Récupère les workspaces d'un utilisateur
  static Future<List<dynamic>?> getAllWorkspaces(String userId) async {
    final String url = 'https://api.trello.com/1/members/$userId/organizations?key=$_apiKey&token=$_apiToken';

    try {
      final http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Convertit la réponse en liste JSON
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (error) {
      //print('❌ Erreur dans getAllWorkspaces : $error');
      return null;
    }
  }

  
}
