import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ListService {
  // Utilisation de flutter_dotenv pour charger les variables d'environnement
  static String? API_KEY = dotenv.env['NEXT_PUBLIC_API_KEY'];
  static String? API_TOKEN = dotenv.env['NEXT_PUBLIC_API_TOKEN'];
  static const String baseUrl = 'https://api.trello.com/1';


  ///Effectue une requête fetch avec une limite de 5s 
  static Future<http.Response> fetchWithTimeout(String url, {Map<String, String>? headers, Duration timeout = const Duration(seconds: 5)}) async {
    try {
      final http.Response response = await http.get(Uri.parse(url), headers: headers).timeout(timeout);
      return response;
    } catch (e) {
      throw Exception('Request timeout or error: $e');
    }
  }
  
  ///Retourne les listes présentes dans un board
  ///\n @var Board_Id
  static Future<List<dynamic>> getList(String boardId) async {
    // Vérifie que les variables d'environnement sont bien chargées
    if (API_KEY == null || API_TOKEN == null) {
      throw Exception('API_KEY ou API_TOKEN non définis dans .env');
    }

    final String url = '$baseUrl/boards/$boardId/lists?key=$API_KEY&token=$API_TOKEN';
    final http.Response response = await fetchWithTimeout(url);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération des listes : ${response.statusCode}');
    }
  }

  /// Request API Create list
  /// @var Board_ID, @var name
  static Future<dynamic> createList(String name, String boardId) async {
  print('Board ID: $boardId');
  try {
    final Uri url = Uri.parse(
      '$baseUrl/lists?name=${Uri.encodeComponent(name)}&idBoard=${Uri.encodeComponent(boardId)}&key=$API_KEY&token=$API_TOKEN',
    );

    print('url: $url');

    // Type of request: POST
    final http.Response response = await http.post(url);

    // Check for success
    if (response.statusCode != 200) {
      throw Exception('Erreur ${response.statusCode}: ${response.body}');
    }
    return jsonDecode(response.body);
  } catch (error) {
    rethrow; // Rethrow the error so that it can be caught in the UI
  }
}

}
