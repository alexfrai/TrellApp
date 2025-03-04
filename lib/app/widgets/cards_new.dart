// ignore_for_file: library_private_types_in_public_api, always_specify_types

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// API KEY
final String apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'] ?? 'DEFAULT_KEY';

/// API TOKEN
final String apiToken = dotenv.env['NEXT_PUBLIC_API_TOKEN'] ?? 'DEFAULT_TOKEN';

/// Nouvelle carte
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
      print('❌ Erreur lors de la requête: $error');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 10, // 🌟 Effet d'ombre douce
      backgroundColor: Colors.transparent, // Fond transparent pour un effet modal
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF3D1308), // Fond bordeaux profond
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 10,
              spreadRadius: 3,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Titre
            const Text(
              'Nouvelle Carte',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF8E5EE), // Texte clair
              ),
            ),
            const SizedBox(height: 16),

            // Champ de texte
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Nom de la carte',
                labelStyle: const TextStyle(color: Color(0xFFF8E5EE)),
                filled: true,
                fillColor: const Color(0xFF9F2042).withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (_) => setState(() {}), // Active/désactive le bouton
            ),
            const SizedBox(height: 16),

            // Boutons actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Bouton Annuler
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFF8E5EE),
                  ),
                  child: const Text('Annuler'),
                ),

                // Bouton Créer (avec indicateur de chargement)
                if (_isLoading) const CircularProgressIndicator(color: Colors.white) else ElevatedButton(
                        onPressed: _controller.text.trim().isEmpty ? null : _createCard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9F2042),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Créer'),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
