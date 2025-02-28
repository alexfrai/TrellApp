import 'dart:convert';
import 'package:http/http.dart' as http;

class ListService {
  static const API_KEY = String.fromEnvironment('NEXT_PUBLIC_API_KEY');
  static const API_TOKEN = String.fromEnvironment('NEXT_PUBLIC_API_TOKEN');
  static const String baseUrl = "https://api.trello.com/1";


  /*
  Créé le 28/02 Par Armand BRAUD
  Effectue une requete fetch avec une limite de 5s 
  Sort une réponse http

  @var String url: L’adresse web à laquelle la requête est envoyée
  @var {Map<String, String>? headers} = liste d’en-têtes optionnelle
  @var Duration timeout = const Duration(seconds: 5) → Limite de temps pour la requête
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
  Créé le 28/02 Par Armand BRAUD
  Return les id des listes présente dans un board au sein d'une liste
  
  @var Board_ID: Id du board dans les quelles les listes seront récupéré
  */
  static Future<List<dynamic>> getList(String Board_ID) async {
    final url = "$baseUrl/boards/$Board_ID/lists?key=$API_KEY&token=$API_TOKEN";
    final response = await fetchWithTimeout(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error fetching lists: ${response.statusCode}");
    }
  }

}
