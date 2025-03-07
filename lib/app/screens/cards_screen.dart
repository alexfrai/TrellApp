// ignore_for_file: public_member_api_docs

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_trell_app/app/widgets/cards_new.dart';
import 'package:flutter_trell_app/app/widgets/getOneListWidget.dart';
import 'package:http/http.dart' as http;

/// API KEY
final String apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'] ?? 'DEFAULT_KEY';

/// API TOKEN
final String apiToken = dotenv.env['NEXT_PUBLIC_API_TOKEN'] ?? 'DEFAULT_TOKEN';

class CardsScreen extends StatefulWidget {
  const CardsScreen({required this.id, super.key});
  final String id;

  @override
  _CardsScreenState createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  List<Map<String, dynamic>> cards = <Map<String, dynamic>>[];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCardsInList();
  }

  Future<void> _getCardsInList() async {
    setState(() => isLoading = true);

    try {
      final http.Response response = await http.get(
        Uri.parse(
          'https://api.trello.com/1/lists/${widget.id}/cards?key=$apiKey&token=$apiToken',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          cards =
              data
                  .map((card) => <String, >{'id': card['id'], 'name': card['name']})
                  .toList();
        });
      }
    } catch (error) {
      // print('Erreur lors du chargement des cartes: $error');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _updateCard(String cardId, String newName) {
    setState(() {
      final int index = cards.indexWhere((Map<String, dynamic> card) => card['id'] == cardId);
      if (index != -1) {
        cards[index]['name'] = newName;
      }
    });
  }

  void _deleteCard(String cardId) {
    setState(() {
      cards.removeWhere((Map<String, dynamic> card) => card['id'] == cardId);
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
      backgroundColor: const Color(0xFF211103), // 🍫 Fond chocolat foncé
      appBar: AppBar(
        title: const Text('Cartes Trello'),
        backgroundColor: const Color(0xFF3D1308), // Rouge foncé
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : GetOneListWidget(
                  list: <String, dynamic>{'id': widget.id, 'name': 'Nom de la liste'},
                  cards: cards,
                  refreshLists:
                      _getCardsInList, // ✅ Gardé pour d'autres cas, mais pas utilisé à chaque ajout
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newCard = await showDialog(
            context: context,
            builder: (BuildContext context) => CardsNew(id: widget.id),
          );
          if (newCard != null) _onCardCreated(newCard);
        },
        backgroundColor: const Color(0xFF9F2042), // Rouge Framboise
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
