import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../widgets/cards_new.dart';
import '../widgets/cards_modal.dart';

final String apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'] ?? 'DEFAULT_KEY';
final String apiToken = dotenv.env['NEXT_PUBLIC_API_TOKEN'] ?? 'DEFAULT_TOKEN';

class CardsScreen extends StatefulWidget {
  final String id;

  const CardsScreen({super.key, required this.id});

  @override
  _CardsScreenState createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  List<Map<String, dynamic>> cards = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCardsInList();
  }

  /// 🔹 Récupération des cartes depuis l'API Trello
  Future<void> _getCardsInList() async {
    setState(() => isLoading = true);

    final String url = 'https://api.trello.com/1/lists/${widget.id}/cards?key=$apiKey&token=$apiToken';

    print("🔗 URL API: $url");

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('Erreur API: ${response.statusCode} - ${response.body}');
      }

      final List<dynamic> data = json.decode(response.body);
      setState(() {
        cards = data.map((card) => {'id': card['id'], 'name': card['name']}).toList();
      });

      print("✅ ${cards.length} cartes chargées !");
    } catch (error) {
      print("❌ Erreur lors de la requête: $error");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cartes")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : cards.isNotEmpty
                ? ListView.builder(
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      final card = cards[index];

                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(card['name']),
                          onTap: () {
                            print("🟢 Carte sélectionnée : ${card['name']}");

                            // Ouvre la modale avec fetchCards() pour actualiser après suppression
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CardsModal(
                                  taskName: card['name'], // Nom de la tâche
                                  selectedCardId: card['id'], // ID de la carte
                                  handleClose: () {
                                    Navigator.of(context).pop();
                                  },
                                  fetchCards: _getCardsInList, // 👈 Passe la fonction ici
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text(
                      "Aucune carte trouvée",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newCard = await showDialog(
            context: context,
            builder: (context) => CardsNew(id: widget.id),
          );
          if (newCard != null) {
            _getCardsInList(); // 👈 Mise à jour après ajout d'une nouvelle carte
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
