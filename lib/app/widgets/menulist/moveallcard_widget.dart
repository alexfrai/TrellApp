import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/services/get_all_cards.dart';
import 'package:flutter_trell_app/app/services/list_service.dart';

/// Widget pour déplacer toutes les cartes
class MoveAllCardsWidget extends StatefulWidget {
  /// Constructeur
  const MoveAllCardsWidget({
    required this.sourceListId,
    required this.boardId,
    required this.onMoveSuccess,
    super.key,
  });

  /// ID de la liste source
  final String sourceListId;

  /// ID du tableau
  final String boardId;

  /// Callback de succès
  final VoidCallback onMoveSuccess;

  @override
  MoveListWidgetState createState() => MoveListWidgetState();
}

/// État du widget
class MoveListWidgetState extends State<MoveAllCardsWidget> {
  bool _loading = false;
  bool _loadingCards = true;
  String? _error;
  List<Map<String, dynamic>> _targetLists = <Map<String, dynamic>>[];
  int? _selectedTargetIndex;
  int _cardCount = 0;
  List<Map<String, dynamic>> _cardsToMove = []; // Stockage des cartes
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

@override
void initState() {
  super.initState();
  _selectedTargetIndex = null; // Initialiser à null pour ne pas sélectionner la première liste par défaut
  unawaited(_fetchTargetLists());
  unawaited(_fetchCards());
}

  @override
  void dispose() {
    _hideDropdown(); // Ferme le dropdown s'il est ouvert
    super.dispose();
  }

  /// Récupère les listes cibles
Future<void> _fetchTargetLists() async {
  try {
    final List<Map<String, dynamic>> targetLists =
        await ListService.getAllLists(widget.boardId);
    setState(() {
      _targetLists = targetLists;
      // Ne pas sélectionner une liste par défaut
      _selectedTargetIndex = null; // Ne pas initialiser à 0 ici
    });
  } catch (e) {
    setState(() {
      _error = 'Erreur lors du chargement des listes : $e';
    });
  }
}

  /// Récupère les cartes de la liste source et les stocke
  Future<void> _fetchCards() async {
    try {
      final List<Map<String, dynamic>> cards =
          await CardService.getAllCards([{'id': widget.sourceListId}]);
      setState(() {
        _cardsToMove = cards;
        _cardCount = cards.length;
        _loadingCards = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement des cartes : $e';
        _loadingCards = false;
      });
    }
  }

  /// Déplace toutes les cartes stockées
  Future<void> _moveAllCards() async {
    if (_selectedTargetIndex == null || _loading || _cardsToMove.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final String targetListId = _targetLists[_selectedTargetIndex!]['id'];

    try {
      print('Déplacement des cartes vers la liste cible : $targetListId');
       await ListService.updateCardsList(_cardsToMove, targetListId);
      

      widget.onMoveSuccess();
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du déplacement des cartes : $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
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
  _overlayEntry = OverlayEntry(
    builder: (BuildContext context) => Positioned(
      width: 200,
      child: CompositedTransformFollower(
        link: _layerLink,
        offset: const Offset(0, 40),
        child: Material(
          color: Colors.grey[800],
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List<Widget>.generate(_targetLists.length, (int index) {
                  // Vérifie si c'est la liste source pour griser l'élément
                  bool isCurrentList = _targetLists[index]['id'] == widget.sourceListId;
                  
                  return ListTile(
                    title: Text(
                      _targetLists[index]['name'],
                      style: TextStyle(
                        color: isCurrentList
                            ? Colors.grey // Griser la liste source
                            : index == _selectedTargetIndex
                                ? Colors.white // Enlever la couleur verte
                                : Colors.white, // Couleur par défaut
                      ),
                    ),
                    onTap: isCurrentList
                        ? null // Empêche la sélection de la liste source
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
  Overlay.of(context).insert(_overlayEntry!);
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
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),

            // Affichage du nombre de cartes
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _loadingCards
                  ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
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

            // Dropdown de sélection de liste cible
            CompositedTransformTarget(
              link: _layerLink,
              child: GestureDetector(
                onTap: _toggleDropdown,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
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
                        style: const TextStyle(color: Colors.white, fontSize: 16),
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
