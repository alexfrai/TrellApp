// ignore_for_file: always_specify_types

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/services/get_all_cards.dart';
import 'package:flutter_trell_app/app/services/list_service.dart';
import 'package:flutter_trell_app/app/widgets/createListButton.dart';
import 'package:flutter_trell_app/app/widgets/getOneListWidget.dart';

///Affiche une liste
class GetListWidget extends StatefulWidget {
  /// Constructeur
  const GetListWidget({required this.boardId, super.key});

  /// ID du board (requis)
  final String boardId;

  @override
  GetListWidgetState createState() => GetListWidgetState();
}

///Prend l etat du get
class GetListWidgetState extends State<GetListWidget> {
  late Future<Map<String, dynamic>> _dataFuture;
  final StreamController<List<dynamic>> _listsStreamController =
      StreamController.broadcast();
  List<dynamic> _currentLists =
      []; // Stocke les listes actuelles pour comparer avec les nouvelles

  @override
  void initState() {
    super.initState();
    _loadData(); // Initial load
    _fetchAndUpdateLists(); // Start the continuous fetch
  }

  // Load the data (lists and cards) initially
  Future<void> _loadData() async {
    setState(() {
      _dataFuture = _fetchData();
    });
  }

  // Fetch the lists and their associated cards
  Future<Map<String, dynamic>> _fetchData() async {
    final List<dynamic> lists = await ListService.getList(widget.boardId);
    final List<Map<String, dynamic>> cards = await CardService.getAllCards(
      lists,
    );
    return <String, dynamic>{'lists': lists, 'cards': cards};
  }

  /// Fetch and update lists periodically (every 10 seconds)
  Future<void> _fetchAndUpdateLists() async {
    int retryCount = 0;
    while (mounted) {
      // Check if the widget is still active
      try {
        final List newLists = await ListService.getList(widget.boardId);
        if (_listsHaveChanged(newLists)) {
          _currentLists = newLists; // Update the current lists state
          _listsStreamController.add(
            newLists,
          ); // Push the new lists to the stream
        }
        retryCount = 0; // Reset retry count on success
      } catch (error) {
        if (error.toString().contains('429')) {
          retryCount++;
          final int waitTime = 2 ^ retryCount; // Exponential backoff
          debugPrint(
            'Trop de requêtes. Nouvelle tentative dans $waitTime secondes.',
          );
          await Future.delayed(Duration(seconds: waitTime));
        } else {
          debugPrint('Erreur lors de la mise à jour: $error');
          break; // If it's another error, stop the loop
        }
      }
      await Future.delayed(
        const Duration(seconds: 10),
      ); // Refresh every 10 seconds if changed
    }
  }

  // Compare new lists with the previous ones to avoid unnecessary updates
  bool _listsHaveChanged(List<dynamic> newLists) {
    if (_currentLists.length != newLists.length) return true;
    for (int i = 0; i < _currentLists.length; i++) {
      if (_currentLists[i]['id'] != newLists[i]['id'] ||
          _currentLists[i]['name'] != newLists[i]['name']) {
        return true;
      }
    }
    return false;
  }

  @override
  Future<void> dispose() async {
    await _listsStreamController
        .close(); // Close the StreamController to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Listes et Cartes Trello')),
      body: StreamBuilder<List<dynamic>>(
        stream: _listsStreamController.stream,
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune liste trouvée'));
          }

          final List lists = snapshot.data!;
          return FutureBuilder<Map<String, dynamic>>(
            future: _dataFuture,
            builder: (
              BuildContext context,
              AsyncSnapshot<Map<String, dynamic>> dataSnapshot,
            ) {
              if (dataSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (dataSnapshot.hasError) {
                return Center(child: Text('Erreur: ${dataSnapshot.error}'));
              } else if (!dataSnapshot.hasData ||
                  dataSnapshot.data!['lists'].isEmpty) {
                return const Center(child: Text('Aucune liste trouvée'));
              }

              final cards = dataSnapshot.data!['cards'];

              return Column(
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            lists.map<Widget>((list) {
                              final List<Map<String, dynamic>> listCards =
                                  cards
                                      .where(
                                        (Map<String, dynamic> card) =>
                                            card['listId'] == list['id'],
                                      )
                                      .toList();
                              return SizedBox(
                                width: 300,
                                child: GetOneListWidget(
                                  list:
                                      list, // ✅ Correction : On passe la liste complète
                                  cards:
                                      listCards, // ✅ Correction : On passe les cartes associées
                                  refreshLists:
                                      _loadData, // ✅ Fonction pour recharger les listes
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Createlistbutton(BOARD_ID: widget.boardId),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}