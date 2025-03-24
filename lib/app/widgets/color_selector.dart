// ignore_for_file: public_member_api_docs, use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';

class ColorSelector extends StatefulWidget {
  @override
  _ColorSelectorState createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<ColorSelector> {
  List<String> colorsToSelect = <String>['blue', 'red', 'green', 'orange', 'pink'];
  String colorSelected = 'blue'; // Initialisation avec une couleur existante

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10), // Ajoute un peu d'espace autour
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10, // Espacement horizontal entre les boutons
        runSpacing: 10, // Espacement vertical entre les lignes
        children: colorsToSelect.map((String color) {
          final Color currentColor = _getColorFromString(color);

          return OutlinedButton(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: BorderSide(
                width: 3,
                color: colorSelected == color ? Colors.white : Colors.transparent,
              ),
              backgroundColor: currentColor,
              minimumSize: const Size(50, 50), // Assure une taille minimale
            ),
            onPressed: () {
              setState(() {
                colorSelected = color;
              });
            },
            child: const SizedBox(), // Pas de texte, juste le bouton coloré
          );
        }).toList(),
      ),
    );
  }

  Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'pink':
        return Colors.pink;
      default:
        return Colors.blue; // Couleur par défaut
    }
  }
}
