
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/services/get_member_card.dart'; 
import 'package:flutter_trell_app/app/widgets/cards_modal.dart';
import 'package:flutter_trell_app/app/widgets/cards_new.dart';
import 'package:http/http.dart' as http;

///getonelist
class GetOneListWidget extends StatefulWidget {
  ///valeures d'entrée
  const GetOneListWidget({
    required this.list,
    required this.refreshLists,
    required this.boardId,
    super.key,
  });
  ///liste des list
  final Map<String, dynamic> list;
  ///callback de la list
  final VoidCallback refreshLists;
  ///id du board 
  final String boardId;

  @override
  // ignore: library_private_types_in_public_api
  _GetOneListWidgetState createState() => _GetOneListWidgetState();
}
///liste de couleurs
List<Color> memberColors = <Color>[
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.yellow,
];

/// fonction pour prendre une couleur
Color getMemberColor(int index) {
  return memberColors[index % memberColors.length];
}

class _GetOneListWidgetState extends State<GetOneListWidget> {
  final GetMemberCardService _memberService = GetMemberCardService();
  List<Map<String, dynamic>> cards = <Map<String, dynamic>>[];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    unawaited(_getCardsInList());
  }

  Future<void> _createNewCard() async {
    final Card newCard = await showDialog(
      context: context,
      builder: (BuildContext context) => CardsNew(id: widget.list['id']),
    );
    if (newCard != null) {
      unawaited(_getCardsInList()); // 🔄 Rafraîchit les cartes après ajout
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
          cards = data.map((dynamic card) {
            return <String, dynamic>{
              'id': card['id'],
              'name': card['name'],
              'desc': card['desc'] ?? '',
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
        boxShadow: <BoxShadow>[
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: cards.length,
                itemBuilder: (BuildContext context, int index) {
                  final Map<String, dynamic> card = cards[index];

                  return FutureBuilder<List<Map<String, dynamic>>>(
                    // ignore: discarded_futures
                    future: _memberService.getMembersCard(card['id']),
                    builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                      final List<Map<String, dynamic>> members = snapshot.data ?? <Map<String, dynamic>>[];

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
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                // ignore: deprecated_member_use
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
                                    children: List.generate(members.length, (int memberIndex) {
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
                                        final int cardIndex = cards.indexWhere((Map<String, dynamic> c) => c['id'] == cardId);
                                        if (cardIndex != -1) {
                                          cards[cardIndex]['desc'] = newDesc;
                                        }
                                      });
                                      _getCardsInList();
                                    },
                                    onCardDeleted: (String cardId) {
                                      setState(() {
                                        cards.removeWhere((Map<String, dynamic> c) => c['id'] == cardId);
                                      });
                                    },
                                    listId: widget.list['id'],
                                    boardId: widget.boardId,
                                    cardId: card['id'],
                                    refreshLists: widget.refreshLists,
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
