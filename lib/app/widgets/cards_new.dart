// ignore_for_file: library_private_types_in_public_api, always_specify_types

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// API KEY
final String apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'] ?? 'DEFAULT_KEY';

/// API TOKEN
final String apiToken = dotenv.env['NEXT_PUBLIC_API_TOKEN'] ?? 'DEFAULT_TOKEN';

/// New card
class CardsNew extends StatefulWidget {
  // ignore: public_member_api_docs
  const CardsNew({required this.id, super.key});
  // ignore: public_member_api_docs
  final String id;

  @override
  _CardsNewState createState() => _CardsNewState();
}

class _CardsNewState extends State<CardsNew> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _createCard() async {
    final String newCardName = _controller.text;
    if (newCardName.isEmpty) return;

    try {
      final http.Response response = await http.post(
        Uri.parse(
          'https://api.trello.com/1/cards?name=$newCardName&idList=${widget.id}&key=$apiKey&token=$apiToken',
        ),
      );

      if (response.statusCode == 200) {
        final newCard = json.decode(response.body);
        Navigator.pop(context, {'id': newCard['id'], 'name': newCard['name']});
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (error) {
      // print('❌ Erreur lors de la requête: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouvelle Carte'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(hintText: 'Nom de la carte'),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(onPressed: _createCard, child: const Text('Créer')),
      ],
    );
  }
}
