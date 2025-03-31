// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_trell_app/app/services/board_service.dart';
import 'package:flutter_trell_app/main.dart';
import 'package:http/http.dart' as http;

/// API KEYS
final String apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'] ?? '';
final String apiToken = dotenv.env['NEXT_PUBLIC_API_TOKEN'] ?? '';

class Sidebar extends StatefulWidget {
  final Function(String) onBoardChanged;
  final String currentPage;
  final String workspaceId;

  const Sidebar({
    required this.currentPage,
    required this.onBoardChanged,
    required this.workspaceId,
    super.key,
  });

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  late String workspaceId;
  final String userId = '5e31418954e5fd1a91bd6ae5';

  String boardId = '6756c8816b281ad931249861';
  String boardName = '';
  Map<String, dynamic> boardData = {};
  List<dynamic> allBoards = [];
  String curentWorkspace = '';

  @override
  void initState() {
    super.initState();
    workspaceId = widget.workspaceId;
    fetchData();
    setState(() {
      workspaceId = widget.workspaceId;
    });
  }

  @override
  void didUpdateWidget(covariant Sidebar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.workspaceId != widget.workspaceId) {
      print('🔁 WorkspaceId changé : ${widget.workspaceId}');
      setState(() {
        workspaceId = widget.workspaceId;
      });
      fetchData(); // 🔁 recharge les données
    }
  }

  Future<dynamic> fetchApi(String apiRequest, String method) async {
    try {
      final response = method == 'POST'
          ? await http.post(Uri.parse(apiRequest))
          : await http.get(Uri.parse(apiRequest));

      if (response.statusCode != 200) {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }

      return json.decode(response.body);
    } catch (error) {
      debugPrint('❌ Erreur dans fetchApi: $error');
      return null;
    }
  }

  Future<void> fetchData() async {
    
    await getBoard();
    await getAllBoards();
    await getCurentWorkspace();
  }

  Future<void> changeBoard(Map<String, dynamic> data) async {
    if (MyApp.currentPage != 'board') {
      MyApp.currentPage = 'board';
      await Navigator.pushNamed(context, '/workspace');
    }
    print('change board into');
    setState(() {
      boardId = data['id'];
      boardData = data;
    });

    widget.onBoardChanged(boardId); // 🔥 Informe `Workspace` du changement !
    debugPrint('Board sélectionné: $boardId');
  }

  Future<void> createBoard() async {
    await fetchApi(
      'https://api.trello.com/1/boards/?name=$boardName&key=$apiKey&token=$apiToken',
      'POST',
    );
    await getAllBoards();
  }

  Future<void> deleteBoard(String boardId) async {
    await BoardService.deleteBoard(boardId);
  }

  Future<void> getBoard() async {
    final data = await fetchApi(
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
        print('✅ Workspace affiché : $curentWorkspace');
      });
    }
  }

  Future<void> getAllBoards() async {
    final boards = await fetchApi(
      'https://api.trello.com/1/organizations/$workspaceId/boards?key=$apiKey&token=$apiToken',
      'GET',
    );
    if (boards != null) {
      setState(() {
        allBoards = boards;
      });
    }
  }

  Future<void> modalDeleteBoard(String boardId, String boardName) async {
    await showModalBottomSheet(
      context: context,
      builder: (_) {
        return SizedBox(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Supprimer le board "$boardName" ?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    child: const Text('Oui'),
                    onPressed: () async {
                      Navigator.pop(context);
                      await deleteBoard(boardId);
                    },
                  ),
                  ElevatedButton(
                    child: const Text('Non'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> showCreateBoardDialog() async {
    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Créer un board'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'Nom du board'),
            onChanged: (value) => boardName = value,
          ),
          actions: [
            TextButton(
              child: const Text('Annuler'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Créer'),
              onPressed: () {
                createBoard();
                Navigator.pop(context);
              },
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
      color: Colors.grey[850],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            height: 80,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  child: Text(curentWorkspace.isNotEmpty ? curentWorkspace[0] : '?'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    curentWorkspace,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
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
                  height: 150,
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: const Text('Boards'),
                        textColor: Colors.white,
                        onTap:
                            () async => <Object>{
                              MyApp.currentPage = '',
                              Navigator.pushNamed(context, '/myboards'),
                            },
                      ),
                      ListTile(
                        title: const Text('Members'),
                        textColor: Colors.white,
                        onTap:
                            () async => <Object>{
                              MyApp.currentPage = 'member',
                              Navigator.pushNamed(context, '/members'),
                            },
                      ),
                      ListTile(
                        title: const Text('Parameters'),
                        textColor: Colors.white,
                        onTap:
                            () async =>
                                Navigator.pushNamed(context, '/parameters'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Row(
            children: [
              const SizedBox(width: 10),
              const Text('Vos Boards', style: TextStyle(color: Colors.white)),
              IconButton(
                onPressed: showCreateBoardDialog,
                icon: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),

          // Boards list
          Expanded(
            child: SizedBox(
              child: Padding(
                padding: EdgeInsets.all(10),
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
                        backgroundColor:
                            board['prefs']['backgroundColor'] != null
                                ? Color(
                                  int.parse(
                                    '0xFF' +
                                        board['prefs']['backgroundColor']
                                            .substring(1),
                                  ),
                                ) // Convertir HEX en `Color`
                                : Colors.grey,
                      ),
                      title: Text(
                        board['name'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: TextButton(
                        onPressed: () async {
                          await modalDeleteBoard(board['id'], board['name']);
                        },
                        child: Icon(Icons.delete, color: Colors.red),
                      ),
                      hoverColor: Colors.amber,
                      onTap: () async => changeBoard(board),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
