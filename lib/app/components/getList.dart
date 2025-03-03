import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/widgets/createListButton.dart'; // Import the CreateListButton
import '../services/list_service.dart';
import '../widgets/getOneListWidget.dart'; // Import the GetOneListWidget

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
    _listsFuture = ListService.getList(widget.boardId); // Fetch the lists when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _listsFuture, // Use the future to load the data
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Erreur: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Aucune liste trouvée"));
        }

        List<dynamic> lists = snapshot.data!;

        // Return a ListView containing the fetched lists and the CreateListButton
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: lists.length,
                itemBuilder: (context, index) {
                  return GetOneListWidget(list: lists[index]); // Use the GetOneListWidget to display each list
                },
              ),
            ),
            // Add CreateListButton below the list of items
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Createlistbutton(BOARD_ID: widget.boardId), // Place the CreateListButton widget here
            ),
          ],
        );
      },
    );
  }
}
