// ignore_for_file: public_member_api_docs, library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/services/checkitem_service.dart';
import 'package:flutter_trell_app/app/services/checklist_service.dart';
import 'package:flutter_trell_app/app/services/create_member_card.dart';
import 'package:flutter_trell_app/app/services/delete_service.dart';
import 'package:flutter_trell_app/app/services/get_members.dart';
import 'package:flutter_trell_app/app/services/update_service.dart';

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
    required this.checklistId,
    required this.refreshLists,
    required this.checklistName,
    super.key,
  });

  final String taskName;
  final String descriptionName;
  final String checklistName;
  final String? selectedCardId;
  final String listId;
  final String boardId;
  final String cardId;
  final String checklistId;
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
  final TextEditingController _checklistNameController =
      TextEditingController();
  final TextEditingController _checkItemController = TextEditingController();

  List<Map<String, dynamic>> _members = <Map<String, dynamic>>[];
  final List<dynamic> _checklists = [];
  final Map<String, List<Map<String, dynamic>>> _checkItemsByChecklist = {};

  bool _isUpdating = false;
  bool _isDeleting = false;
  bool _isAssigning = false;
  bool _isCreatingChecklist = false;
  bool _isCreatingCheckItem = false;

  String? _selectedMemberId;
  String? _selectedChecklistId;

  final CheckItemService _checkItemService = CheckItemService();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.taskName;
    _descriptionController.text = widget.descriptionName;
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadMembers();
    await _loadChecklists();
    if (mounted) setState(() {});
  }

  Future<void> _loadMembers() async {
    final GetMemberService service = GetMemberService();
    final List<Map<String, dynamic>> members = await service.getAllMembers(
      widget.boardId,
    );
    setState(() => _members = members);
  }

  Future<void> _loadChecklists() async {
    final Map<String, dynamic>? checklistData = await ChecklistService()
        .getChecklist(widget.cardId);
    if (checklistData == null || checklistData['idChecklists'] == null) return;

    final List<dynamic> checklistIds = checklistData['idChecklists'];
    _checklists.clear();
    _checkItemsByChecklist.clear();

    for (String id in checklistIds) {
      final Map<String, dynamic>? details = await ChecklistService()
          .getChecklistDetails(id);
      if (details != null) {
        _checklists.add(details);
        final List<Map<String, dynamic>> checkItems = await _checkItemService
            .getCheckItems(id);
        _checkItemsByChecklist[id] = checkItems;
      }
    }

    setState(() {});
  }

  Future<void> _createChecklist() async {
    if (_checklistNameController.text.isEmpty) return;

    setState(() => _isCreatingChecklist = true);

    final bool success = await ChecklistService().createChecklist(
      widget.cardId,
      _checklistNameController.text,
    );
    if (success) {
      _checklistNameController.clear();
      await _loadChecklists();
    }
    setState(() => _isCreatingChecklist = false);
  }

  Future<void> _updateChecklistName(String checklistId, String newName) async {
    final bool success = await ChecklistService().updateChecklist(
      checklistId,
      newName,
    );
    if (success) await _loadChecklists();
  }

  Future<void> _deleteChecklist(String checklistId) async {
    final bool success = await ChecklistService().deleteChecklist(checklistId);
    if (success) await _loadChecklists();
  }

  Future<void> _createCheckItem(String checklistId) async {
    if (_checkItemController.text.isEmpty) return;

    setState(() => _isCreatingCheckItem = true);

    final bool success = await _checkItemService.createCheckItem(
      checklistId,
      _checkItemController.text,
    );
    if (success) {
      _checkItemController.clear();
      await _loadChecklists();
    }

    setState(() => _isCreatingCheckItem = false);
  }

  Future<void> _updateCheckItemState(
    String checklistId,
    String checkItemId,
    bool state,
  ) async {
    await _checkItemService.updateCheckItem(
      widget.cardId,
      checkItemId,
      '',
      state,
    );
    await _loadChecklists();
  }

  Future<void> _deleteCheckItem(String checklistId, String checkItemId) async {
    await _checkItemService.deleteCheckItem(checklistId, checkItemId);
    await _loadChecklists();
  }

  Future<void> _updateCardName() async {
    if (_nameController.text.isEmpty || widget.selectedCardId == null) return;

    setState(() => _isUpdating = true);
    final success = await UpdateService.updateCardName(
      widget.selectedCardId!,
      _nameController.text,
    );
    if (success) {
      widget.onCardUpdated(widget.selectedCardId!, _nameController.text);
    }
    setState(() => _isUpdating = false);
  }

  Future<void> _updateCardDescription() async {
    if (_descriptionController.text.isEmpty || widget.selectedCardId == null)
      return;

    setState(() => _isUpdating = true);
    final bool success = await UpdateService.updateCardDescription(
      widget.selectedCardId!,
      _descriptionController.text,
    );
    if (success) {
      widget.onCardUpdated(widget.selectedCardId!, _descriptionController.text);
    }
    setState(() => _isUpdating = false);
  }

  Future<void> _deleteCard() async {
    if (widget.selectedCardId == null) return;

    setState(() => _isDeleting = true);
    final bool success = await DeleteService.deleteCard(widget.selectedCardId!);
    if (success) widget.onCardDeleted(widget.selectedCardId!);
    setState(() => _isDeleting = false);
  }

  Future<void> _assignMemberToCard() async {
    if (_selectedMemberId == null || widget.selectedCardId == null) return;

    setState(() => _isAssigning = true);
    final CreateMemberCard service = CreateMemberCard();
    await service.assignMemberToCard(
      widget.selectedCardId!,
      _selectedMemberId!,
    );
    setState(() => _isAssigning = false);
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white10,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromRGBO(113, 117, 104, 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.75,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🧱 Partie gauche
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📝 Gérer la carte',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _fieldDecoration('Nom de la carte'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descriptionController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _fieldDecoration('Description'),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white24),
                      const Text(
                        '✅ Checklists',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      for (var checklist in _checklists)
                        ExpansionTile(
                          backgroundColor: Colors.white10,
                          collapsedBackgroundColor: Colors.white12,
                          title: Text(
                            checklist['name'],
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            "${_checkItemsByChecklist[checklist['id']]?.length ?? 0} éléments",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ),
                                onPressed: () async {
                                  final TextEditingController controller =
                                      TextEditingController(
                                        text: checklist['name'],
                                      );
                                  await showDialog(
                                    context: context,
                                    builder:
                                        (_) => AlertDialog(
                                          title: const Text(
                                            'Modifier Checklist',
                                          ),
                                          content: TextField(
                                            controller: controller,
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(context),
                                              child: const Text('Annuler'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                await _updateChecklistName(
                                                  checklist['id'],
                                                  controller.text,
                                                );
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Valider'),
                                            ),
                                          ],
                                        ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed:
                                    () => _deleteChecklist(checklist['id']),
                              ),
                            ],
                          ),
                          children: [
                            for (var item
                                in (_checkItemsByChecklist[checklist['id']] ??
                                    []))
                              CheckboxListTile(
                                value: item['state'] == 'complete',
                                title: Text(
                                  item['name'],
                                  style: const TextStyle(color: Colors.white),
                                ),
                                onChanged:
                                    (val) async => _updateCheckItemState(
                                      checklist['id'],
                                      item['id'],
                                      val ?? false,
                                    ),
                                secondary: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed:
                                      () async => _deleteCheckItem(
                                        checklist['id'],
                                        item['id'],
                                      ),
                                ),
                              ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _checkItemController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _fieldDecoration(
                                      'Ajouter un checkitem',
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.greenAccent,
                                  ),
                                  onPressed:
                                      () async =>
                                          _createCheckItem(checklist['id']),
                                ),
                              ],
                            ),
                          ],
                        ),
                      const Divider(),
                      TextField(
                        controller: _checklistNameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _fieldDecoration('Nom nouvelle checklist'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed:
                            _isCreatingChecklist ? null : _createChecklist,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Créer Checklist'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 24),

              // 🧱 Partie droite dans une SizedBox centrée verticalement
              Center(
                child: SizedBox(
                  width: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: _updateCardName,
                        child: const Text('💾 Enregistrer'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _deleteCard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('🗑 Supprimer'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _assignMemberToCard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text('👤 Assigner'),
                      ),
                      const SizedBox(height: 16),
                      DropdownButton<String>(
                        value: _selectedMemberId,
                        hint: const Text(
                          'Sélectionner un membre',
                          style: TextStyle(color: Colors.white),
                        ),
                        dropdownColor: const Color.fromRGBO(225, 244, 203, 1),
                        isExpanded: true,
                        items:
                            _members.map((member) {
                              return DropdownMenuItem<String>(
                                value: member['id'] as String,
                                child: Text(
                                  member['fullName'],
                                  style: const TextStyle(color: Colors.black),
                                ),
                              );
                            }).toList(),
                        onChanged:
                            (val) => setState(() => _selectedMemberId = val),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
