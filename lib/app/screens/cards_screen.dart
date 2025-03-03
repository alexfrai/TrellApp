// ignore_for_file: public_member_api_docs, library_private_types_in_public_api, always_specify_types, discarded_futures

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_trell_app/app/widgets/cards_modal.dart';
import 'package:flutter_trell_app/app/widgets/cards_new.dart';
import 'package:http/http.dart' as http;

/// API Trello
final String apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'] ?? 'DEFAULT_KEY';
final String apiToken = dotenv.env['NEXT_PUBLIC_API_TOKEN'] ?? 'DEFAULT_TOKEN';

class CardsScreen extends StatefulWidget {
  const CardsScreen({required this.id, super.key});
  final String id;

  @override
  _CardsScreenState createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  List<Map<String, dynamic>> cards = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  /// 🔹 Charge les cartes en évitant `async` dans `initState()`
  void _loadCards() {
    _getCardsInList();
  }

  /// 🔹 Récupération des cartes depuis l'API Trello avec gestion des erreurs
  Future<void> _getCardsInList() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final String url =
        'https://api.trello.com/1/lists/${widget.id}/cards?key=$apiKey&token=$apiToken';

    try {
      final http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('Erreur API: ${response.statusCode} - ${response.body}');
      }

      final List<dynamic> data = json.decode(response.body);
      setState(() {
        cards = data
            .map((card) => {'id': card['id'], 'name': card['name']})
            .toList();
      });

      print("✅ ${cards.length} cartes chargées !");
    } catch (error) {
      setState(() {
        errorMessage =
            "Impossible de charger les cartes. Vérifiez votre connexion.";
      });
      print("❌ Erreur lors de la requête: $error");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color(0xFF94C5CC), // Barre d'application
        scaffoldBackgroundColor: const Color(0xFFF8F8F8), // Fond clair
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Cartes Trello'),
          backgroundColor: const Color(0xFF94C5CC),
          elevation: 4,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF8F8F8), Color(0xFFB4D2E7)], // Dégradé élégant
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Text(
                          errorMessage,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : cards.isNotEmpty
                        ? ListView.builder(
                            itemCount: cards.length,
                            itemBuilder: (BuildContext context, int index) {
                              final Map<String, dynamic> card = cards[index];

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: InkWell(
                                  onTap: () async {
                                    print("🟢 Carte sélectionnée : ${card['name']}");

                                    await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CardsModal(
                                          taskName: card['name'],
                                          selectedCardId: card['id'],
                                          handleClose: () {
                                            Navigator.of(context).pop();
                                          },
                                          fetchCards: _getCardsInList,
                                        );
                                      },
                                    );
                                  },
                                  splashColor: const Color(0xFFA1A6B4)
                                      .withOpacity(0.2), // Effet au clic
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFB4D2E7), // Couleur carte
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            card['name'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const Icon(Icons.arrow_forward_ios,
                                            color: Color(0xFFA1A6B4), size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Text(
                              'Aucune carte trouvée',
                              style: TextStyle(
                                  color: Color(0xFFA1A6B4), fontSize: 16),
                            ),
                          ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final newCard = await showDialog(
              context: context,
              builder: (BuildContext context) => CardsNew(id: widget.id),
            );
            if (newCard != null) {
              await _getCardsInList(); // ✅ Mise à jour après ajout
            }
          },
          backgroundColor: const Color(0xFFA1A6B4),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
