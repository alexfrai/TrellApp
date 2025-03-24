import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;


///Class
class BoardService {
///@var apiKey
static final String? apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'];
///@var apiToken
static final String? apiToken = dotenv.env['NEXT_PUBLIC_API_TOKEN'];
  
  /// Create a new Board
  static Future<bool> createBoard(String name , String workspaceId, [String backgroundColor = 'blue', String visibility = 'org']) async {
    print('create a board $visibility');
     final String url = 'https://api.trello.com/1/boards/?name=$name&idOrganization=$workspaceId&prefs_background=$backgroundColor&prefs_permissionLevel=$visibility&key=$apiKey&token=$apiToken';
    //  print(url);
    try {

      final http.Response response = await http.post(Uri.parse(url));
      if (response.statusCode == 200) {
        // ignore: always_specify_types
        final data = json.decode(response.body);
        // print(data);
        return true;
      } else {
        throw Exception('Erreur lors de la crea du board : ${response.statusCode} / ${response.body}');
      }
    } catch (error) {
      throw Exception('Erreur dans createBoard: $error');
    }
  }
  /// Create a new Board with a template
  static Future<bool> createBoardWithTemplate(String name , String boardId ,[String workspaceId = '672b2d9a2083a0e3c28a3212']) async {
    print('create a board with template $workspaceId');
     final String url = 'https://api.trello.com/1/boards/?name=$name&idBoardSource=$boardId&idOrganization=$workspaceId&key=$apiKey&token=$apiToken';
    try {

      final http.Response response = await http.post(Uri.parse(url));
      if (response.statusCode == 200) {
        // ignore: unused_local_variable
        final data = json.decode(response.body);
        // print(data);
        return true;
      } else {
        throw Exception('Erreur lors de la crea du board : ${response.statusCode} / ${response.body}');
      }
    } catch (error) {
      throw Exception('Erreur dans createBoard: $error');
    }
  }

 ///Get all data of a board 
  static Future<Map<String, dynamic>> getBoard(String boardId) async {
  final String url = 'https://api.trello.com/1/boards/$boardId?key=$apiKey&token=$apiToken';

  try {
    final http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body).cast<String, dynamic>();
      return data;
    } else {
      throw Exception('❌ Erreur lors du chargement du board: ${response.statusCode} / ${response.body}');
    }
  } catch (error) {
    throw Exception('❌ Erreur dans getBoard: $error');
  }
}


/// Get a board id
  static Future<List<dynamic>?> getBoardWithShortId(String boardId) async {
     final String url = 'https://api.trello.com/1/boards/$boardId?key=$apiKey&token=$apiToken';
    try {

      final http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // print(data);
        return data;
      } else {
        throw Exception('Erreur lors de la crea du board : ${response.statusCode} / ${response.body}');
      }
    } catch (error) {
      throw Exception('Erreur dans createBoard: $error');
    }
  }


  ///Delete board
  static Future<bool> deleteBoard(String boardId) async {
     final String url = 'https://api.trello.com/1/boards/$boardId?key=$apiKey&token=$apiToken';
    
    try {
      final http.Response response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        // print('board deleted successfully');
        return true;
      } else {
        throw Exception('Erreur lors de la supression du board : ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Erreur dans suppressBoard: $error');
    }
  }
/// Get favorite board of a member (a mettre dans member_service ??)
  static Future<List<Map<String, dynamic>>> getFavBoards(String memberId) async {
  final String url = 'https://api.trello.com/1/members/$memberId/boardStars?key=$apiKey&token=$apiToken';

  try {
    final http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      // print('📌 Favorite boards data: $data');

      final List<String> boardIds = data.map((item) => item['idBoard'].toString()).toList();

      // Attente de toutes les requêtes
      final List<Map<String, dynamic>> boardData = await Future.wait(
        boardIds.map((id) => getBoard(id)),
      );

      return boardData;
    } else {
      throw Exception('❌ Erreur lors du chargement des favoris: ${response.statusCode} / ${response.body}');
    }
  } catch (error) {
    throw Exception('❌ Erreur dans getFavBoards: $error');
  }
}



  /// Ajouter un board aux favoris
  Future<void> addBoardToFavorite(String userId, String boardId) async {
    final String url = 'https://api.trello.com/1/members/$userId/boardStars?idBoard=$boardId&pos=bottom&key=$apiKey&token=$apiToken';
    
    try {
      final http.Response response = await http.post(Uri.parse(url));
      if (response.statusCode == 200) {
        // print('Board successfully starred: ${response.body}');
      } else {
        // print('Erreur lors de l ajout aux favoris: ${response.statusCode}');
      }
    } catch (error) {
      // print('Erreur dans addBoardToFavorite: $error');
    }
  }

  /// Supprimer un board des favoris
  Future<void> removeBoardFromFavorite(String userId, String boardStarId) async {
    final String url = 'https://api.trello.com/1/members/$userId/boardStars/$boardStarId?key=$apiKey&token=$apiToken';
    
    try {
      final http.Response response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        // print('Board successfully unstarred');
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
        // print('Starred (favorite) boards: $starredBoards');
        return starredBoards;
      } else {
        throw Exception('Erreur lors de la récupération des boards: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Erreur dans getBoardFromFavorite: $error');
    }
  }

}
