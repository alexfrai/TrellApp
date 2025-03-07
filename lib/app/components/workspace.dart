import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_trell_app/app/components/board.dart';
import 'package:flutter_trell_app/app/widgets/sidebar.dart';
import 'package:http/http.dart' as http;

/// API KEYS
final String apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'] ?? '';
/// API TOKEN
final String apiToken = dotenv.env['NEXT_PUBLIC_API_TOKEN'] ?? '';

///Class
class Workspace extends StatefulWidget {
  ///Constructor
  const Workspace({super.key});

  @override
  _WorkspaceState createState() => _WorkspaceState();
}

class _WorkspaceState extends State<Workspace> {
  final String userId = '5e31418954e5fd1a91bd6ae5';
  final String workspaceId = '672b2d9a2083a0e3c28a3212';

  String boardId = 'XuEuw84e';
  String boardName = '';
  Map<String, dynamic> boardData = {};
  List<dynamic> allBoards = [];
  String curentWorkspace = '';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accueil')),
      body: Row(
      // ✅ Le header prend uniquement sa hauteur naturelle
      //const Header(),

        children: <Widget>[
          // Sidebar
          const Sidebar(),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Board(boardId: boardId),
          ),
        ],
      ),
    );
  }
}
