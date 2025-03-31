// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_trell_app/app/components/board.dart';
import 'package:flutter_trell_app/app/screens/members_screen.dart';
import 'package:flutter_trell_app/app/services/board_service.dart';
import 'package:flutter_trell_app/app/services/workspace_service.dart';
import 'package:flutter_trell_app/app/widgets/header.dart';
import 'package:flutter_trell_app/app/widgets/sidebar.dart';
import 'package:flutter_trell_app/main.dart';

/// API KEYS
final String apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'] ?? '';

/// API TOKEN
final String apiToken = dotenv.env['NEXT_PUBLIC_API_TOKEN'] ?? '';

///Class
class Workspace extends StatefulWidget {
  ///Constructor
  const Workspace({
    required this.curentPage,
    super.key,
    this.focusedBoardId,
    this.focusedListId,
    this.focusedCardId,
  });

  /// Curent page on website
  final String curentPage;
  final String? focusedBoardId;
  final String? focusedListId;
  final String? focusedCardId;

  /// Curent page on website
  static String workspaceId = '672b2d9a2083a0e3c28a3212';

  ///curent workspace to show
  //static String workspaceId = '672b2d9a2083a0e3c28a3212';

  @override
  _WorkspaceState createState() => _WorkspaceState();
}

class _WorkspaceState extends State<Workspace> {
  late String workspaceId;
  final String userId = '5e31418954e5fd1a91bd6ae5';

  late String boardId;
  String boardName = '';

  Map<String, dynamic> boardData = <String, dynamic>{};
  List<dynamic> allBoards = [];
  String curentWorkspace = '';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    boardId = widget.focusedBoardId ?? '6756c8816b281ad931249861';

    //fetchData();
    setState(() {
      workspaceId = Workspace.workspaceId;
    });
  }

  Future<void> updateWorkspace(String newWorkspaceId) async {
    print('update workspace in workspace');
    setState(() {
      Workspace.workspaceId = newWorkspaceId;
    });


    if (allBoards.isNotEmpty) {
      setState(() {
        boardId = allBoards.first['id'];
      });
    }

    await fetchData(); // 🔥 Attendre que les données soient chargées avant de naviguer
    //await Navigator.pushNamed(context, '/workspace'); // 🔥 Naviguer après mise à jour

    
  }

  Future<void> fetchData() async {
  print('🔄 Rechargement des données...');
  try {
    final List<Map<String, dynamic>> fetchedBoards = await BoardService.getAllBoard(Workspace.workspaceId);

    print('📋 Données reçues : $fetchedBoards'); // Vérifie la structure des données

    setState(() {
      allBoards = fetchedBoards; // ✅ Assignation directe
      if (allBoards.isNotEmpty) {
        boardId = allBoards.first['id']; // Sélection du premier board
      }
    });
  } catch (e) {
    print('❌ Erreur lors du chargement des boards : $e');
  }
}




  void updateBoardId(String newBoardId) {
    setState(() {
      boardId = newBoardId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accueil')),
      body: Column(
        children: <Widget>[
          // Page header
          SizedBox(
            height: 100, // Hauteur fixe pour éviter l'overflow
            child: Header(onWorkspaceChanged: updateWorkspace),
          ),
          // Page Content
          Expanded(
            child: Row(
              children: <Widget>[
                // Sidebar avec callback
                Sidebar(
                  currentPage: MyApp.currentPage,
                  onBoardChanged: updateBoardId,
                  workspaceId: Workspace.workspaceId
                ),

                // Contenu principal
                Expanded(
                  child:
                      widget.curentPage == 'board'
                          ? Board(
                            boardId: boardId,
                            focusedListId: widget.focusedListId,
                            focusedCardId: widget.focusedCardId,
                          )
                          : widget.curentPage == 'member'
                          ? MembersScreen(curentPage: '')
                          : SizedBox(), // 🔥 boardId mis à jour dynamiquement
                // Contenu principal
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
