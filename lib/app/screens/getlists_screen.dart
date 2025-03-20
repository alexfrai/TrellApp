import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/services/list_service.dart';
import 'package:flutter_trell_app/app/widgets/button_create_list.dart';
import 'package:flutter_trell_app/app/widgets/getonelist_widget.dart';

class GetListWidget extends StatefulWidget {
  const GetListWidget({required this.boardId, super.key});

  final String boardId;

  @override
  GetListWidgetState createState() => GetListWidgetState();
}

class GetListWidgetState extends State<GetListWidget> {
  final StreamController<List<dynamic>> _listsStreamController = StreamController<List<dynamic>>.broadcast();
  List<dynamic>? _lastLists;

  @override
  void initState() {
    super.initState();
    _fetchAndUpdateLists();
  }

  Future<void> _fetchAndUpdateLists() async {
    while (mounted) {
      try {
        final List<dynamic> lists = await ListService.getList(widget.boardId);

        // Vérifie si les données ont changé
        if (_lastLists == null || !_listEquals(lists, _lastLists!)) {
          _listsStreamController.add(lists);  // Met à jour le stream
          _lastLists = lists;  // Mets à jour la version locale des listes
        }
      } catch (error) {
        debugPrint('Erreur lors de la mise à jour des listes: $error');
      }
      await Future.delayed(const Duration(seconds: 2)); // Temps d'attente entre chaque requête (plus rapide que 5s)
    }
  }

  bool _listEquals(List<dynamic> list1, List<dynamic> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i]['id'] != list2[i]['id']) return false; // Compare les IDs des listes (ou autres propriétés uniques)
    }
    return true;
  }

  @override
  void dispose() {
    _listsStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<dynamic>>(
        stream: _listsStreamController.stream,
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune liste trouvée'));
          }

          final List<dynamic> lists = snapshot.data!;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ...lists.map<Widget>((dynamic list) {
                  return SizedBox(
                    width: 300,
                    child: GetOneListWidget(
                      list: list,
                      refreshLists: _fetchAndUpdateLists,
                      boardId: widget.boardId,
                    ),
                  );
                }).toList(),
                SizedBox(
                  width: 300,
                  child: Createlistbutton(boardId: widget.boardId),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
