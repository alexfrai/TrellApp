// ignore_for_file: public_member_api_docs, library_private_types_in_public_api, always_specify_types, discarded_futures, deprecated_member_use

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

  void _loadCards() {
    _getCardsInList();
  }

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
        throw Exception('Erreur API: ${response.statusCode}');
      }

      final List<dynamic> data = json.decode(response.body);
      setState(() {
        cards =
            data
                .map((card) => {'id': card['id'], 'name': card['name']})
                .toList();
      });
    } catch (error) {
      setState(() {
        errorMessage =
            'Impossible de charger les cartes. Vérifiez votre connexion.';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF211103), // Fond Chocolat foncé
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Cartes Trello'),
          backgroundColor: const Color(0xFF3D1308),
          elevation: 4,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child:
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage.isNotEmpty
                  ? Center(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  )
                  : ListView.builder(
                    itemCount: cards.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Map<String, dynamic> card = cards[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0xFF7B0D1E), // Rouge foncé
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red,
                              width: 2,
                            ), // ✅ Ajout de la bordure rouge
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(
                              card['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF8E5EE), // Texte clair
                              ),
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
                                    fetchCards: _getCardsInList,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final newCard = await showDialog(
              context: context,
              builder: (BuildContext context) => CardsNew(id: widget.id),
            );
            if (newCard != null) {
              await _getCardsInList();
            }
          },
          backgroundColor: const Color(0xFF9F2042), // Rouge Framboise
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
