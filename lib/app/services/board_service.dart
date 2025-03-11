import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

///@var apiKey
final String apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'] ?? '';
///@var apiToken
final String apiToken = dotenv.env['NEXT_PUBLIC_API_TOKEN'] ?? '';

/// Ajouter un board aux favoris
Future<void> addBoardToFavorite(String userId, String boardId) async {
  final String url = 'https://api.trello.com/1/members/$userId/boardStars?idBoard=$boardId&pos=bottom&key=$apiKey&token=$apiToken';
  
  try {
    final http.Response response = await http.post(Uri.parse(url));
    if (response.statusCode == 200) {
      print('Board successfully starred: ${response.body}');
    } else {
      print('Erreur lors de l ajout aux favoris: ${response.statusCode}');
    }
  } catch (error) {
    print('Erreur dans addBoardToFavorite: $error');
  }
}

/// Supprimer un board des favoris
Future<void> removeBoardFromFavorite(String userId, String boardStarId) async {
  final String url = 'https://api.trello.com/1/members/$userId/boardStars/$boardStarId?key=$apiKey&token=$apiToken';
  
  try {
    final http.Response response = await http.delete(Uri.parse(url));
    if (response.statusCode == 200) {
      print('Board successfully unstarred');
    } else {
      throw Exception('Erreur lors de la suppression des favoris: ${response.statusCode}');
    }
  } catch (error) {
    throw Exception('Erreur dans removeBoardFromFavorite: $error');
  }
}

/// Récupérer les boards favoris
Future<List<Map<String, dynamic>>> getBoardFromFavorite(String memberId) async {
  final String url = 'https://api.trello.com/1/members/$memberId/boards?key=$apiKey&token=$apiToken';
  
  try {
    final http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<Map<String, dynamic>> starredBoards = data.where((board) => board['starred'] == true).cast<Map<String, dynamic>>().toList();
      print('Starred (favorite) boards: $starredBoards');
      return starredBoards;
    } else {
      throw Exception('Erreur lors de la récupération des boards: ${response.statusCode}');
    }
  } catch (error) {
    throw Exception('Erreur dans getBoardFromFavorite: $error');
  }
}
