// ignore_for_file: public_member_api_docs, library_private_types_in_public_api, always_specify_types

import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/services/get_member_card.dart';
import 'package:flutter_trell_app/app/widgets/cards_modal.dart';
import 'package:flutter_trell_app/app/widgets/cards_new.dart';

class CardsWidget extends StatefulWidget {
  const CardsWidget({
    required this.listId,
    required this.boardId,
    required this.cardId,
    required this.cards,
    required this.refreshLists,
    super.key,
  });

  final String listId;
  final String boardId;
  final String cardId;
  final List<Map<String, dynamic>> cards;
  final VoidCallback refreshLists;

  @override
  _CardsWidgetState createState() => _CardsWidgetState();
}

class _CardsWidgetState extends State<CardsWidget> {
  final GetMemberCardService _memberService = GetMemberCardService();

  List<Color> memberColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
  ];

  Color getMemberColor(int index) {
    return memberColors[index % memberColors.length];
  }

  Future<void> _createNewCard() async {
    final newCard = await showDialog(
      context: context,
      builder: (BuildContext context) => CardsNew(id: widget.listId),
    );
    if (newCard != null) {
      setState(() {
        widget.cards.add(newCard);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.cards.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: widget.cards.length,
              itemBuilder: (BuildContext context, int index) {
                final Map<String, dynamic> card = widget.cards[index];
                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: _memberService.getMembersCard(card['id']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(
                        title: Text(card['name']),
                        leading: const CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return ListTile(
                        title: Text(card['name']),
                        leading: const Icon(Icons.error),
                      );
                    } else {
                      final members = snapshot.data ?? [];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 8,
                        ),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0xFF7B0D1E),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: ListTile(
                            leading: members.isNotEmpty
                                ? Wrap(
                                    spacing: 4,
                                    children: List.generate(
                                      members.length,
                                      (memberIndex) {
                                        return CircleAvatar(
                                          backgroundColor: getMemberColor(memberIndex),
                                          child: Text(
                                            members[memberIndex]['username'][0]
                                                .toUpperCase(),
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Container(width: 40, height: 40, color: Colors.transparent),
                            title: Text(
                              card['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () async {
                              await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CardsModal(
                                    taskName: card['name'],
                                    descriptionName: card['desc'] ?? "",
                                    selectedCardId: card['id'],
                                    handleClose: () => Navigator.pop(context),
                                    onCardUpdated: (String cardId, String newDesc) {
                                      setState(() {
                                        final int cardIndex = widget.cards.indexWhere(
                                            (c) => c['id'] == cardId);
                                        if (cardIndex != -1) {
                                          widget.cards[cardIndex]['desc'] = newDesc;
                                        }
                                      });
                                      widget.refreshLists();
                                    },
                                    onCardDeleted: (String cardId) {
                                      setState(() {
                                        widget.cards.removeWhere((c) => c['id'] == cardId);
                                      });
                                    },
                                    listId: widget.listId,
                                    boardId: widget.boardId,
                                    cardId: widget.cardId,
                                    refreshLists: widget.refreshLists, checklistId: '', checklistName: '',
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      );
                    }
                  },
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
      ],
    );
  }
}
