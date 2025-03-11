import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/services/get_all_cards.dart';
import 'package:flutter_trell_app/app/services/list_service.dart';
import 'package:flutter_trell_app/app/widgets/createListButton.dart';
import 'package:flutter_trell_app/app/widgets/getOneListWidget.dart';

/// Affiche tout ce qui est en rapport avec les listes
class GetListWidget extends StatefulWidget {
  const GetListWidget({required this.boardId, required this.cardId, super.key});

  final String boardId;
  final String cardId;

  @override
  GetListWidgetState createState() => GetListWidgetState();
}

class GetListWidgetState extends State<GetListWidget> {
  late Future<Map<String, dynamic>> _dataFuture;
  final StreamController<List<dynamic>> _listsStreamController =
      StreamController.broadcast();
  List<dynamic> _currentLists = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _fetchAndUpdateLists();
  }

  Future<void> _loadData() async {
    setState(() {
      _dataFuture = _fetchData();
    });
  }

  Future<Map<String, dynamic>> _fetchData() async {
    final List<dynamic> lists = await ListService.getList(widget.boardId);
    final List<Map<String, dynamic>> cards = await CardService.getAllCards(lists);
    return <String, dynamic>{'lists': lists, 'cards': cards};
  }

  Future<void> _fetchAndUpdateLists() async {
    int retryCount = 0;
    while (mounted) {
      try {
        final List newLists = await ListService.getList(widget.boardId);
        if (_listsHaveChanged(newLists)) {
          _currentLists = newLists;
          _listsStreamController.add(newLists);
        }
        retryCount = 0;
      } catch (error) {
        if (error.toString().contains('429')) {
          retryCount++;
          final int waitTime = 2 ^ retryCount;
          debugPrint('Trop de requêtes. Nouvelle tentative dans $waitTime secondes.');
          await Future.delayed(Duration(seconds: waitTime));
        } else {
          debugPrint('Erreur lors de la mise à jour: $error');
          break;
        }
      }
      await Future.delayed(const Duration(seconds: 10));
    }
  }

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
    await _listsStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
            builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> dataSnapshot) {
              if (dataSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (dataSnapshot.hasError) {
                return Center(child: Text('Erreur: ${dataSnapshot.error}'));
              } else if (!dataSnapshot.hasData || dataSnapshot.data!['lists'].isEmpty) {
                return const Center(child: Text('Aucune liste trouvée'));
              }

              final cards = dataSnapshot.data!['cards'];

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...lists.map<Widget>((list) {
                      final List<Map<String, dynamic>> listCards = cards
                          .where((Map<String, dynamic> card) => card['listId'] == list['id'])
                          .toList();
                      return SizedBox(
                        width: 300,
                        child: GetOneListWidget(
                          list: list,
                          cards: listCards,
                          refreshLists: _loadData,
                          boardId: widget.boardId,
                          cardId: widget.cardId, // Passage du boardId
                        ),
                      );
                    }).toList(),
                    // Bouton de création de liste
                    SizedBox(
                      width: 300,
                      child: Createlistbutton(BOARD_ID: widget.boardId),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}