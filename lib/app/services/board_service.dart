import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Class
class BoardService {
  /// @var apiKey
  static final String? apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'];
  /// @var apiToken
  static final String? apiToken = dotenv.env['NEXT_PUBLIC_API_TOKEN'];

  final StreamController<Map<String, dynamic>> _boardStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  static int _boardApiRequestCount = 0;
  ///board stream
  Stream<Map<String, dynamic>> get boardStream => _boardStreamController.stream;

  static Future<http.Response> _makeRequest(String url, {required String method}) async {
    try {
      switch (method) {
        case 'GET':
          return await http.get(Uri.parse(url));
        case 'POST':
          return await http.post(Uri.parse(url));
        case 'DELETE':
          return await http.delete(Uri.parse(url));
        default:
          throw Exception('Unsupported HTTP method');
      }
    } catch (error) {
      throw Exception('Error making request: $error');
    }
  }


  /// Create a new Board
  static Future<bool> createBoard(String name, String workspaceId,
      [String backgroundColor = 'blue', String visibility = 'org',]) async {
    final String url =
        'https://api.trello.com/1/boards/?name=$name&idOrganization=$workspaceId&prefs_background=$backgroundColor&prefs_permissionLevel=$visibility&key=$apiKey&token=$apiToken';

    try {
      final http.Response response = await http.post(Uri.parse(url));
      _incrementBoardApiRequestCount();
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return true;
      } else {
        throw Exception('Erreur lors de la crea du board : ${response.statusCode} / ${response.body}');
      }
    } catch (error) {
      throw Exception('Erreur dans createBoard: $error');
    }
  }

  /// Create a new Board with a template
  static Future<bool> createBoardWithTemplate(String name, String boardId,
      [String workspaceId = '672b2d9a2083a0e3c28a3212', String visibility = 'org',]) async {
    final String url =
        'https://api.trello.com/1/boards/?name=$name&idBoardSource=$boardId&idOrganization=$workspaceId&prefs_permissionLevel=$visibility&key=$apiKey&token=$apiToken';
    try {
      final http.Response response = await http.post(Uri.parse(url));
      _incrementBoardApiRequestCount();
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return true;
      } else {
        throw Exception('Erreur lors de la crea du board : ${response.statusCode} / ${response.body}');
      }
    } catch (error) {
      throw Exception('Erreur dans createBoard: $error');
    }
  }

  /// Get all data of a board
  static Future<Map<String, dynamic>> getBoard(String boardId) async {
    final String url = 'https://api.trello.com/1/boards/$boardId?key=$apiKey&token=$apiToken';

    try {
      final http.Response response = await http.get(Uri.parse(url));
      _incrementBoardApiRequestCount();
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
      _incrementBoardApiRequestCount();
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Erreur lors de la crea du board : ${response.statusCode} / ${response.body}');
      }
    } catch (error) {
      throw Exception('Erreur dans createBoard: $error');
    }
  }

  /// Delete board
  static Future<bool> deleteBoard(String boardId) async {
    final String url = 'https://api.trello.com/1/boards/$boardId?key=$apiKey&token=$apiToken';

    try {
      final http.Response response = await http.delete(Uri.parse(url));
      _incrementBoardApiRequestCount();
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Erreur lors de la supression du board : ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Erreur dans suppressBoard: $error');
    }
  }

  /// Get favorite board of a member (a mettre dans member_service ??)
  static Future<List<Map<String, dynamic>>> getFavBoards() async {
    final String url = 'https://api.trello.com/1/members/me/boardStars?key=$apiKey&token=$apiToken';

    try {
      final http.Response response = await http.get(Uri.parse(url));
      _incrementBoardApiRequestCount();
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<String> boardIds = data.map((dynamic item) => item['idBoard'].toString()).toList();

        final List<Map<String, dynamic>> boardData = await Future.wait(
          boardIds.map(getBoard),
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
      _incrementBoardApiRequestCount();
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
      _incrementBoardApiRequestCount();
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
      _incrementBoardApiRequestCount();
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Map<String, dynamic>> starredBoards = data.where((dynamic board) => board['starred'] == true).cast<Map<String, dynamic>>().toList();
        return starredBoards;
      } else {
        throw Exception('Erreur lors de la récupération des boards: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Erreur dans getBoardFromFavorite: $error');
    }
  }

  /// Refresh
  Future<void> refreshListsAndCards(String boardId) async {
    await fetchBoardData(boardId);
  }

  /// Actualise
    Future<void> fetchBoardData(String boardId) async {
    try {
      final dynamic listsResponse = await _makeRequest(
        'https://api.trello.com/1/boards/$boardId/lists?key=$apiKey&token=$apiToken',
        method: 'GET',
      );
      final dynamic cardsResponse = await _makeRequest(
        'https://api.trello.com/1/boards/$boardId/cards?key=$apiKey&token=$apiToken',
        method: 'GET',
      );

      _incrementBoardApiRequestCount();
      _incrementBoardApiRequestCount();

      if (listsResponse.statusCode == 200 && cardsResponse.statusCode == 200) {
        final dynamic newLists = json.decode(listsResponse.body);
        final dynamic newCards = json.decode(cardsResponse.body);

        // Compare with the previous state and emit only changes
        Map<String, dynamic>? currentState;
        _boardStreamController.stream.listen((Map<String, dynamic> data) {
          currentState = data;
        });

        final Map<String, dynamic> newState = <String, dynamic>{
          'lists': newLists,
          'cards': newCards,
        };

        if (!_mapsEqual(currentState ?? <String, dynamic>{}, newState)) {
          _boardStreamController.add(newState);
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      throw Exception('Error fetching board data: $error');
    }
  }

  bool _mapsEqual(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    if (map1.length != map2.length) return false;
    for (final String key in map1.keys) {
      if (json.encode(map1[key]) != json.encode(map2[key])) {
        return false;
      }
    }
    return true;
  }

  /// Dispose
  Future<void> dispose() async {
    await _boardStreamController.close();
  }

  static void _incrementBoardApiRequestCount() {
    _boardApiRequestCount += 1;
    print('board: $_boardApiRequestCount');
  }

}
