import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/services/list_service.dart';
import 'package:flutter_trell_app/app/widgets/createListButton.dart';
import 'package:flutter_trell_app/app/widgets/getOneListWidget.dart';

class GetListWidget extends StatefulWidget {
  final String boardId;

  const GetListWidget({Key? key, required this.boardId}) : super(key: key);

  @override
  _GetListWidgetState createState() => _GetListWidgetState();
}

class _GetListWidgetState extends State<GetListWidget> {
  final StreamController<List<dynamic>> _listsStreamController = StreamController.broadcast();
  List<dynamic> _currentLists = []; // Stocke les listes actuelles pour comparer avec les nouvelles

  @override
  void initState() {
    super.initState();
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
      appBar: AppBar(title: const Text('Listes Trello')),
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

          final List<dynamic> lists = snapshot.data!;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: lists.map((list) {
                        return SizedBox(
                          width: 300,
                          child: GetOneListWidget(list: list),
                        );
                      }).toList(),
                    ),
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
      ),
    );
  }
}
