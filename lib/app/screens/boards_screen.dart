import 'package:flutter/material.dart';

class BoardScreen extends StatelessWidget {
  final String? boardId;
  final String? cardId;
  final String? cardName;

  BoardScreen({this.boardId, this.cardId, this.cardName});

  @override
  Widget build(BuildContext context) {
    // Ajoutez des logs pour vérifier les arguments
    print('Board ID: $boardId');
    print('Card ID: $cardId');
    print('Card Name: $cardName');

    return Scaffold(
      appBar: AppBar(
        title: Text('Board Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Board ID: $boardId'),
            Text('Card ID: $cardId'),
            Text('Card Name: $cardName'),
          ],
        ),
      ),
    );
  }
}
