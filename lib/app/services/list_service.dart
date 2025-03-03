import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ListService {
  // Utilisation de flutter_dotenv pour charger les variables d'environnement
  static String? API_KEY = dotenv.env['NEXT_PUBLIC_API_KEY'];
  static String? API_TOKEN = dotenv.env['NEXT_PUBLIC_API_TOKEN'];
  static const String baseUrl = "https://api.trello.com/1";




  /*
  Effectue une requête fetch avec une limite de 5s  
  */
  static Future<http.Response> fetchWithTimeout(String url, {Map<String, String>? headers, Duration timeout = const Duration(seconds: 5)}) async {
    try {
      final response = await http.get(Uri.parse(url), headers: headers).timeout(timeout);
      return response;
    } catch (e) {
      throw Exception("Request timeout or error: $e");
    }
  }
  
  /*
  Retourne les listes présentes dans un board
  */
  static Future<List<dynamic>> getList(String Board_ID) async {
    // Vérifie que les variables d'environnement sont bien chargées
    if (API_KEY == null || API_TOKEN == null) {
      throw Exception("API_KEY ou API_TOKEN non définis dans .env");
    }

    final url = "$baseUrl/boards/$Board_ID/lists?key=$API_KEY&token=$API_TOKEN";
    final response = await fetchWithTimeout(url);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur lors de la récupération des listes : ${response.statusCode}");
    }
  }
  static Future<List<dynamic>> CreateList(String Board_ID, String name) async {
    // Vérifie que les variables d'environnement sont bien chargées
    if (API_KEY == null || API_TOKEN == null) {
      throw Exception("API_KEY ou API_TOKEN non définis dans .env");
    }

    final url = "$baseUrl/lists?name=$name&idBoard=$Board_ID&key=$API_KEY&token=$API_TOKEN";
    final response = await fetchWithTimeout(url);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur lors de la création des listes : ${response.statusCode}");
    }
  }
}
