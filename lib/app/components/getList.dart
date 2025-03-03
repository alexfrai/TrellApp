import 'package:flutter/material.dart';
import '../services/list_service.dart';
import '../widgets/getOneListWidget.dart'; // Import du composant

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
    return FutureBuilder<List<dynamic>>(
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
        return ListView.builder(
          itemCount: lists.length,
          itemBuilder: (context, index) {
            return GetOneListWidget(list: lists[index]); // ✅ Utilisation du composant
          },
        );
      },
    );
  }
}
