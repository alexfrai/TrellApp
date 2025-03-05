// ignore_for_file: always_specify_types

import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/services/delete_service.dart';
import 'package:flutter_trell_app/app/services/update_service.dart';
import 'package:flutter_trell_app/app/widgets/cards_modal.dart';
import 'package:flutter_trell_app/app/widgets/cards_new.dart';

class GetOneListWidget extends StatefulWidget {
  const GetOneListWidget({
    super.key,
    required this.list,
    required this.cards,
    required this.refreshLists,
  });

  final Map<String, dynamic> list;
  final List<Map<String, dynamic>> cards;
  final Function() refreshLists;

  @override
  _GetOneListWidgetState createState() => _GetOneListWidgetState();
}

class _GetOneListWidgetState extends State<GetOneListWidget> {
  bool _isLoading = false;

  Future<void> _updateCard(String cardId, String newName) async {
    setState(() => _isLoading = true);

    bool success = await UpdateService.updateCard(cardId, newName);

    if (success) {
      widget.refreshLists();
    } else {
      print('❌ Mise à jour échouée');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _deleteCard(String cardId) async {
    setState(() => _isLoading = true);

    bool success = await DeleteService.deleteCard(cardId);

    if (success) {
      widget.refreshLists();
    } else {
      // print('❌ Suppression échouée');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ExpansionTile(
        title: Text(
          widget.list['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: <Widget>[
          ...widget.cards.map((Map<String, dynamic> card) {
            return ListTile(
              title: Text(card['name'], style: const TextStyle(fontSize: 16)),
              onTap: () async {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CardsModal(
                      taskName: card['name'],
                      selectedCardId: card['id'],
                      handleClose: () {
                        Navigator.of(context).pop();
                      },
                      fetchCards: widget.refreshLists,
                    );
                  },
                );
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Bouton Modifier la carte
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                    onPressed: () async {
                      final TextEditingController controller = TextEditingController(
                        text: card['name'],
                      );
                      final String? newName = await showDialog<String>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Modifier la carte'),
                            content: TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                hintText: 'Nouveau nom de la carte',
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, controller.text),
                                child: const Text('Mettre à jour'),
                              ),
                            ],
                          );
                        },
                      );
                      if (newName != null && newName.isNotEmpty) {
                        await _updateCard(card['id'], newName);
                      }
                    },
                  ),

                  // Bouton Supprimer la carte
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteCard(card['id']),
                  ),
                ],
              ),
            );
          }),

          if (widget.cards.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('Aucune carte dans cette liste'),
            ),

          // Bouton pour ajouter une carte
          TextButton.icon(
            onPressed: () async {
              final newCard = await showDialog(
                context: context,
                builder: (BuildContext context) => CardsNew(id: widget.list['id']),
              );
              if (newCard != null) widget.refreshLists();
            },
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une carte'),
          ),
        ],
      ),
    );
  }
}
