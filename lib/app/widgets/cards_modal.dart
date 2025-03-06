import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/services/delete_service.dart';
import 'package:flutter_trell_app/app/services/update_service.dart';
import 'package:flutter_trell_app/app/widgets/cards_new.dart';

class CardsModal extends StatefulWidget {
  const CardsModal({
    required this.taskName,
    required this.selectedCardId,
    required this.handleClose,
    required this.onCardUpdated,
    required this.onCardDeleted,
    required this.listId, // ✅ Ajout du paramètre listId
    super.key,
  });

  final String taskName;
  final String? selectedCardId;
  final String listId; // ✅ ID de la liste pour l'ajout de carte
  final VoidCallback handleClose;
  final Function(String, String) onCardUpdated;
  final Function(String) onCardDeleted;


  @override
  _CardsModalState createState() => _CardsModalState();
}

class _CardsModalState extends State<CardsModal> {
  final TextEditingController _nameController = TextEditingController();
  bool _isUpdating = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.taskName;
  }

  Future<void> _updateCardName() async {
    if (widget.selectedCardId == null || _nameController.text.isEmpty) return;

    setState(() => _isUpdating = true);

    bool success = await UpdateService.updateCard(widget.selectedCardId!, _nameController.text);

    if (success) {
      widget.onCardUpdated(widget.selectedCardId!, _nameController.text);
      widget.handleClose();
    }

    setState(() => _isUpdating = false);
  }

  Future<void> _deleteCard() async {
    if (widget.selectedCardId == null) return;

    setState(() => _isDeleting = true);

    bool success = await DeleteService.deleteCard(widget.selectedCardId!);

    if (success) {
      widget.onCardDeleted(widget.selectedCardId!);
      widget.handleClose();
    }

    setState(() => _isDeleting = false);
  }

  Future<void> _createNewCard() async {
    final newCard = await showDialog(
      context: context,
      builder: (BuildContext context) => CardsNew(id: widget.listId),
    );
    if (newCard != null) {
      widget.handleClose(); // Ferme le modal après création
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 10,
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF3D1308), // Fond bordeaux foncé
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
            // 🌟 Titre du modal
            const Text(
              'Gérer la Carte',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF8E5EE),
              ),
            ),
            const SizedBox(height: 16),

            // 📝 Champ pour modifier le nom de la carte
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: InputDecoration(
                labelText: 'Nom de la carte',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF9F2042).withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 📜 Description placeholder
            const Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
              'Suspendisse malesuada lacus ex, sit amet blandit leo lobortis eget.',
              style: TextStyle(color: Color(0xFFF8E5EE)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // 🎛️ Boutons actions : Modifier, Supprimer, Ajouter une carte
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                // ✅ Bouton Enregistrer
                ElevatedButton(
                  onPressed: _isUpdating ? null : _updateCardName,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isUpdating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Enregistrer'),
                ),

                // ❌ Bouton Supprimer
                if (_isDeleting)
                  const CircularProgressIndicator(color: Colors.white)
                else
                  ElevatedButton(
                    onPressed: _deleteCard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Supprimer'),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // ➕ Bouton Ajouter une carte
            ElevatedButton(
              onPressed: _createNewCard,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9F2042), // Rouge Framboise
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Ajouter une nouvelle carte'),
            ),
          ],
        ),
      ),
    );
  }
}
