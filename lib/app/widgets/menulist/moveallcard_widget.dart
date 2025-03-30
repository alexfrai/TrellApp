import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/services/get_all_cards.dart';
import 'package:flutter_trell_app/app/services/list_service.dart';

/// Widget pour déplacer toutes les cartes
class MoveAllCardsWidget extends StatefulWidget {
  ///required parameter
  const MoveAllCardsWidget({
    required this.sourceListId,
    required this.boardId,
    required this.onMoveSuccess,
    super.key,
  });

  ///list id
  final String sourceListId;

  /// board id
  final String boardId;

  /// callback move
  final VoidCallback onMoveSuccess;

  @override
  MoveListWidgetState createState() => MoveListWidgetState();
}

///move state
class MoveListWidgetState extends State<MoveAllCardsWidget> {
  bool _loading = false;
  bool _loadingCards = true;
  String? _error;
  List<Map<String, dynamic>> _targetLists = <Map<String, dynamic>>[];
  int? _selectedTargetIndex;
  int _cardCount = 0;
  List<Map<String, dynamic>> _cardsToMove = <Map<String, dynamic>>[];
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _selectedTargetIndex = null;
    unawaited(_fetchTargetLists());
    unawaited(_fetchCards());
  }

  @override
  void dispose() {
    _hideDropdown();
    super.dispose();
  }

  Future<void> _fetchTargetLists() async {
    try {
      final List<Map<String, dynamic>> targetLists =
          await ListService.getAllLists(widget.boardId);
      if (mounted) {
        setState(() {
          _targetLists = targetLists;
          _selectedTargetIndex = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erreur lors du chargement des listes : $e';
        });
      }
    }
  }

  Future<void> _fetchCards() async {
    try {
      final List<Map<String, dynamic>> cards = await CardService.getAllCards(
        <dynamic>[
          <String, String>{'id': widget.sourceListId},
        ],
      );
      if (mounted) {
        setState(() {
          _cardsToMove = cards;
          _cardCount = cards.length;
          _loadingCards = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erreur lors du chargement des cartes : $e';
          _loadingCards = false;
        });
      }
    }
  }

  Future<void> _moveAllCards() async {
    if (_selectedTargetIndex == null || _loading || _cardsToMove.isEmpty)
      return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final String targetListId = _targetLists[_selectedTargetIndex!]['id'];

    try {
      await ListService.updateCardsList(_cardsToMove, targetListId);
      widget
          .onMoveSuccess(); // Appelle le callback pour réactualiser les données
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du déplacement des cartes : $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _toggleDropdown() {
    if (_overlayEntry == null) {
      _showDropdown();
    } else {
      _hideDropdown();
    }
  }

  void _showDropdown() {
    if (_overlayEntry != null)
      return; // Ne crée pas un nouvel overlay si un existe déjà.

    _overlayEntry = OverlayEntry(
      builder:
          (BuildContext context) => Positioned(
            width: 200,
            child: CompositedTransformFollower(
              link: _layerLink,
              offset: const Offset(0, 40),
              child: Material(
                color: Colors.grey[800],
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List<Widget>.generate(_targetLists.length, (
                        int index,
                      ) {
                        final bool isCurrentList =
                            _targetLists[index]['id'] == widget.sourceListId;
                        return ListTile(
                          title: Text(
                            _targetLists[index]['name'],
                            style: TextStyle(
                              color:
                                  isCurrentList
                                      ? Colors.grey
                                      : index == _selectedTargetIndex
                                      ? Colors.white
                                      : Colors.white,
                            ),
                          ),
                          onTap:
                              isCurrentList
                                  ? null
                                  : () {
                                    setState(() {
                                      _selectedTargetIndex = index;
                                    });
                                    _hideDropdown();
                                  },
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
    Overlay.of(context)?.insert(_overlayEntry!);
  }

  void _hideDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Move All Cards',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child:
                  _loadingCards
                      ? const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      )
                      : Text(
                        '$_cardCount card${_cardCount > 1 ? 's' : ''} to move',
                        style: const TextStyle(color: Colors.white),
                      ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            CompositedTransformTarget(
              link: _layerLink,
              child: GestureDetector(
                onTap: _toggleDropdown,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        _selectedTargetIndex == null
                            ? 'Select Target List'
                            : _targetLists[_selectedTargetIndex!]['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton(
                  onPressed: _loading ? null : _moveAllCards,
                  style: TextButton.styleFrom(foregroundColor: Colors.blue),
                  child: Text(_loading ? 'Moving...' : 'Move'),
                ),
                TextButton(
                  onPressed: widget.onMoveSuccess,
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
