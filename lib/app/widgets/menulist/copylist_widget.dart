import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/services/get_all_cards.dart';
import 'package:flutter_trell_app/app/services/list_service.dart';

/// Widget pour déplacer toutes les cartes
class CopylistWidget extends StatefulWidget {
  const CopylistWidget({
    required this.sourceListId,
    required this.boardId,
    required this.onCopySuccess,
    super.key,
  });

  final String sourceListId;
  final String boardId;
  final VoidCallback onCopySuccess;

  @override
  CopylistWidgetState createState() => CopylistWidgetState();
}

class CopylistWidgetState extends State<CopylistWidget> {
  bool _loading = false;
  String? _error;
  final TextEditingController _nameController = TextEditingController();

  Future<void> _copyList() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Utilisez le service pour copier la liste
      await ListService().copyList(
        idBoard: widget.boardId,
        idListSource: widget.sourceListId,
        newName: _nameController.text.trim(), // Utilisez le nom saisi par l'utilisateur
      );
      widget.onCopySuccess();
    } catch (error) {
      setState(() {
        _error = 'Erreur lors de la copie de la liste : $error';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 200, // Largeur fixe pour correspondre à l'overlay
        constraints: const BoxConstraints(maxHeight: 200), // Hauteur maximale
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Copy List',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'New List Name',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    TextButton(
                      onPressed: _loading ? null : _copyList,
                      style: TextButton.styleFrom(foregroundColor: Colors.blue),
                      child: Text(_loading ? 'Copying...' : 'Copy'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Fermer le widget
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.grey),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
