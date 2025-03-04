// ignore_for_file: public_member_api_docs, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// API KEY
final String apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'] ?? 'DEFAULT_KEY';

/// API TOKEN
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
  final bool _error = false;
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
        widget.fetchCards(); // ✅ Rafraîchir CardsScreen après suppression
        widget.handleClose(); // ✅ Fermer la modale
      } else {
        throw Exception('❌ Erreur API: ${response.statusCode}');
      }
    } catch (error) {
      print('❌ Erreur lors de la suppression : $error');
    } finally {
      setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 10, // 🌟 Ombre douce pour un effet premium
      backgroundColor: Colors.transparent, // Fond transparent pour l'effet modal
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF3D1308), // Fond bordeaux profond
          borderRadius: BorderRadius.circular(12),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12,
              spreadRadius: 3,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Titre et bouton de fermeture
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    widget.taskName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF8E5EE), // Texte clair
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFFF8E5EE)),
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
              style: TextStyle(color: Color(0xFFF8E5EE)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Champ de commentaire
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Commentaire',
                labelStyle: const TextStyle(color: Color(0xFFF8E5EE)),
                filled: true,
                fillColor: const Color(0xFF9F2042).withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: _error ? 'Le champ ne peut pas être vide' : null,
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Boutons actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                // Bouton Fermer
                ElevatedButton(
                  onPressed: widget.handleClose,
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
                  child: const Text('Fermer'),
                ),

                // Bouton Supprimer avec indicateur de chargement
                if (_isDeleting) const CircularProgressIndicator(color: Colors.white) else ElevatedButton(
                        onPressed: _deleteCard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Supprimer'),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
