import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/widgets/createListButton.dart';
import 'package:flutter_trell_app/app/services/list_service.dart';
import 'package:flutter_trell_app/app/widgets/getOneListWidget.dart';

class GetListWidget extends StatefulWidget {
  final String boardId;

  const GetListWidget({Key? key, required this.boardId}) : super(key: key);

  @override
  _GetListWidgetState createState() => _GetListWidgetState();
}

class _GetListWidgetState extends State<GetListWidget> {
  late Future<List<dynamic>> _listsFuture;

  @override
  void initState() {
    super.initState();
    _listsFuture = ListService.getList(widget.boardId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // ✅ Ajout d'un Scaffold ici
      appBar: AppBar(title: const Text("Listes Trello")),
      body: FutureBuilder<List<dynamic>>(
        future: _listsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucune liste trouvée"));
          }

          List<dynamic> lists = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: lists.length,
                  itemBuilder: (context, index) {
                    return GetOneListWidget(list: lists[index]);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Createlistbutton(BOARD_ID: widget.boardId), // ✅ Correction du nom du widget
              ),
            ],
          );
        },
      ),
    );
  }
}
