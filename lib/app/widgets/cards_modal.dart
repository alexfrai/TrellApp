import 'package:flutter/material.dart';

class CardsModal extends StatefulWidget {
  final String taskName;
  final String? selectedCardId;
  final VoidCallback handleClose;

  const CardsModal({
    super.key,
    required this.taskName,
    required this.selectedCardId,
    required this.handleClose,
  });

  @override
  _CardsModalState createState() => _CardsModalState();
}

class _CardsModalState extends State<CardsModal> {
  final TextEditingController _commentController = TextEditingController();
  bool _error = false;

  void _handleSave() {
    if (_commentController.text.trim().isEmpty) {
      setState(() {
        _error = true;
      });
      return;
    }
    
    print("Commentaire sauvegardé: ${_commentController.text}");
    
    _commentController.clear();
    widget.handleClose();
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
            colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header avec le titre et le bouton de fermeture
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.taskName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: widget.handleClose,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Description temporaire
            const Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse malesuada lacus ex.",
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),

            // Champ de commentaire
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: "Commentaire",
                labelStyle: const TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                errorText: _error ? "Le champ ne peut pas être vide" : null,
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),

            // Bouton Sauvegarder
            ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text("Sauvegarder"),
            ),
          ],
        ),
      ),
    );
  }
}
