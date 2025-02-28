import 'package:flutter/material.dart';

class CardsModal extends StatelessWidget {
  final String taskName;
  final String? selectedCardId;
  final VoidCallback handleClose;

  const CardsModal({super.key, required this.taskName, required this.selectedCardId, required this.handleClose});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(taskName),
      content: Text('ID: $selectedCardId'),
      actions: [
        TextButton(
          onPressed: handleClose,
          child: const Text("Fermer"),
        ),
      ],
    );
  }
}