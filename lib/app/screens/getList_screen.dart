import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/services/get_all_cards.dart';

import 'package:flutter_trell_app/app/services/list_service.dart';
import 'package:flutter_trell_app/app/widgets/createListButton.dart';
import 'package:flutter_trell_app/app/widgets/getOneListWidget.dart';

class GetListWidget extends StatefulWidget {
  const GetListWidget({super.key, required this.boardId});
  final String boardId;

  @override
  _GetListWidgetState createState() => _GetListWidgetState();
}

class _GetListWidgetState extends State<GetListWidget> {
  late Future<Map<String, dynamic>> _dataFuture;
  final StreamController<List<dynamic>> _listsStreamController = StreamController.broadcast();
  List<dynamic> _currentLists = []; // Stocke les listes actuelles pour comparer avec les nouvelles

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// 🔄 Rafraîchir les données (listes et cartes)
  Future<void> _loadData() async {
    setState(() {
      _dataFuture = _fetchData();
    });
  }

  /// Récupère les listes et leurs cartes associées
  Future<Map<String, dynamic>> _fetchData() async {
    List<dynamic> lists = await ListService.getList(widget.boardId);
    List<Map<String, dynamic>> cards = await CardService.getAllCards(lists);
    return {'lists': lists, 'cards': cards};
    _fetchAndUpdateLists(); // Chargement initial
  }

  /// Fonction pour récupérer les listes et mettre à jour le Stream si elles changent
  Future<void> _fetchAndUpdateLists() async {
    while (mounted) { // Vérifie que le widget est toujours actif
      try {
        final newLists = await ListService.getList(widget.boardId);
        if (_listsHaveChanged(newLists)) {
          _currentLists = newLists; // Met à jour l'état actuel
          _listsStreamController.add(newLists); // Envoie les nouvelles listes au Stream
        }
      } catch (error) {
        debugPrint("Erreur lors de la récupération des listes: $error");
      }
      await Future.delayed(const Duration(seconds: 2)); // Rafraîchit toutes les 2s (uniquement si changement)
    }
  }

  /// Compare les nouvelles listes avec les anciennes pour éviter des mises à jour inutiles
  bool _listsHaveChanged(List<dynamic> newLists) {
    if (_currentLists.length != newLists.length) return true;
    for (int i = 0; i < _currentLists.length; i++) {
      if (_currentLists[i]['id'] != newLists[i]['id'] || _currentLists[i]['name'] != newLists[i]['name']) {
        return true;
      }
    }
    return false;
  }

  @override
  void dispose() {
    _listsStreamController.close(); // Ferme le StreamController pour éviter les fuites mémoire
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Listes et Cartes Trello')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!['lists'].isEmpty) {
            return const Center(child: Text('Aucune liste trouvée'));
          }

          final lists = snapshot.data!['lists'];
          final cards = snapshot.data!['cards'];

          return Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  itemCount: lists.length,
                  itemBuilder: (context, index) {
                    final list = lists[index];
                    final listCards = cards.where((card) => card['listId'] == list['id']).toList();

                    return GetOneListWidget(
                      list: list,
                      cards: listCards,
                      refreshLists: _loadData, // 🔄 Passer la fonction de mise à jour
                    );
                  },

                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Createlistbutton(BOARD_ID: widget.boardId),
              ),
            ],
          );
        },
      ),
    );
  }
}
