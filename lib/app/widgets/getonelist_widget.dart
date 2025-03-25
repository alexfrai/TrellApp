import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_trell_app/app/services/get_member_card.dart';
import 'package:flutter_trell_app/app/services/list_service.dart';
import 'package:flutter_trell_app/app/widgets/cards_modal.dart';
import 'package:flutter_trell_app/app/widgets/cards_new.dart';
import 'package:flutter_trell_app/app/widgets/menulist/menulist_widget.dart';

/// Widget to display a single list with its cards.
class GetOneListWidget extends StatefulWidget {
  const GetOneListWidget({
    required this.list,
    required this.refreshLists,
    required this.boardId,
    super.key,
  });

  /// Parameters
  final Map<String, dynamic> list;
  final VoidCallback refreshLists;
  final String boardId;

  @override
  GetOneListWidgetState createState() => GetOneListWidgetState();
}

/// List of colors for members
List<Color> memberColors = <Color>[
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.yellow,
];

/// Get a member color based on index
Color getMemberColor(int index) {
  return memberColors[index % memberColors.length];
}

/// State for GetOneListWidget
class GetOneListWidgetState extends State<GetOneListWidget> {
  final GetMemberCardService _memberService = GetMemberCardService();
  final StreamController<List<Map<String, dynamic>>> _cardsStreamController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  List<Map<String, dynamic>>? _lastCards;

  /// Cards in the list
  List<Map<String, dynamic>> cards = <Map<String, dynamic>>[];

  /// Loading state
  bool isLoading = false;

  /// Editing state
  bool isEditingName = false;

  /// Focus node for text field
  late FocusNode focusNode;

  /// Controller for list name text field
  late TextEditingController listNameController;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    listNameController = TextEditingController(text: widget.list['name']);
    focusNode.addListener(_onFocusChange);
    unawaited(_getCardsInList());

    // Periodic refresh
    Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (mounted) {
        unawaited(_getCardsInList());
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    focusNode.removeListener(_onFocusChange);
    listNameController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!focusNode.hasFocus) {
      unawaited(_updateListName(listNameController.text));
    }
  }

  Future<void> _updateListName(String newName) async {
    if (newName.isNotEmpty && newName != widget.list['name']) {
      try {
        await ListService.updateListName(widget.list['id'], newName);
        setState(() {
          widget.list['name'] = newName;
        });
      } catch (error) {
        debugPrint('Error updating list name: $error');
      }
    }
    setState(() => isEditingName = false);
  }

  Future<void> _createNewCard() async {
    final dynamic newCard = await showDialog(
      context: context,
      builder: (BuildContext context) => CardsNew(id: widget.list['id']),
    );
    if (newCard != null) {
      unawaited(_getCardsInList());
    }
  }

  Future<void> _getCardsInList() async {
    if (_lastCards == null) {
      setState(() => isLoading = true);
    }

    try {
      final http.Response response = await http.get(
        Uri.parse(
          'https://api.trello.com/1/lists/${widget.list['id']}/cards?members=true&key=$apiKey&token=$apiToken',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Map<String, dynamic>> newCards = data.map((dynamic card) {
          return <String, dynamic>{
            'id': card['id'],
            'name': card['name'],
            'desc': card['desc'] ?? '',
          };
        }).toList();

        // Check if cards have changed before emitting a new state
        if (_lastCards == null || !_listEquals(newCards, _lastCards!)) {
          _cardsStreamController.add(newCards);
          setState(() {
            cards = newCards;
          });
          _lastCards = newCards;
        }
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('❌ Error loading cards: $error');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  /// Function to compare lists and avoid unnecessary updates
  bool _listEquals(List<Map<String, dynamic>> list1, List<Map<String, dynamic>> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i]['id'] != list2[i]['id'] || list1[i]['desc'] != list2[i]['desc']) {
        return false;
      }
    }
    return true;
  }

  void _showModal(BuildContext context, RenderBox button) {
    final Offset position = button.localToGlobal(Offset.zero);
    final double screenWidth = MediaQuery.of(context).size.width;

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Stack(
          children: [
            // Capture taps to close the modal
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  overlayEntry.remove();
                },
                behavior: HitTestBehavior.translucent,
              ),
            ),
            // Modal
            ModalListWidget(
              listId: widget.list['id'],
              boardId: widget.boardId,
              refreshLists: widget.refreshLists,
              position: position,
              screenWidth: screenWidth,
              closeModal: () {
                overlayEntry.remove();
              },
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(113, 117, 104, 1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isEditingName = true;
                    });
                  },
                  child: isEditingName
                      ? TextField(
                          controller: listNameController,
                          autofocus: true,
                          focusNode: focusNode,
                          onSubmitted: (String newName) =>
                              unawaited(_updateListName(newName)),
                          onEditingComplete: () {
                            unawaited(_updateListName(listNameController.text));
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            fillColor: Colors.white24,
                            filled: true,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        )
                      : Text(
                          widget.list['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
                        future: _memberService.getMembersCard(card['id']),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                          final List<Map<String, dynamic>> members =
                              snapshot.data ?? <Map<String, dynamic>>[];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 8,
                            ),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(186, 203, 169,1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white12),
                                boxShadow: <BoxShadow>[
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
                                        children: List<Widget>.generate(
                                            members.length, (int memberIndex) {
                                          return CircleAvatar(
                                            backgroundColor:
                                                getMemberColor(memberIndex),
                                            child: Text(
                                              members[memberIndex]['username'][0]
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
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
                                        descriptionName: card['desc'] ?? '',
                                        selectedCardId: card['id'],
                                        handleClose: () => Navigator.pop(context),
                                        onCardUpdated: (String cardId,
                                            String newDesc) {
                                          setState(() {
                                            final int cardIndex = cards.indexWhere(
                                                (Map<String, dynamic> c) =>
                                                    c['id'] == cardId);
                                            if (cardIndex != -1) {
                                              cards[cardIndex]['desc'] = newDesc;
                                            }
                                          });
                                          widget.refreshLists();
                                        },
                                        onCardDeleted: (String cardId) {
                                          setState(() {
                                            cards.removeWhere(
                                                (Map<String, dynamic> c) =>
                                                    c['id'] == cardId);
                                          });
                                        },
                                        listId: widget.list['id'],
                                        boardId: widget.boardId,
                                        cardId: card['id'],
                                        refreshLists: widget.refreshLists,
                                        checklistId: '',
                                        checklistName: '',
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
                    backgroundColor: const Color.fromRGBO(63, 71, 57,1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
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
          Positioned(
            top: 0,
            right: 0,
            child: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {
                    final RenderBox button =
                        context.findRenderObject() as RenderBox;
                    _showModal(context, button);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
