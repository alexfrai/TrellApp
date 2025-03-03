// ignore_for_file: public_member_api_docs, library_private_types_in_public_api, discarded_futures

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Board extends StatefulWidget {
  const Board({required this.boardId, super.key});
  final String boardId;

  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Board> {
  String apiKey = 'TA_CLE_API';
  String apiToken = 'TON_TOKEN';
  String userId = '5e31418954e5fd1a91bd6ae5';

  Map<String, dynamic>? currentBoard;
  String background = '';
  bool isFavorite = false;

  Future<Map<String, dynamic>?> fetchBoard() async {
    final String url =
        'https://api.trello.com/1/boards/${widget.boardId}?key=$apiKey&token=$apiToken';
    try {
      final http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        // print('Erreur HTTP: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      // print('Erreur dans fetchBoard : $error');
      return null;
    }
  }

  Future<void> handleFavorite() async {
    if (isFavorite) {
      await removeBoardFromFavorites();
    } else {
      await addBoardToFavorites();
    }
  }

  Future<void> addBoardToFavorites() async {
    final String url =
        'https://api.trello.com/1/members/$userId/boardStars?idBoard=${widget.boardId}&pos=bottom&key=$apiKey&token=$apiToken';
    await http.post(Uri.parse(url));
    setState(() {
      isFavorite = true;
    });
  }

  Future<void> removeBoardFromFavorites() async {
    final String url =
        'https://api.trello.com/1/members/$userId/boardStars/${widget.boardId}?key=$apiKey&token=$apiToken';
    await http.delete(Uri.parse(url));
    setState(() {
      isFavorite = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: fetchBoard(),
      builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || snapshot.data == null) {
          return const Center(child: Text('Erreur lors du chargement du board'));
        }

        currentBoard = snapshot.data;
        background = currentBoard?['prefs']['backgroundImage'] ?? '';
        isFavorite = currentBoard?['starred'] ?? false;

        return DecoratedBox(
          decoration: BoxDecoration(
            image: background.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(background),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: Column(
            children: <Widget>[
              // Header
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          currentBoard?['name'] ?? 'Board',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: handleFavorite,
                          icon: Icon(
                            isFavorite ? Icons.star : Icons.star_border,
                            color: Colors.yellow,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.visibility),
                          label: const Text('Visibility'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.person_add_alt),
                          label: const Text('Share'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Body - Ici, tu peux afficher les listes et cartes
              const Expanded(
                child: Center(
                  child: Text(
                    'Contenu du board',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
