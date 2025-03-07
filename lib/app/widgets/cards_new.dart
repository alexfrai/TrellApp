// ignore_for_file: public_member_api_docs, library_private_types_in_public_api, always_specify_types

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

final String apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'] ?? 'DEFAULT_KEY';
final String apiToken = dotenv.env['NEXT_PUBLIC_API_TOKEN'] ?? 'DEFAULT_TOKEN';

class CardsNew extends StatefulWidget {
  const CardsNew({required this.id, super.key});
  final String id;

  @override
  _CardsNewState createState() => _CardsNewState();
}

class _CardsNewState extends State<CardsNew> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _createCard() async {
    final String newCardName = _controller.text.trim();
    if (newCardName.isEmpty) return;

    setState(() => _isLoading = true);

    final http.Response response = await http.post(
      Uri.parse(
        'https://api.trello.com/1/cards?name=$newCardName&idList=${widget.id}&key=$apiKey&token=$apiToken',
      ),
    );

    if (response.statusCode == 200) {
      final newCard = json.decode(response.body);
      if (response.statusCode == 200) {
        final newCard = json.decode(response.body);
        Navigator.pop(context, {
          'id': newCard['id'],
          'name': newCard['name'],
        }); 
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouvelle Carte'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(labelText: 'Nom'),
      ),
      actions: [TextButton(onPressed: _createCard, child: const Text('Créer'))],
    );
  }
}
