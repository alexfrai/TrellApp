// ignore_for_file: public_member_api_docs, library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/services/checklist_service.dart';
import 'package:flutter_trell_app/app/services/create_member_card.dart';
import 'package:flutter_trell_app/app/services/delete_service.dart';
import 'package:flutter_trell_app/app/services/get_members.dart';
import 'package:flutter_trell_app/app/services/update_service.dart';
import 'package:flutter_trell_app/app/widgets/cards_new.dart';
import 'package:flutter_trell_app/app/widgets/checklist.dart';

class CardsModal extends StatefulWidget {
  const CardsModal({
    required this.taskName,
    required this.descriptionName,
    required this.selectedCardId,
    required this.handleClose,
    required this.onCardUpdated,
    required this.onCardDeleted,
    required this.listId,
    required this.boardId,
    required this.cardId,
    required this.refreshLists,
    super.key,
  });

  final String taskName;
  final String descriptionName;
  final String? selectedCardId;
  final String listId;
  final String boardId;
  final String cardId;
  final VoidCallback handleClose;
  final Function(String, String) onCardUpdated;
  final Function(String) onCardDeleted;
  final VoidCallback refreshLists;

  @override
  _CardsModalState createState() => _CardsModalState();
}

class _CardsModalState extends State<CardsModal> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late ChecklistManager _checklistManager;

  List<Map<String, dynamic>> _members = <Map<String, dynamic>>[];
  String? _selectedMemberId;
  bool _isUpdating = false;
  bool _isDeleting = false;
  bool _isAssigning = false;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.taskName;
    _descriptionController.text = widget.descriptionName;

    _checklistManager = ChecklistManager(
      cardId: widget.selectedCardId ?? '',
      refreshLists: widget.refreshLists,
      handleClose: widget.handleClose,
    );

    _loadData();
  }

  Future<void> _loadData() async {
    await _loadMembers();
    await _loadChecklists();
    if (mounted) {
      setState(() {}); // Rafraîchir l'affichage après le chargement
    }
  }

  Future<void> _loadChecklists() async {
    await _checklistManager.fetchChecklists();
  }

  Future<void> _loadMembers() async {
    final GetMemberService service = GetMemberService();
    final List<Map<String, dynamic>> members = await service.getAllMembers(
      widget.boardId,
    );

    if (!mounted) return;

    setState(() {
      _members = members;
    });
  }

  Future<void> _updateCardName() async {
    if (widget.selectedCardId == null || _nameController.text.isEmpty) return;

    setState(() => _isUpdating = true);
    final bool success = await UpdateService.updateCardName(
      widget.selectedCardId!,
      _nameController.text,
    );

    if (success) {
      widget.onCardUpdated(widget.selectedCardId!, _nameController.text);
      widget.handleClose();
    }

    setState(() => _isUpdating = false);
  }

  Future<void> _updateDescription() async {
    if (widget.selectedCardId == null || _descriptionController.text.isEmpty)
      return;

    setState(() => _isUpdating = true);

    final bool success = await UpdateService.updateCardDescription(
      widget.selectedCardId!,
      _descriptionController.text,
    );

    if (!mounted) return;

    if (success) {
      widget.onCardUpdated(widget.selectedCardId!, _descriptionController.text);
      widget.handleClose();
      widget.refreshLists(); // ✅ Rafraîchir les cartes après la mise à jour
    }

    setState(() => _isUpdating = false);
  }

  Future<void> _deleteCard() async {
    if (widget.selectedCardId == null) return;

    setState(() => _isDeleting = true);

    final bool success = await DeleteService.deleteCard(widget.selectedCardId!);

    if (success) {
      widget.onCardDeleted(widget.selectedCardId!);
      widget.handleClose();
    }

    setState(() => _isDeleting = false);
  }

  Future<void> _assignMemberToCard() async {
    if (widget.selectedCardId == null || _selectedMemberId == null) return;

    setState(() => _isAssigning = true);

    final CreateMemberCard service = CreateMemberCard();
    try {
      await service.assignMemberToCard(
        widget.selectedCardId!,
        _selectedMemberId!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Membre assigné avec succès !')),
      );
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Erreur : $error')));
    }

    setState(() => _isAssigning = false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 10,
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF3D1308),
          borderRadius: BorderRadius.circular(12),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 10,
              spreadRadius: 3,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ✅ Titre de la modale
            const Text(
              'Gérer la Carte',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF8E5EE),
              ),
            ),
            const SizedBox(height: 12),

            // ✅ Champ pour le nom de la carte
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
            const SizedBox(height: 12),

            // ✅ Sélecteur de membres
            DropdownButton<String>(
              hint: const Text('Sélectionner un membre'),
              value: _selectedMemberId,
              items:
                  _members.map((Map<String, dynamic> member) {
                    return DropdownMenuItem<String>(
                      value: member['id'],
                      child: Text(
                        member['fullName'],
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedMemberId = value;
                });
              },
              dropdownColor: const Color(0xFF3D1308),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),

            // ✅ Zone d'affichage des checklists avec FutureBuilder
            Expanded(
              child: FutureBuilder<void>(
                future: _checklistManager.fetchChecklists(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "❌ Erreur lors du chargement des checklists.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  } else {
                    print(
                      "🎯 Affichage des checklists : ${_checklistManager.checklistListWidget()}",
                    );
                    return _checklistManager.checklistListWidget();
                  }
                },
              ),
            ),

            const SizedBox(height: 12),

            // ✅ Boutons d'action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                  child:
                      _isUpdating
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Enregistrer'),
                ),
                ElevatedButton(
                  onPressed: _isDeleting ? null : _deleteCard,
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
                  child:
                      _isDeleting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Supprimer'),
                ),
                ElevatedButton(
                  onPressed: _isAssigning ? null : _assignMemberToCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isAssigning
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text('Assigner un membre'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ✅ Bouton pour créer une nouvelle checklist et rafraîchir l'affichage
            ElevatedButton(
              onPressed: () async {
                await _checklistManager.createChecklist(context, () {
                  setState(() {}); // Met à jour l'UI après création
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Créer Checklist'),
            ),
          ],
        ),
      ),
    );
  }
}
