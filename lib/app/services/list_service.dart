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
      '$baseUrl/lists?name=${Uri.encodeComponent(name)}&idBoard=${Uri.encodeComponent(boardId)}&key=$apikey&token=$apitoken',
    );
    final http.Response response = await http.post(url);

    if (response.statusCode != 200) {
      throw Exception('Erreur ${response.statusCode}: ${response.body}');
    }
    return jsonDecode(response.body);
  } catch (error) {
    rethrow;
  }
}

  ///Change le nom d'une liste
  ///@var String idist, @var String newname
  static Future<dynamic> updateListName(String idlist, String newname) async { 
  try {
    final Uri url = Uri.parse(
      'https://api.trello.com/1/lists/$idlist?name=${Uri.encodeComponent(newname)}&key=$apikey&token=$apitoken',
    );
    // Type of request: PUT (UPDATE)
    final http.Response response = await http.put(url);

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
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, String>{'pos': newpos}), // Envoi du paramètre pos correctement
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur ${response.statusCode}: ${response.body}');
    }

    return jsonDecode(response.body);
  } catch (error) {
    rethrow;
  }
}

///Récupère les postitions de toutes les list d'un board
static Future<List<double>> getAllListPositions(String boardId) async {
    try {
      final Uri url = Uri.parse(
        '$baseUrl/boards/$boardId/lists?key=$apikey&token=$apitoken',
      );

      final http.Response response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }

      final List<dynamic> lists = jsonDecode(response.body);

      // Extraire toutes les positions des listes
      final List<double> positions = lists.map<double>((list) => (list["pos"] as num).toDouble()).toList();

      // Trier les positions pour s'assurer qu'elles sont dans l'ordre
      positions.sort();

      return positions;
    } catch (error) {
      throw Exception('Erreur lors de la récupération des positions : $error');
    }
  }

/// retourne la position de la liste
static Future<double> getListPos(String idlist) async {
  try {
    final Uri url = Uri.parse(
      '$baseUrl/lists/$idlist?key=$apikey&token=$apitoken',
    );

    final http.Response response = await http.get( // Correction: utiliser GET au lieu de PUT
      url,
      headers: <String, String>{'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body);
    
    if (data is Map<String, dynamic> && data.containsKey('pos')) {
      return (data['pos'] as num).toDouble(); // S'assure que c'est un double
    } else {
      throw Exception("Réponse invalide: 'pos' non trouvé");
    }
  } catch (error) {
    rethrow;
  }
}

static Future<String?> getListName(String id) async {
  try {
    final Uri url = Uri.parse('$baseUrl/lists/$id?key=$apikey&token=$apitoken');

    final response = await http.get(url); // Utilisation de GET avec HTTP

    if (response.statusCode != 200) {
      throw Exception('Erreur ${response.statusCode}: $response');
    }

    final data = jsonDecode(response.body); // Décoder la réponse JSON
    return data['name']; // Récupérer le nom de la liste
  } catch (error) {
    print("❌ Erreur lors de la récupération du nom de la liste: $error");
    return null; // Retourner null en cas d'erreur
  }
}


static Future<void> ArchiveList(String id) async {
  try {
    final Uri url = Uri.parse(
      '$baseUrl/lists/$id?key=$apikey&token=$apitoken',
    );

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'closed': true}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }

    // Attendre le résultat de getListName avant de l'afficher
    final listName = await getListName(id);
    print('List $listName archive success.');
  } catch (error) {
    print('❌ Error archiving list: $error');
  }
}



}
