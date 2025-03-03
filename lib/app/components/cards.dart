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
  void initState() {
    super.initState();
    _getCardsInList();
  }

  /// 🔹 Récupération des cartes depuis l'API Trello
  Future<void> _getCardsInList() async {
    setState(() => isLoading = true);

    try {
      final http.Response response = await http.get(
        Uri.parse('https://api.trello.com/1/lists/${widget.id}/cards?key=$apiKey&token=$apiToken'),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur API: ${response.statusCode}');
      }

      final List<dynamic> data = json.decode(response.body);
      setState(() {
        cards = data.map((card) => <String, dynamic>{'id': card['id'], 'name': card['name']}).toList();
      });
    } catch (error) {
      print('❌ Erreur lors de la requête: $error');
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
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[200],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Cartes'),
          backgroundColor: Colors.blueAccent,
          elevation: 4,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              if (isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Expanded(
                  child: cards.isNotEmpty
                      ? GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.8,
                          ),
                          itemCount: cards.length,
                          itemBuilder: (BuildContext context, int index) {
                            final Map<String, dynamic> card = cards[index];
                            return GestureDetector(
                              onTap: () => _handleOpen(card),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Center(
                                    child: Text(
                                      card['name'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
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
                            style: TextStyle(color: Colors.grey, fontSize: 16),
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
        floatingActionButton: open
            ? FloatingActionButton(
                onPressed: _handleClose,
                backgroundColor: Colors.redAccent,
                child: const Icon(Icons.close, color: Colors.white),
              )
            : null,
      ),
    );
  }
}
