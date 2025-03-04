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
  final Function() refreshLists; // Ajout d'une fonction de rafraîchissement

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

  /// 🔥 Supprimer une carte depuis l'API Trello
  Future<void> _deleteCard(String cardId) async {
    setState(() => _isLoading = true);

    final String url =
        'https://api.trello.com/1/cards/$cardId?key=$apiKey&token=$apiToken';

    try {
      final http.Response response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        widget.refreshLists(); // 🔄 Rafraîchir après suppression
      } else {
        throw Exception('❌ Erreur API: ${response.statusCode}');
      }
    } catch (error) {
      print('❌ Erreur lors de la suppression : $error');
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
        subtitle: Text("ID: ${widget.list['id']}"),
        children: <Widget>[
          // 📌 Bouton pour ajouter une carte
          TextButton.icon(
            onPressed: () async {
              final newCard = await showDialog(
                context: context,
                builder: (BuildContext context) => CardsNew(id: widget.list['id']),
              );
              if (newCard != null) widget.refreshLists();
            },
            icon: const Icon(Icons.add),
            label: const Text("Ajouter une carte"),
          ),

          // 📌 Liste des cartes
          ...widget.cards.map((card) {
            return ListTile(
              title: Text(
                card['name'],
                style: const TextStyle(fontSize: 16),
              ),
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
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _deleteCard(card['id']),
              ),
            );
          }).toList(),

          if (widget.cards.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Aucune carte dans cette liste"),
            ),
        ],
      ),
    );
  }
}
