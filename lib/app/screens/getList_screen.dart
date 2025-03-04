import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/services/get_all_cards.dart';
import 'package:flutter_trell_app/app/services/list_service.dart';
import 'package:flutter_trell_app/app/widgets/createListButton.dart';
import 'package:flutter_trell_app/app/widgets/getOneListWidget.dart';

class GetListWidget extends StatefulWidget {
  const GetListWidget({required this.boardId, super.key});
  final String boardId;

  @override
  _GetListWidgetState createState() => _GetListWidgetState();
}

class _GetListWidgetState extends State<GetListWidget> {
  late Future<Map<String, dynamic>> _dataFuture;

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
    final List<dynamic> lists = await ListService.getList(widget.boardId);
    final List<Map<String, dynamic>> cards = await CardService.getAllCards(lists);
    return <String, dynamic>{'lists': lists, 'cards': cards};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Listes et Cartes Trello')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
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
                  itemBuilder: (BuildContext context, int index) {
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
