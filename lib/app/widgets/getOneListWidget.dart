import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_trell_app/app/widgets/cards_modal.dart';
import 'package:flutter_trell_app/app/widgets/cards_new.dart';
import 'package:http/http.dart' as http;

/// API KEYS
final String apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'] ?? 'DEFAULT_KEY';
final String apiToken = dotenv.env['NEXT_PUBLIC_API_TOKEN'] ?? 'DEFAULT_TOKEN';

class GetOneListWidget extends StatefulWidget {
  final Map<String, dynamic> list;
  final List<Map<String, dynamic>> cards;
  final Function() refreshLists;

  const GetOneListWidget({
    super.key,
    required this.list,
    required this.cards,
    required this.refreshLists,
  });

  @override
  _GetOneListWidgetState createState() => _GetOneListWidgetState();
}

class _GetOneListWidgetState extends State<GetOneListWidget> {
  bool _isLoading = false;

  Future<void> _deleteCard(String cardId) async {
    setState(() => _isLoading = true);

    final String url =
        'https://api.trello.com/1/cards/$cardId?key=$apiKey&token=$apiToken';

    try {
      final http.Response response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        widget.refreshLists();
      } else {
        throw Exception('❌ Erreur API: ${response.statusCode}');
      }
    } catch (error) {
      // print('❌ Erreur lors de la suppression : $error');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateCard(String cardId, String newName) async {
    setState(() => _isLoading = true);

    final String url =
        'https://api.trello.com/1/cards/$cardId?key=$apiKey&token=$apiToken';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': newName}),
      );

      if (response.statusCode == 200) {
        widget.refreshLists(); // 🔄 Rafraîchir les listes après mise à jour
      } else {
        throw Exception('❌ Erreur API: ${response.statusCode}');
      }
    } catch (error) {
      // print('❌ Erreur lors de la mise à jour : $error');
    } finally {
      setState(() => _isLoading = false);
    }
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
          ...widget.cards.map((card) {
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
                children: [
                  // Bouton Modifier la carte
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                    onPressed: () async {
                      TextEditingController _controller = TextEditingController(
                        text: card['name'],
                      );
                      final newName = await showDialog<String>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Modifier la carte'),
                            content: TextField(
                              controller: _controller,
                              decoration: const InputDecoration(
                                hintText: 'Nouveau nom de la carte',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, null),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed:
                                    () => Navigator.pop(
                                      context,
                                      _controller.text,
                                    ),
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
          }).toList(),

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
                builder:
                    (BuildContext context) => CardsNew(id: widget.list['id']),
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
