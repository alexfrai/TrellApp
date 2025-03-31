import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/services/list_service.dart';
import 'package:flutter_trell_app/app/widgets/menulist/moveallcard_widget.dart';
import 'package:flutter_trell_app/app/widgets/menulist/movelist_widget.dart';

///modal
class ModalListWidget extends StatefulWidget {
  ///parametres
  const ModalListWidget({
    required this.listId,
    required this.boardId,
    required this.refreshLists,
    required this.position,
    required this.positions,
    required this.screenWidth,
    required this.closeModal,
    super.key,
  });

  ///list id
  final String listId;

  ///id du board
  final String boardId;

  ///refrsh
  final VoidCallback refreshLists;

  ///position actuelle
  final Offset position;

  ///screenwitdh
  final double screenWidth;

  ///close
  final VoidCallback closeModal;

  ///list positions
  final List<double> positions;

  @override
  ModalListWidgetState createState() => ModalListWidgetState();
}

///modal
class ModalListWidgetState extends State<ModalListWidget> {
  bool _isMoveListOpen = false;
  bool _isMoveAllCardsOpen = false;
  List<double> _positions = <double>[];
  Offset? _moveListPosition;
  Offset? _moveAllCardsPosition;
  bool _isHoveredCopy = false;
  bool _isHoveredMoveList = false;
  bool _isHoveredMoveCards = false;
  bool _isHoveredArchive = false;
  bool _isConfirmationOpen = false;

  @override
  void initState() {
    super.initState();
    unawaited(_fetchPositions());
  }

  Future<void> _fetchPositions() async {
    try {
      final List<double> positions = widget.positions;
      setState(() {
        _positions = positions;
      });
    } catch (e) {
      throw Exception('Erreur lors du chargement des positions : $e');
    }
  }

  void _copyList() {
    widget.closeModal();
  }

  void _moveList(TapDownDetails details) {
    setState(() {
      _isMoveListOpen = true;
      _isMoveAllCardsOpen = false;
      _moveListPosition = details.localPosition;
    });
  }

  void _moveAllCards() {
    setState(() {
      _isMoveAllCardsOpen = true;
      _isMoveListOpen = false;
      _moveAllCardsPosition = widget.position;
    });
  }

  void _archiveList() {
    setState(() {
      _isConfirmationOpen = true;
    });
  }

  Future<void> _confirmArchiveList() async {
    try {
      // Appeler le service pour archiver la liste
      await ListService.archiveList(widget.listId);
      // Rafraîchir les listes après l'archivage
      widget.refreshLists();
      widget.closeModal();
    } catch (e) {
      // Vous pouvez gérer les erreurs ici si l'archivage échoue
      throw Exception("Erreur lors de l'archivage : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const double modalWidth = 200;
    final double rightSpace = widget.screenWidth - widget.position.dx;
    final double leftPosition =
        (rightSpace > modalWidth + 20)
            ? widget.position.dx + 40
            : widget.position.dx - modalWidth - 10;
    final double moveListLeftPosition =
        (rightSpace > modalWidth + 20)
            ? widget.position.dx + 210
            : widget.position.dx - modalWidth - 10;

    return Stack(
      children: <Widget>[
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
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
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
                    child: ColoredBox(
                      color:
                          _isHoveredCopy
                              ? Colors.grey.withValues(alpha: .2)
                              : Colors.transparent,
                      child: ListTile(
                        title: const Text(
                          'Copy list',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        leading: const Icon(
                          Icons.copy,
                          color: Colors.white,
                          size: 20,
                        ),
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
                    child: ColoredBox(
                      color:
                          _isHoveredMoveList
                              ? Colors.grey.withValues(alpha: .2)
                              : Colors.transparent,
                      child: GestureDetector(
                        onTapDown: _moveList,
                        child: ListTile(
                          title: const Text(
                            'Move List',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          leading: const Icon(
                            Icons.swap_horiz,
                            color: Colors.white,
                            size: 20,
                          ),
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
                    child: ColoredBox(
                      color:
                          _isHoveredMoveCards
                              ? Colors.grey.withValues(alpha: .2)
                              : Colors.transparent,
                      child: ListTile(
                        title: const Text(
                          'Move cards',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        leading: const Icon(
                          Icons.list_alt,
                          color: Colors.white,
                          size: 20,
                        ),
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
                    child: ColoredBox(
                      color:
                          _isHoveredArchive
                              ? Colors.grey.withValues(alpha: .2)
                              : Colors.transparent,
                      child: ListTile(
                        title: const Text(
                          'Archive',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        leading: const Icon(
                          Icons.archive,
                          color: Colors.white,
                          size: 20,
                        ),
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
            left: moveListLeftPosition,
            top: widget.position.dy + _moveListPosition!.dy + 50,
            child: SizedBox(
              width: 200,
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
            left: moveListLeftPosition,
            top: widget.position.dy + 125,
            child: SizedBox(
              width: 200,
              child: MoveAllCardsWidget(
                sourceListId: widget.listId,
                boardId: widget.boardId,
                onMoveSuccess: () {
                  widget.refreshLists();
                  widget.closeModal();
                },
              ),
            ),
          ),
        if (_isConfirmationOpen)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black.withValues(alpha: .8),
              child: Center(
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .2),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text(
                        'Do you want archive it?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          decoration:
                              TextDecoration
                                  .none, // Retirer le soulignement ici
                        ),
                      ),

                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          TextButton(
                            style: TextButton.styleFrom(
                              textStyle: TextStyle(
                                decoration: TextDecoration.none,
                              ), // Retirer le soulignement
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmationOpen = false;
                              });
                            },
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            onPressed: _confirmArchiveList,
                            child: const Text('Confirm'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
