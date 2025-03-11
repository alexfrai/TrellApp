// ignore_for_file: library_private_types_in_public_api, public_member_api_docs, deprecated_member_use, always_specify_types

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/services/get_member_card.dart'; 
import 'package:flutter_trell_app/app/widgets/cards_modal.dart';
import 'package:flutter_trell_app/app/widgets/cards_new.dart';
import 'package:http/http.dart' as http;

class GetOneListWidget extends StatefulWidget {
  const GetOneListWidget({
    required this.list,
    required this.refreshLists,
    required this.boardId,
    super.key,
  });

  final Map<String, dynamic> list;
  final VoidCallback refreshLists;
  final String boardId;

  @override
  _GetOneListWidgetState createState() => _GetOneListWidgetState();
}

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

class _GetOneListWidgetState extends State<GetOneListWidget> {
  final GetMemberCardService _memberService = GetMemberCardService();
  List<Map<String, dynamic>> cards = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCardsInList();
  }

  Future<void> _createNewCard() async {
    final newCard = await showDialog(
      context: context,
      builder: (BuildContext context) => CardsNew(id: widget.list['id']),
    );
    if (newCard != null) {
      _getCardsInList(); // 🔄 Rafraîchit les cartes après ajout
    }
  }

  Future<void> _getCardsInList() async {
    setState(() => isLoading = true);

    try {
      final http.Response response = await http.get(
        Uri.parse(
          'https://api.trello.com/1/lists/${widget.list['id']}/cards?members=true&key=$apiKey&token=$apiToken',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          cards = data.map((card) {
            return {
              'id': card['id'],
              'name': card['name'],
              'desc': card['desc'] ?? "",
            };
          }).toList();
        });
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('❌ Erreur lors du chargement des cartes: $error');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
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
        mainAxisSize: MainAxisSize.min,
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
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (cards.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Aucune carte dans cette liste',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: cards.length,
                itemBuilder: (BuildContext context, int index) {
                  final Map<String, dynamic> card = cards[index];

                  return FutureBuilder<List<Map<String, dynamic>>>(
                    // ignore: discarded_futures
                    future: _memberService.getMembersCard(card['id']),
                    builder: (context, snapshot) {
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(2, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: members.isNotEmpty
                                ? Wrap(
                                    spacing: 4,
                                    children: List.generate(members.length, (memberIndex) {
                                      return CircleAvatar(
                                        backgroundColor: getMemberColor(memberIndex),
                                        child: Text(
                                          members[memberIndex]['username'][0].toUpperCase(),
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      );
                                    }),
                                  )
                                : const SizedBox(width: 40, height: 40), 
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
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
                                    descriptionName: card['desc'] ?? '',
                                    selectedCardId: card['id'],
                                    handleClose: () => Navigator.pop(context),
                                    onCardUpdated: (String cardId, String newDesc) {
                                      setState(() {
                                        final int cardIndex = cards.indexWhere((c) => c['id'] == cardId);
                                        if (cardIndex != -1) {
                                          cards[cardIndex]['desc'] = newDesc;
                                        }
                                      });
                                      _getCardsInList();
                                    },
                                    onCardDeleted: (String cardId) {
                                      setState(() {
                                        cards.removeWhere((c) => c['id'] == cardId);
                                      });
                                    },
                                    listId: widget.list['id'],
                                    boardId: widget.boardId,
                                    cardId: card['id'], // ✅ Ajout du paramètre manquant
                                    refreshLists: widget.refreshLists, // ✅ Ajout du paramètre manquant
                                  );
                                },
                              );
                            },

                          ),
                        ),
                      );
                    },
                  );
                },
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
