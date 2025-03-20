import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/services/list_service.dart';


class ModalListWidget extends StatefulWidget {
  final String listId;
  final String boardId;
  final VoidCallback refreshLists;
  final Offset position;
  final double screenWidth;
  final VoidCallback closeModal;

  const ModalListWidget({
    Key? key,
    required this.listId,
    required this.boardId,
    required this.refreshLists,
    required this.position,
    required this.screenWidth,
    required this.closeModal,
  }) : super(key: key);

  @override
  _ModalListWidgetState createState() => _ModalListWidgetState();
}

class _ModalListWidgetState extends State<ModalListWidget> {
  void _copyList() {
    print('Copier la liste');
    widget.closeModal();
  }

  void _moveList() {
    print('Déplacer la liste');
    widget.closeModal();
  }

  void _moveAllCards() {
    print('Déplacer toutes les cartes');
    widget.closeModal();
  }

  void _archiveList() {
    print('Archiver la liste');
    ListService.ArchiveList(widget.listId);
    widget.closeModal();
  }

  @override
  Widget build(BuildContext context) {
    double modalWidth = 250;
    double rightSpace = widget.screenWidth - widget.position.dx;

    // Vérifie si la place à droite est suffisante, sinon affiche à gauche
    double leftPosition = (rightSpace > modalWidth + 20) 
        ? widget.position.dx + 40 
        : widget.position.dx - modalWidth - 10;

    return Positioned(
      left: leftPosition,
      top: widget.position.dy + 10,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: modalWidth,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 5,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Paramètres de la liste',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Copier', style: TextStyle(color: Colors.white)),
                leading: const Icon(Icons.copy, color: Colors.white),
                onTap: _copyList,
              ),
              ListTile(
                title: const Text('Déplacer la liste', style: TextStyle(color: Colors.white)),
                leading: const Icon(Icons.swap_horiz, color: Colors.white),
                onTap: _moveList,
              ),
              ListTile(
                title: const Text('Déplacer toutes les cartes', style: TextStyle(color: Colors.white)),
                leading: const Icon(Icons.list_alt, color: Colors.white),
                onTap: _moveAllCards,
              ),
              ListTile(
                title: const Text('Archiver', style: TextStyle(color: Colors.white)),
                leading: const Icon(Icons.archive, color: Colors.white),
                onTap: _archiveList,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
