import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/services/checkitem_service.dart';

class CheckItemManager {
  CheckItemManager({
    required this.checklistId,
    required this.refreshUI,
  });

  String checklistId;
  final VoidCallback refreshUI;
  final CheckItemService _checkItemService = CheckItemService();
  List<Map<String, dynamic>> _checkItems = [];

  /// Récupérer les checkitems
  Future<void> fetchCheckItems() async {
    if (checklistId.isEmpty) return;

    try {
      _checkItems = await _checkItemService.getCheckItems(checklistId);
      refreshUI();
    } catch (error) {
      print("❌ Erreur lors du chargement des checkitems : $error");
    }
  }

  /// Mettre à jour la checklist sélectionnée dynamiquement
  void updateChecklistId(String newId) {
    checklistId = newId;
  }

  /// Créer un checkitem
  Future<void> createCheckItem(BuildContext context, String name) async {
    if (checklistId.isEmpty || name.isEmpty) return;

    final bool success = await _checkItemService.createCheckItem(checklistId, name);

    if (success) {
      await fetchCheckItems();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ CheckItem ajouté !')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Erreur lors de l\'ajout du CheckItem')),
      );
    }
  }

  /// Supprimer un checkitem
  Future<void> deleteCheckItem(BuildContext context, String checkItemId) async {
    if (checklistId.isEmpty || checkItemId.isEmpty) return;

    final bool success = await _checkItemService.deleteCheckItem(checklistId, checkItemId);

    if (success) {
      await fetchCheckItems();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ CheckItem supprimé !')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Erreur lors de la suppression du CheckItem')),
      );
    }
  }

  /// Modifier l'état (coché / décoché)
  Future<void> updateCheckItemState(BuildContext context, String checkItemId, bool isChecked) async {
    final bool success = await _checkItemService.updateCheckItem(checklistId, checkItemId, '', isChecked);

    if (success) {
      await fetchCheckItems();
    }
  }

  /// Affichage des checkitems
  Widget checkItemListWidget(BuildContext context) {
    return _checkItems.isEmpty
        ? const Text('Aucun checkitem disponible.', style: TextStyle(color: Colors.white70))
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _checkItems.length,
            itemBuilder: (context, index) {
              final item = _checkItems[index];

              return CheckboxListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['name'], style: const TextStyle(color: Colors.white)),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () async {
                        await deleteCheckItem(context, item['id']);
                      },
                    ),
                  ],
                ),
                value: item['state'] == 'complete',
                onChanged: (bool? checked) async {
                  await updateCheckItemState(context, item['id'], checked ?? false);
                },
                controlAffinity: ListTileControlAffinity.leading,
              );
            },
          );
  }
}
