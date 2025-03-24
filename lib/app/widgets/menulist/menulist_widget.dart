import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/services/list_service.dart';
import 'package:flutter_trell_app/app/widgets/menulist/moveallcard_widget.dart';
import 'package:flutter_trell_app/app/widgets/menulist/movelist_widget.dart';

///modal de la list
class ModalListWidget extends StatefulWidget {
  ///parametres
  const ModalListWidget({
    required this.listId,
    required this.boardId,
    required this.refreshLists,
    required this.position,
    required this.screenWidth,
    required this.closeModal,
    super.key,
  });
  /// listID
  final String listId;
  ///Voard id
  final String boardId;
  ///Callback refresh
  final VoidCallback refreshLists;
  ///position
  final Offset position;
  ///largeyr screan
  final double screenWidth;
  ///close callback
  final VoidCallback closeModal;

  @override
  _ModalListWidgetState createState() => _ModalListWidgetState();
}

class _ModalListWidgetState extends State<ModalListWidget> {
  bool _isMoveListOpen = false;
  bool _isMoveAllCardsOpen = false; // Ajouter un nouvel état pour MoveAllCards
  List<double> _positions = [];
  Offset? _moveListPosition;
  Offset? _moveAllCardsPosition;

  // Variables pour détecter les hover sur les boutons
  bool _isHoveredCopy = false;
  bool _isHoveredMoveList = false;
  bool _isHoveredMoveCards = false;
  bool _isHoveredArchive = false;

  @override
  void initState() {
    super.initState();
    _fetchPositions();
  }

  Future<void> _fetchPositions() async {
    try {
      final List<double> positions = await ListService.getAllListPositions(widget.boardId);
      setState(() {
        _positions = positions;
      });
    } catch (e) {
      print("Erreur lors du chargement des positions : $e");
    }
  }

  void _copyList() {
    print('Copier la liste');
    widget.closeModal();
  }

  void _moveList(TapDownDetails details) {
    setState(() {
      _isMoveListOpen = true;
      _isMoveAllCardsOpen = false; // Fermer MoveAllCardsWidget si MoveListWidget est ouvert
      _moveListPosition = details.localPosition; // Local position du bouton, pas global
    });
  }

  void _moveAllCards() {
    setState(() {
      _isMoveAllCardsOpen = true; // Ouvrir le MoveAllCardsWidget
      _isMoveListOpen = false; // Fermer MoveListWidget si MoveAllCardsWidget est ouvert
      _moveAllCardsPosition = widget.position; // Position de départ pour MoveAllCardsWidget
    });
  }

  void _archiveList() {
    ListService.ArchiveList(widget.listId);
    widget.closeModal();
  }

  @override
  Widget build(BuildContext context) {
    final double modalWidth = 200;
    final double rightSpace = widget.screenWidth - widget.position.dx;
    final double leftPosition = (rightSpace > modalWidth + 20)
        ? widget.position.dx + 40
        : widget.position.dx - modalWidth - 10;

    // Calcul de la position en fonction de l'espace disponible à gauche ou à droite
    final double moveListLeftPosition = (rightSpace > modalWidth + 20)
        ? widget.position.dx + 210 // Position à droite du bouton
        : widget.position.dx - modalWidth - 10; // Position à gauche du bouton

    return Stack(
      children: [
        Positioned(
          left: leftPosition,
          top: widget.position.dy + 10,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: modalWidth,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Liste',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        _isHoveredCopy = true;
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        _isHoveredCopy = false;
                      });
                    },
                    child: Container(
                      color: _isHoveredCopy ? Colors.grey.withOpacity(0.2) : Colors.transparent, // Fond gris clair
                      child: ListTile(
                        title: const Text('Copy list', style: TextStyle(color: Colors.white, fontSize: 14)),
                        leading: const Icon(Icons.copy, color: Colors.white, size: 20),
                        onTap: _copyList,
                        dense: true,
                      ),
                    ),
                  ),
                  MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        _isHoveredMoveList = true;
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        _isHoveredMoveList = false;
                      });
                    },
                    child: Container(
                      color: _isHoveredMoveList ? Colors.grey.withOpacity(0.2) : Colors.transparent, // Fond gris clair
                      child: GestureDetector(
                        onTapDown: _moveList,
                        child: ListTile(
                          title: const Text('Move List', style: TextStyle(color: Colors.white, fontSize: 14)),
                          leading: const Icon(Icons.swap_horiz, color: Colors.white, size: 20),
                          dense: true,
                        ),
                      ),
                    ),
                  ),
                  MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        _isHoveredMoveCards = true;
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        _isHoveredMoveCards = false;
                      });
                    },
                    child: Container(
                      color: _isHoveredMoveCards ? Colors.grey.withOpacity(0.2) : Colors.transparent, // Fond gris clair
                      child: ListTile(
                        title: const Text('Move cards', style: TextStyle(color: Colors.white, fontSize: 14)),
                        leading: const Icon(Icons.list_alt, color: Colors.white, size: 20),
                        onTap: _moveAllCards,
                        dense: true,
                      ),
                    ),
                  ),
                  MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        _isHoveredArchive = true;
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        _isHoveredArchive = false;
                      });
                    },
                    child: Container(
                      color: _isHoveredArchive ? Colors.grey.withOpacity(0.2) : Colors.transparent, // Fond gris clair
                      child: ListTile(
                        title: const Text('Archive', style: TextStyle(color: Colors.white, fontSize: 14)),
                        leading: const Icon(Icons.archive, color: Colors.white, size: 20),
                        onTap: _archiveList,
                        dense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isMoveListOpen && _moveListPosition != null)
          Positioned(
            left: moveListLeftPosition, // Utilisation de la nouvelle position calculée
            top: widget.position.dy + _moveListPosition!.dy + 50, // Même position verticale
            child: SizedBox(
              width: 200, // Largeur du MoveListWidget
              child: MoveListWidget(
                listId: widget.listId,
                positions: _positions,
                onMoveSuccess: () {
                  widget.refreshLists();
                  widget.closeModal();
                },
                onCancel: () {
                  setState(() {
                    _isMoveListOpen = false;
                  });
                },
              ),
            ),
          ),
       if (_isMoveAllCardsOpen && _moveAllCardsPosition != null)
  Positioned(
    left: moveListLeftPosition, // Décale à droite du bouton de déplacement de la liste
    top: widget.position.dy +125,  // Ajuste la position verticale pour la mettre à droite du bouton
    child: SizedBox(
      width: 200, // Largeur du MoveAllCardsWidget
      child: MoveAllCardsWidget(
        sourceListId: widget.listId, // ID de la liste source
        boardId: widget.boardId, // Passe le boardId ici
        onMoveSuccess: () {
          widget.refreshLists();
          widget.closeModal();
        },
      ),
    ),
  ),


      ],
    );
  }
}

