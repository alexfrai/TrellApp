// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/services/delete_service.dart';
import 'package:flutter_trell_app/app/services/update_service.dart';

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
  final TextEditingController _nameController = TextEditingController();
  bool _isUpdating = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.taskName; // Charger le nom actuel de la carte
  }

  /// 🔄 Mettre à jour le nom de la carte via l'API
  Future<void> _updateCardName() async {
    if (widget.selectedCardId == null || _nameController.text.isEmpty) return;

    setState(() => _isUpdating = true);

    bool success = await UpdateService.updateCard(widget.selectedCardId!, _nameController.text);

    if (success) {
      widget.fetchCards(); // 🔄 Rafraîchir l'affichage après mise à jour
      widget.handleClose(); // ✅ Fermer la modale
    } else {
      // print('❌ Échec de la mise à jour');
    }

    setState(() => _isUpdating = false);
  }

  /// 🔥 Supprimer une carte via `DeleteService`
  Future<void> _deleteCard() async {
    if (widget.selectedCardId == null) return;

    setState(() => _isDeleting = true);

    bool success = await DeleteService.deleteCard(widget.selectedCardId!);

    if (success) {
      widget.fetchCards(); // ✅ Rafraîchir CardsScreen après suppression
      widget.handleClose(); // ✅ Fermer la modale
    } else {
      // print('❌ Échec de la suppression');
    }

    setState(() => _isDeleting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 10,
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF3D1308),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
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
            // 🔄 Champ pour modifier le nom de la carte
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

            // 📜 Description
            const Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
              'Suspendisse malesuada lacus ex, sit amet blandit leo lobortis eget.',
              style: TextStyle(color: Color(0xFFF8E5EE)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Boutons actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                // ✅ Bouton Enregistrer
                ElevatedButton(
                  onPressed: _isUpdating ? null : _updateCardName,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
