import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_trell_app/app/services/checklist_service.dart';

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
  bool _isCreating = false;
  List<dynamic> _checklists = [];

  final String apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'] ?? 'DEFAULT_KEY';
  final String apiToken =
      dotenv.env['NEXT_PUBLIC_API_TOKEN'] ?? 'DEFAULT_TOKEN';

  /// 🔄 Récupère les checklists et met à jour `_checklists`
  Future<void> fetchChecklists() async {
    if (cardId.isEmpty) return;

    try {
      // print('🔄 Chargement des checklists pour la carte ID: $cardId');
      final checklistData = await ChecklistService().getChecklist(cardId);

      if (checklistData != null && checklistData['idChecklists'] != null) {
        List<dynamic> checklistIds = checklistData['idChecklists'];
        _checklists.clear();

        for (String checklistId in checklistIds) {
          final checklistDetails = await ChecklistService().getChecklistDetails(
            checklistId,
          );
          if (checklistDetails != null) {
            _checklists.add(checklistDetails);
          }
        }
      } else {
        _checklists = [];
      }
    } catch (error) {
      // print("❌ Erreur lors du chargement des checklists : $error");
    }
  }

  /// ✅ Crée une nouvelle checklist et met à jour l'affichage
  Future<void> createChecklist(BuildContext context, Function updateUI) async {
    if (cardId.isEmpty) {
      // print("❌ Erreur : Aucune carte sélectionnée !");
      return;
    }

    _isCreating = true;

    final bool success = await ChecklistService().createChecklist(
      cardId,
      'Checklist',
    );

    if (success) {
      handleClose();
      refreshLists();
      await fetchChecklists(); // Recharger les checklists après la création
      updateUI(); // Met à jour l'UI avec setState
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Checklist créée avec succès !')),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Erreur lors de la création de la checklist'),
          ),
        );
      }
    }

    _isCreating = false;
  }

  /// ✅ Met à jour une checklist
  Future<void> updateChecklistName(
    BuildContext context,
    String checklistId,
    String newName,
    Function updateUI, // 🔄 Fonction pour mettre à jour l'UI
  ) async {
    if (checklistId.isEmpty || newName.isEmpty) return;

    final bool success = await ChecklistService().updateChecklist(
      checklistId,
      newName,
    );

    if (success) {
      await fetchChecklists(); // 🔄 Rafraîchir les checklists
      updateUI(); // 🔄 Mettre à jour l'UI dans CardsModal

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Checklist mise à jour avec succès !'),
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Erreur lors de la mise à jour de la checklist.'),
          ),
        );
      }
    }
  }

  void showEditChecklistDialog(
    BuildContext context,
    String checklistId,
    String currentName,
    Function updateUI,
  ) {
    TextEditingController editChecklistController = TextEditingController(
      text: currentName,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Modifier la Checklist"),
          content: TextField(
            controller: editChecklistController,
            decoration: const InputDecoration(labelText: "Nouveau nom"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () async {
                await updateChecklistName(
                  context,
                  checklistId,
                  editChecklistController.text,
                  () {
                    Navigator.of(context).pop(); // Fermer la pop-up
                    updateUI(); // 🔄 Rafraîchir l'affichage dans CardsModal
                  },
                );
              },
              child: const Text("Mettre à jour"),
            ),
          ],
        );
      },
    );
  }

  /// 🎯 Affiche la liste des checklists sous forme de `ListView`
  Widget checklistListWidget(BuildContext context, Function updateUI) {
    if (_checklists.isEmpty) {
      return const Text(
        'Aucune checklist disponible.',
        style: TextStyle(color: Colors.white70),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _checklists.length,
      itemBuilder: (context, index) {
        final checklist = _checklists[index];

        return GestureDetector(
          onTap: () {
            showEditChecklistDialog(
              context,
              checklist['id'],
              checklist['name'],
              updateUI,
            );
          },
          child: Card(
            color: Colors.white12,
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: ListTile(
              title: Text(
                checklist['name'],
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                '${checklist['checkItems'].length} éléments',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
        );
      },
    );
  }
}
