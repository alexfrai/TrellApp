// ignore_for_file: public_member_api_docs, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// API KEY
final String apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'] ?? 'DEFAULT_KEY';

///API TOKEN
final String apiToken = dotenv.env['NEXT_PUBLIC_API_TOKEN'] ?? 'DEFAULT_TOKEN';

/// Modale cartes
class CardsModal extends StatefulWidget {
  const CardsModal({
    required this.taskName,
    required this.selectedCardId,
    required this.handleClose,
    required this.fetchCards,
    super.key,
  });
  final String taskName;
  final String? selectedCardId;
  final VoidCallback handleClose;
  final VoidCallback fetchCards;

  @override
  _CardsModalState createState() => _CardsModalState();
}

class _CardsModalState extends State<CardsModal> {
  final TextEditingController _commentController = TextEditingController();
  bool _error = false;
  bool _isDeleting = false;

  /// 🔥 Supprimer une carte depuis l'API Trello
  Future<void> _deleteCard() async {
    if (widget.selectedCardId == null) return;

    setState(() => _isDeleting = true);

    final String url =
        'https://api.trello.com/1/cards/${widget.selectedCardId}?key=$apiKey&token=$apiToken';

    try {
      final http.Response response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        // print('✅ Carte supprimée avec succès !');
        widget.fetchCards(); // ✅ Rafraîchir CardsScreen après suppression
        widget.handleClose(); // ✅ Fermer la modale
      } else {
        throw Exception('❌ Erreur API: ${response.statusCode}');
      }
    } catch (error) {
      // print("❌ Erreur lors de la suppression : $error");
    } finally {
      setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[Color(0xFF2193B0), Color(0xFF6DD5ED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Header avec le titre et le bouton de fermeture
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  widget.taskName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: widget.handleClose,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description (Lorem Ipsum)
            const Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
              'Suspendisse malesuada lacus ex, sit amet blandit leo lobortis eget. '
              'Fusce vel dui eget ligula tristique convallis.',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Champ de commentaire
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Commentaire',
                labelStyle: const TextStyle(color: Colors.white),
                filled: true,
                // ignore: deprecated_member_use
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                errorText: _error ? 'Le champ ne peut pas être vide' : null,
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),

            // Bouton Sauvegarder
            ElevatedButton(
              onPressed: () {
                if (_commentController.text.trim().isEmpty) {
                  setState(() => _error = true);
                } else {
                  // print("Commentaire sauvegardé: ${_commentController.text}");
                  widget.handleClose();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Sauvegarder'),
            ),

            const SizedBox(height: 16),

            // Bouton Supprimer avec indicateur de chargement
            if (_isDeleting)
              const CircularProgressIndicator()
            else
              TextButton(
                onPressed: _deleteCard,
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Supprimer la carte'),
              ),
          ],
        ),
      ),
    );
  }
}
