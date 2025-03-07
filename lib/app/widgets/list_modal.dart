import 'package:flutter/material.dart';

class ListModal extends StatefulWidget {
  final String listId;

  const ListModal({
    super.key,
    required this.listId,
  });

  @override
  _ListModalState createState() => _ListModalState();
}

class _ListModalState extends State<ListModal> {
  OverlayEntry? _overlayEntry;

  // Créer le menu déroulant à afficher dans l'Overlay
  void _showMenu(BuildContext context, RenderBox button) {
    final overlay = Overlay.of(context);
    final size = button.size;
    final position = button.localToGlobal(Offset.zero);

    // Positionner le menu à droite du bouton, si possible
    final menuPosition = position.dx + size.width + 8;  // Décalage de 8 pixels
    final screenWidth = MediaQuery.of(context).size.width;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: position.dy,
        left: menuPosition > screenWidth ? position.dx - 200 : menuPosition,  // Vérifie si on dépasse la largeur
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Déplacer la liste'),
                  onTap: () {
                    // Action de déplacer la liste
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Text('Copier la liste'),
                  onTap: () {
                    // Action de copier la liste
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Text('Archiver la liste'),
                  onTap: () {
                    // Action d'archiver la liste
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  // Fermer le menu
  void _hideMenu() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.more_vert),
      onPressed: () {
        final renderBox = context.findRenderObject() as RenderBox;
        _showMenu(context, renderBox);
      },
    );
  }
}
