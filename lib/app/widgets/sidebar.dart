import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// API KEYS
final String apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'] ?? '';
/// API TOKEN
final String apiToken = dotenv.env['NEXT_PUBLIC_API_TOKEN'] ?? '';

///Class
class Sidebar extends StatefulWidget {
  ///Constructor
  const Sidebar({ super.key });


  @override
  _SidebarState createState() => _SidebarState();
}
 

class _SidebarState extends State<Sidebar> {
  final String userId = '5e31418954e5fd1a91bd6ae5';
  final String workspaceId = '672b2d9a2083a0e3c28a3212';

  String boardId = '';
  String boardName = '';
  Map<String, dynamic> boardData = {};
  List<dynamic> allBoards = [];
  String curentWorkspace = '';

  bool isLoading = true;

   @override
  void initState() {
    super.initState();
    fetchData();
  }

Future<void> fetchData() async {
    await getBoard();
    await getAllBoards();
    await getCurentWorkspace();
  }

  Future<dynamic> fetchApi(String apiRequest, String method) async {
    try {

      final http.Response response =
          await (method == 'POST'
              ? http.post(Uri.parse(apiRequest))
              : http.get(Uri.parse(apiRequest)));

      if (response.statusCode != 200) {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }

      return json.decode(response.body);
    } catch (error) {
      debugPrint('Erreur dans fetchApi: $error');
      return null;
    }
  }

  Future<void> changeBoard(Map<String, dynamic> data) async {
    setState(() {
      boardId = data['id'];
      boardData = data;
    });
    debugPrint('Board sélectionné: $boardId');
  }

  Future<void> createBoard() async {
    await fetchApi(

      'https://api.trello.com/1/boards/?name=$boardName&key=$apiKey&token=$apiToken',
      'POST',
    );
    await getAllBoards();
  }

  Future<void> getBoard() async {
    final dynamic data = await fetchApi(
      'https://api.trello.com/1/boards/$boardId?key=$apiKey&token=$apiToken',
      'GET',
    );

    if (data != null) {
      setState(() {
        boardData = data;
      });
    }
  }

  Future<void> getCurentWorkspace() async {

    final dynamic data = await fetchApi(
      'https://api.trello.com/1/organizations/$workspaceId?key=$apiKey&token=$apiToken',
      'GET',
    );
    if (data != null) {
      setState(() {
        curentWorkspace = data['displayName'];
      });
    }
  }

  Future<void> getAllBoards() async {

    final dynamic boards = await fetchApi(
      'https://api.trello.com/1/organizations/$workspaceId/boards?key=$apiKey&token=$apiToken',
      'GET',
    );
    if (boards != null) {
      setState(() {
        allBoards = boards;
      });
    }
  }

Future<void> showCreateBoardDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Créer un nouveau board'),
          content: Column(
            children: <Widget>[
              TextField(
                decoration: const InputDecoration(labelText: 'Nom du board'),
                onChanged: (String value) => boardName = value,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                createBoard();
                Navigator.of(context).pop();
              },
              child: const Text('Créer'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
            width: MediaQuery.of(context).size.width * 0.2,
            color: Colors.grey[800],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Header de l'espace de travail
                
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color.fromARGB(255, 38, 38, 38),
                      ),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        child: Text(
                          curentWorkspace.isNotEmpty ? curentWorkspace[0] : '?',
                        ),
                      ),
                      Text(
                        curentWorkspace,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),

                // Menu
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.20,
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              title: const Text('Boards'),
                              textColor: Colors.white,
                              onTap:
                                  () async =>
                                      Navigator.pushNamed(context, '/myboards'),
                            ),
                            ListTile(
                              title: const Text('Members'),
                              textColor: Colors.white,
                              onTap:
                                  () async =>
                                      Navigator.pushNamed(context, '/members'),
                            ),
                            ListTile(
                              title: const Text('Parameters'),
                              textColor: Colors.white,
                              onTap:
                                  () async => Navigator.pushNamed(
                                    context,
                                    '/parameters',
                                  ),
                            ),
                          ],
                        ),
                      ),

                      // Section des Boards
                      Row(
                        children: <Widget>[
                          const Text(
                            'Vos Boards',
                            style: TextStyle(color: Colors.white),
                          ),
                          IconButton(
                            onPressed: showCreateBoardDialog,
                            icon: const Icon(Icons.add, color: Colors.white),
                          ),
                        ],
                      ),

                      // Liste des boards
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: ListView.builder(
                          itemCount: allBoards.length,
                          itemBuilder: (BuildContext context, int index) {
                            final dynamic board = allBoards[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    board['prefs']['backgroundImage'] != null
                                        ? NetworkImage(
                                          board['prefs']['backgroundImage'],
                                        )
                                        : null,
                                backgroundColor: Colors.grey,
                              ),
                              title: Text(
                                board['name'],
                                style: const TextStyle(color: Colors.white),
                              ),
                              onTap: () async => changeBoard(board),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
