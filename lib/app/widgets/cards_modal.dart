// ignore_for_file: public_member_api_docs, library_private_types_in_public_api, deprecated_member_use, unused_field, use_late_for_private_fields_and_variables, always_specify_types, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/services/checkitem_service.dart';
import 'package:flutter_trell_app/app/services/checklist_service.dart';
import 'package:flutter_trell_app/app/services/create_member_card.dart';
import 'package:flutter_trell_app/app/services/delete_service.dart';
import 'package:flutter_trell_app/app/services/get_member_card.dart';
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
  List<Map<String, dynamic>> _assignedMembers = <Map<String, dynamic>>[];

  bool _isUpdating = false;
  bool _isDeleting = false;
  bool _isAssigning = false;
  bool _isCreatingChecklist = false;
  bool _isCreatingCheckItem = false;

  String? _selectedMemberId;
  String? _selectedChecklistId;

  final CheckItemService _checkItemService = CheckItemService();
  final GetMemberCardService _getMemberService = GetMemberCardService();

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
    await _loadAssignedMembers();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadMembers() async {
    final GetMemberService service = GetMemberService();
    final List<Map<String, dynamic>> members = await service.getAllMembers(
      widget.boardId,
    );
    if (mounted) {
      setState(() => _members = members);
    }
  }

  Future<void> _loadChecklists() async {
    final Map<String, dynamic>? checklistData = await ChecklistService()
        .getChecklist(widget.cardId);
    if (checklistData == null || checklistData['idChecklists'] == null) return;

    final List<dynamic> checklistIds = checklistData['idChecklists'];
    _checklists.clear();
    _checkItemsByChecklist.clear();

    for (final String id in checklistIds) {
      final Map<String, dynamic>? details = await ChecklistService()
          .getChecklistDetails(id);
      if (details != null) {
        _checklists.add(details);
        final List<Map<String, dynamic>> checkItems = await _checkItemService
            .getCheckItems(id);
        _checkItemsByChecklist[id] = checkItems;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadAssignedMembers() async {
    final List<Map<String, dynamic>> assignedMembers = await _getMemberService
        .getMembersCard(widget.cardId);
    if (mounted) {
      setState(() {
        _assignedMembers = assignedMembers;
      });
    }
  }

  Future<void> _createChecklist() async {
    if (_checklistNameController.text.isEmpty) return;

    setState(() => _isCreatingChecklist = true);

    final bool success = await ChecklistService().createChecklist(
      widget.cardId,
      _checklistNameController.text,
    );
    if (success && mounted) {
      _checklistNameController.clear();
      await _loadChecklists();
    }
    if (mounted) {
      setState(() => _isCreatingChecklist = false);
    }
  }

  Future<void> _updateChecklistName(String checklistId, String newName) async {
    final bool success = await ChecklistService().updateChecklist(
      checklistId,
      newName,
    );
    if (success && mounted) {
      await _loadChecklists();
    }
  }

  Future<void> _deleteChecklist(String checklistId) async {
    final bool success = await ChecklistService().deleteChecklist(checklistId);
    if (success && mounted) {
      await _loadChecklists();
    }
  }

  Future<void> _createCheckItem(String checklistId) async {
    if (_checkItemController.text.isEmpty) return;

    setState(() => _isCreatingCheckItem = true);

    final bool success = await _checkItemService.createCheckItem(
      checklistId,
      _checkItemController.text,
    );
    if (success && mounted) {
      _checkItemController.clear();
      await _loadChecklists();
    }
    if (mounted) {
      setState(() => _isCreatingCheckItem = false);
    }
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
    if (mounted) {
      await _loadChecklists();
    }
  }

  Future<void> _deleteCheckItem(String checklistId, String checkItemId) async {
    await _checkItemService.deleteCheckItem(checklistId, checkItemId);
    if (mounted) {
      await _loadChecklists();
    }
  }

  Future<void> _updateCard() async {
    if (_nameController.text.isEmpty || widget.selectedCardId == null) return;

    setState(() => _isUpdating = true);

    final bool success = await UpdateService.updateCardFields(
      widget.selectedCardId!,
      {'name': _nameController.text, 'desc': _descriptionController.text},
    );

    if (success && mounted) {
      widget.onCardUpdated(widget.selectedCardId!, _nameController.text);
    }
    if (mounted) {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _deleteCard() async {
    if (widget.selectedCardId == null) return;

    setState(() => _isDeleting = true);
    final bool success = await DeleteService.deleteCard(widget.selectedCardId!);
    if (success && mounted) {
      widget.onCardDeleted(widget.selectedCardId!);
    }
    if (mounted) {
      setState(() => _isDeleting = false);
    }
  }

  Future<void> _assignMemberToCard() async {
    if (_selectedMemberId == null || widget.selectedCardId == null) return;

    setState(() => _isAssigning = true);
    final CreateMemberCard service = CreateMemberCard();
    await service.assignMemberToCard(
      widget.selectedCardId!,
      _selectedMemberId!,
    );
    if (mounted) {
      setState(() => _isAssigning = false);
    }
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
            children: <Widget>[
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
                      for (final checklist in _checklists)
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
                                  if (!mounted) return;
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
                                                if (!mounted) return;
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
                                  color: Color.fromRGBO(63, 71, 57, 1),
                                ),
                                onPressed:
                                    () async =>
                                        _deleteChecklist(checklist['id']),
                              ),
                            ],
                          ),
                          children: [
                            for (final item
                                in (_checkItemsByChecklist[checklist['id']] ??
                                    []))
                              CheckboxListTile(
                                value: item['state'] == 'complete',
                                title: Text(
                                  item['name'],
                                  style: const TextStyle(color: Colors.white),
                                ),
                                onChanged:
                                    (bool? val) async => _updateCheckItemState(
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
              Center(
                child: SizedBox(
                  width: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: _updateCard,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.save),
                            SizedBox(width: 8),
                            Text('Enregistrer la carte'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _deleteCard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(244, 67, 54, 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.delete),
                            SizedBox(width: 8),
                            Text('Supprimer'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Membres : ',
                        style: TextStyle(color: Colors.white),
                      ),
                      if (_assignedMembers.isNotEmpty)
                        Wrap(
                          spacing: 4,
                          children: List<Widget>.generate(
                            _assignedMembers.length,
                            (int index) {
                              return CircleAvatar(
                                child: Text(
                                  _assignedMembers[index]['username'][0]
                                      .toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.person_add),
                        label: const Text('Assigner un membre'),
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              String? selectedId;
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                backgroundColor: const Color.fromRGBO(
                                  113,
                                  117,
                                  104,
                                  1,
                                ),
                                title: const Row(
                                  children: [
                                    Icon(
                                      Icons.person_add,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Assigner un membre',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                content: StatefulBuilder(
                                  builder:
                                      (context, setState) => Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          DropdownButtonFormField<String>(
                                            isExpanded: true,
                                            decoration: InputDecoration(
                                              labelText:
                                                  'Sélectionnez un membre',
                                              labelStyle: TextStyle(
                                                color: Colors.white70,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white10,
                                            ),
                                            dropdownColor: const Color.fromRGBO(
                                              113,
                                              117,
                                              104,
                                              1,
                                            ),
                                            value: selectedId,
                                            items:
                                                _members.map((member) {
                                                  return DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: member['id'],
                                                    child: Text(
                                                      member['fullName'],
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                            onChanged:
                                                (val) => setState(
                                                  () => selectedId = val,
                                                ),
                                          ),
                                        ],
                                      ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      'Annuler',
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (selectedId != null) {
                                        _selectedMemberId = selectedId;
                                        await _assignMemberToCard();
                                        if (mounted) Navigator.pop(context);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      'Assigner',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
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
