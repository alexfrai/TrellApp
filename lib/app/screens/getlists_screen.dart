// ignore_for_file: public_member_api_docs, always_specify_types

import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/services/board_service.dart';
import 'package:flutter_trell_app/app/widgets/button_create_list.dart';
import 'package:flutter_trell_app/app/widgets/getonelist_widget.dart';

class GetListWidget extends StatefulWidget {
  const GetListWidget({required this.boardId, super.key});

  final String boardId;

  @override
  GetListWidgetState createState() => GetListWidgetState();
}

class GetListWidgetState extends State<GetListWidget> {
  final BoardService _boardService = BoardService();

  @override
  void initState() {
    super.initState();
    _boardService.fetchBoardData(widget.boardId);
  }

  @override
  void dispose() {
    _boardService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _boardService.boardStream,
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!['lists'].isEmpty) {
            return const Center(child: Text('Aucune liste trouvée'));
          }

          final lists = snapshot.data!['lists'];
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
                      refreshLists: () => _boardService.fetchBoardData(widget.boardId),
                      boardId: widget.boardId,
                    ),
                  );
                }),
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
