// ignore_for_file: public_member_api_docs, library_private_types_in_public_api, always_specify_types

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/widgets/cards_new.dart';
import 'package:http/http.dart' as http;

/// API KEYS
const String apiKey = String.fromEnvironment('NEXT_PUBLIC_API_KEY');

/// API TOKEN
const String apiToken = String.fromEnvironment('NEXT_PUBLIC_API_TOKEN');

class CardsScreen extends StatefulWidget {
  const CardsScreen({required this.id, super.key});
  final String id;

  @override
  _CardsScreenState createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  bool open = false;
  List<Map<String, dynamic>> cards = <Map<String, dynamic>>[];
  String? selectedCardId;
  String taskOpen = '';
  bool isLoading = true;

  @override
  Future<void> initState() async {
    super.initState();
    await _getCardsInList();
  }

  Future<void> _getCardsInList() async {
    setState(() => isLoading = true);

    try {
      final http.Response response = await http.get(
        Uri.parse(
          'https://api.trello.com/1/lists/${widget.id}/cards?key=$apiKey&token=$apiToken',
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur API: ${response.statusCode}');
      }

      final List<dynamic> data = json.decode(response.body);
      setState(() {
        cards =
            data
                .map(
                  (card) => <String, dynamic>{
                    'id': card['id'],
                    'name': card['name'],
                  },
                )
                .toList();
      });
    } catch (error) {
      // print('Erreur lors de la requête: $error');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _handleOpen(Map<String, dynamic> card) {
    setState(() {
      selectedCardId = card['id'];
      taskOpen = card['name'];
      open = true;
    });
  }

  void _handleClose() {
    setState(() {
      open = false;
      selectedCardId = null;
    });
  }

  void _onCardCreated(Map<String, dynamic> newCard) {
    setState(() {
      cards.add(newCard);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cartes')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            if (isLoading)
              const CircularProgressIndicator()
            else
              Expanded(
                child:
                    cards.isNotEmpty
                        ? GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 2,
                              ),
                          itemCount: cards.length,
                          itemBuilder: (BuildContext context, int index) {
                            final Map<String, dynamic> card = cards[index];
                            return GestureDetector(
                              onTap: () => _handleOpen(card),
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Center(
                                    child: Text(
                                      card['name'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                        : const Center(
                          child: Text(
                            'Aucune carte trouvée',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final newCard = await showDialog(
                  context: context,
                  builder: (BuildContext context) => CardsNew(id: widget.id),
                );
                if (newCard != null) _onCardCreated(newCard);
              },
              child: const Text('Ajouter une nouvelle carte'),
            ),
          ],
        ),
      ),
      floatingActionButton:
          open
              ? FloatingActionButton(
                onPressed: _handleClose,
                child: const Icon(Icons.close),
              )
              : null,
    );
  }
}
