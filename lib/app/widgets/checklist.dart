
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_trell_app/app/services/checklist_service.dart';

class ChecklistManager {
  final String cardId;
  final VoidCallback refreshLists;
  final VoidCallback handleClose;
  bool _isCreating = false;
  List<dynamic> _checklists = [];

  final String apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'] ?? 'DEFAULT_KEY';
  final String apiToken =
      dotenv.env['NEXT_PUBLIC_API_TOKEN'] ?? 'DEFAULT_TOKEN';

  ChecklistManager({
    required this.cardId,
    required this.refreshLists,
    required this.handleClose,
  });

  /// 🔄 Récupère les checklists et met à jour `_checklists`
  Future<void> fetchChecklists() async {
  if (cardId.isEmpty) return;

  try {
    print("🔄 Chargement des checklists pour la carte ID: $cardId");

    // Récupérer la carte pour obtenir les ID des checklists
    final checklistData = await ChecklistService().getChecklist(cardId);
    // print("🔍 Réponse API: $checklistData"); 

    if (checklistData != null && checklistData['idChecklists'] != null) {
      List<dynamic> checklistIds = checklistData['idChecklists']; // Liste des ID des checklists
      // print("✅ ID des checklists récupérées: $checklistIds");

      _checklists.clear(); // Nettoyer la liste avant de la remplir

      // Récupérer chaque checklist individuellement
      for (String checklistId in checklistIds) {
        final checklistDetails = await ChecklistService().getChecklistDetails(checklistId);
        if (checklistDetails != null) {
          _checklists.add(checklistDetails);
        }
      }

      // print("✅ Checklists détaillées récupérées: $_checklists");
    } else {
      _checklists = [];
    }
  } catch (error) {
    // print("❌ Erreur lors du chargement des checklists : $error");
  }
}

  /// ✅ Crée une nouvelle checklist et force le rafraîchissement de l'UI
  Future<void> createChecklist(BuildContext context, Function updateUI) async {
    if (cardId.isEmpty) {
      // print("❌ Erreur : Aucune carte sélectionnée !");
      return;
    }

    _isCreating = true;

    final bool success = await ChecklistService().createChecklist(
      cardId,
      "Checklist",
    );

    if (success) {
      handleClose();
      refreshLists();
      await fetchChecklists(); // Recharger les checklists après la création
      updateUI(); // Met à jour l'UI avec setState
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Checklist créée avec succès !')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Erreur lors de la création de la checklist'),
        ),
      );
    }

    _isCreating = false;
  }


  /// 🎯 Affiche la liste des checklists sous forme de `ListView`
  Widget checklistListWidget() {
    if (_checklists.isEmpty) {
      // print("⚠️ Aucune checklist trouvée pour l'affichage.");
      return const Text(
        "Aucune checklist disponible.",
        style: TextStyle(color: Colors.white70),
      );
    }

    // print("📝 Affichage de ${_checklists.length} checklists !");

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _checklists.length,
      itemBuilder: (context, index) {
        final checklist = _checklists[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              checklist['name'] ?? 'Checklist',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: checklist['checkItems'].length,
              itemBuilder: (context, i) {
                final item = checklist['checkItems'][i];

                return CheckboxListTile(
                  title: Text(
                    item['name'] ?? 'Item',
                    style: const TextStyle(color: Colors.white),
                  ),
                  value: item['state'] == "complete",
                  onChanged: (bool? newValue) {
                    // Implémenter la mise à jour de l'élément ici
                  },
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }
}
