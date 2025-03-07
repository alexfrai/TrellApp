import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/widgets/cards_modal.dart';
import 'package:flutter_trell_app/app/widgets/cards_new.dart';

class GetOneListWidget extends StatefulWidget {
  const GetOneListWidget({
    required this.list,
    required this.cards,
    required this.refreshLists,
    required this.boardId, // Ajoutez boardId ici
    super.key,
  });

  final Map<String, dynamic> list;
  final List<Map<String, dynamic>> cards;
  final VoidCallback refreshLists;
  final String boardId; // Ajoutez boardId ici

  @override
  _GetOneListWidgetState createState() => _GetOneListWidgetState();
}

class _GetOneListWidgetState extends State<GetOneListWidget> {
  Future<void> _createNewCard() async {
    final newCard = await showDialog(
      context: context,
      builder: (BuildContext context) => CardsNew(id: widget.list['id']),
    );
    if (newCard != null) {
      setState(() {
        widget.cards.add(newCard);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF3D1308),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Text(
              widget.list['name'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (widget.cards.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: widget.cards.length,
                itemBuilder: (BuildContext context, int index) {
                  final Map<String, dynamic> card = widget.cards[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFF7B0D1E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(2, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          card['name'],
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        onTap: () async {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CardsModal(
                                taskName: card['name'],
                                selectedCardId: card['id'],
                                handleClose: () => Navigator.pop(context),
                                onCardUpdated: (String cardId, String newName) {
                                  setState(() {
                                    final int cardIndex = widget.cards.indexWhere((c) => c['id'] == cardId);
                                    if (cardIndex != -1) {
                                      widget.cards[cardIndex]['name'] = newName;
                                    }
                                  });
                                },
                                onCardDeleted: (String cardId) {
                                  setState(() {
                                    widget.cards.removeWhere((c) => c['id'] == cardId);
                                  });
                                },
                                listId: widget.list['id'],
                                boardId: widget.boardId, // Passez boardId ici
                              );
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Aucune carte dans cette liste',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ),
          const SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              onPressed: _createNewCard,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9F2042),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Ajouter une carte'),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
