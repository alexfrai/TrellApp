// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_trell_app/app/services/checklist_service.dart';
import 'package:flutter_trell_app/app/widgets/checkitem.dart';

class ChecklistManager {
  ChecklistManager({
    required this.cardId,
    required this.checklistId,
    required this.refreshLists,
    required this.handleClose,
  });

  final String cardId;
  final String checklistId;
  final VoidCallback refreshLists;
  final VoidCallback handleClose;

  final String apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'] ?? 'DEFAULT_KEY';
  final String apiToken = dotenv.env['NEXT_PUBLIC_API_TOKEN'] ?? 'DEFAULT_TOKEN';

  final List<dynamic> _checklists = [];
  final Map<String, bool> _expanded = {};

  /// Récupère les checklists
  Future<void> fetchChecklists() async {
    if (cardId.isEmpty) return;
    try {
      final Map<String, dynamic>? checklistData = await ChecklistService().getChecklist(cardId);
      if (checklistData != null && checklistData['idChecklists'] != null) {
        final List<String> ids = List<String>.from(checklistData['idChecklists']);
        _checklists.clear();

        for (final String id in ids) {
          final Map<String, dynamic>? details = await ChecklistService().getChecklistDetails(id);
          if (details != null) {
            _checklists.add(details);
            _expanded[id] = false;
          }
        }
      }
    } catch (e) {
      // print("❌ Erreur chargement checklists : $e");
    }
  }

  /// Créer une nouvelle checklist
  Future<void> createChecklist(BuildContext context, VoidCallback refreshUI) async {
    if (cardId.isEmpty) return;

    final bool success = await ChecklistService().createChecklist(cardId, 'Checklist');
    if (success) {
      refreshLists();
      await fetchChecklists();
      refreshUI();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Checklist créée')),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Erreur création checklist')),
        );
      }
    }
  }

  /// Modifier une checklist
  Future<void> updateChecklistName(BuildContext context, String checklistId, String newName, VoidCallback refreshUI) async {
    final bool success = await ChecklistService().updateChecklist(checklistId, newName);
    if (success) {
      await fetchChecklists();
      refreshUI();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Nom de checklist modifié')),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Erreur de mise à jour')),
        );
      }
    }
  }

  /// Supprimer une checklist
  Future<void> deleteChecklist(BuildContext context, String checklistId, VoidCallback refreshUI) async {
    final bool success = await ChecklistService().deleteChecklist(checklistId);
    if (success) {
      await fetchChecklists();
      refreshUI();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Checklist supprimée')),
        );
      }
    }
  }

  /// Widget accordéon pour afficher les checklists et checkitems
  Widget checklistListWidget(BuildContext context, VoidCallback refreshUI) {
    if (_checklists.isEmpty) {
      return const Text('Aucune checklist', style: TextStyle(color: Colors.white70));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _checklists.length,
      itemBuilder: (context, index) {
        final checklist = _checklists[index];
        final String id = checklist['id'];
        final String name = checklist['name'];
        final List<dynamic> checkItems = checklist['checkItems'];

        return ExpansionTile(
          initiallyExpanded: _expanded[id] ?? false,
          onExpansionChanged: (val) => _expanded[id] = val,
          title: Text(name, style: const TextStyle(color: Colors.white)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange),
                onPressed: () {
                  final TextEditingController controller = TextEditingController(text: name);
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Modifier Checklist'),
                      content: TextField(controller: controller),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Annuler'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await updateChecklistName(context, id, controller.text.trim(), refreshUI);
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
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () async {
                  await deleteChecklist(context, id, refreshUI);
                },
              ),
            ],
          ),
          children: [
            CheckItemManager(
              checklistId: id,
              refreshUI: refreshUI,
            ).checkItemListWidget(context),
          ],
        );
      },
    );
  }
}
