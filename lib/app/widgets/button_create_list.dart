import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/services/list_service.dart';

/// Bouton pour créer les listes
class Createlistbutton extends StatefulWidget {
  /// Paramètre d'entrée
  const Createlistbutton({
    required this.boardId,
    required this.refreshLists, // Paramètre pour rafraîchir la liste
    super.key,
  });

  /// BoardID pour l'ID du board
  final String boardId;

  /// Fonction pour rafraîchir les listes
  final VoidCallback refreshLists;

  @override
  _CreatelistbuttonState createState() => _CreatelistbuttonState();
}

class _CreatelistbuttonState extends State<Createlistbutton> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _createList() async {
    if (_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nom de la liste ne peut pas être vide')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      // Créer la liste via le service
      final response = await ListService.createList(
        _controller.text, 
        widget.boardId, 
        position: 'bottom',  // Placer la liste à la fin
      );
      final String listId = response['id'];
      // Rafraîchir la liste après la création
      widget.refreshLists();

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La liste a été créée avec succès !')),
      );

      // Effacer le champ de saisie
      _controller.clear();
    } catch (error) {
      // Gérer l'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Permet à la colonne de prendre uniquement l'espace dont elle a besoin
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Name of the new list',
                border: InputBorder.none,
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          // Centrer le bouton horizontalement
          Center(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _createList,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(63, 71, 57, 1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Create list'),
            ),
          ),
        ],
      ),
    );
  }
}
