import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

///List pour les list
class ListService {
  // Utilisation de flutter_dotenv pour charger les variables d'environnement
  ///Clé API
  static String? apikey = dotenv.env['NEXT_PUBLIC_API_KEY'];
  ///Token API
  static String? apitoken = dotenv.env['NEXT_PUBLIC_API_TOKEN'];
  ///URL Requetes api
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
  ///@var String Board_Id
  static Future<List<dynamic>> getList(String boardId) async {
    // Vérifie que les variables d'environnement sont bien chargées
    if (apikey == null || apitoken == null) {
      throw Exception('API_KEY ou API_TOKEN non définis dans .env');
    }

    final String url = '$baseUrl/boards/$boardId/lists?key=$apikey&token=$apitoken';
    final http.Response response = await fetchWithTimeout(url);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération des listes : ${response.statusCode}');
    }
  }

  /// Request API Create list
  /// @var String Board_ID, @var String name
  static Future<dynamic> createList(String name, String boardId) async {
    try {
      final Uri url = Uri.parse(
        //Uri.encodeComponent sert pour les caractères spéciaux comme /, %, $ ...
        '$baseUrl/lists?name=${Uri.encodeComponent(name)}&idBoard=${Uri.encodeComponent(boardId)}&key=$apikey&token=$apitoken',
      );
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
  ///Change le nom d'une liste
  ///@var String idist, @var String newname
  static Future<dynamic> updateListName(String idlist, String newname) async {  //A utilisé dans GetOneList
    try {
      final Uri url = Uri.parse(
        '$baseUrl/lists?$idlist?name=${Uri.encodeComponent(newname)}&key=$apikey&token=$apitoken',
      );
      // Type of request: POST
      final http.Response response = await http.post(url);

      // Check for success
      if (response.statusCode != 200) {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
      return jsonDecode(response.body);
    } catch (error) {
      rethrow;
    }
  }

///Modifie la position d'une liste
///@var String idlist, @var String pos: [top / bottom / float number]
static Future<dynamic> updateListPos(String idlist, String newpos) async {
  try {
    final Uri url = Uri.parse(
      '$baseUrl/lists/$idlist?key=$apikey&token=$apitoken',
    );

    final http.Response response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'pos': newpos}), // Envoi du paramètre pos correctement
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur ${response.statusCode}: ${response.body}');
    }

    return jsonDecode(response.body);
  } catch (error) {
    rethrow;
  }
}

}
