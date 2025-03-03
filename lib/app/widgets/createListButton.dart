import 'package:flutter/material.dart';
import '../services/list_service.dart'; // Assuming the ListService contains the createList method

class Createlistbutton extends StatefulWidget {
  final String BOARD_ID;
  const Createlistbutton({Key? key, required this.BOARD_ID}) : super(key: key);

  @override
  _CreatelistbuttonState createState() => _CreatelistbuttonState();

}

class _CreatelistbuttonState extends State<Createlistbutton> {
  final TextEditingController _controller = TextEditingController();

  // You can pass the BOARD_ID as an argument if needed

  // Flag to show loading state
  bool _isLoading = false;

  // Function to handle the button press
  Future<void> _createList() async {
    if (_controller.text.isEmpty) {
      // Show an error if the text field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Le nom de la liste ne peut pas être vide")),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });
    try {
      // Call the createList function from ListService
      final response = await ListService.createList(_controller.text, widget.BOARD_ID,);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Liste créée avec succès!")),
      );
      _controller.clear(); // Clear the text field
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $error")),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Nom de la liste',
              border: OutlineInputBorder(),
            ),
          ),
        ),
       ElevatedButton(
          onPressed: _isLoading ? null : () {
            // Print the boardId when the button is pressed
            _createList(); // Call the function to create the list
          }, 
          child: _isLoading
              ? CircularProgressIndicator(color: Colors.white)
              : Text("Créer la liste"),
        ),

      ],
    );
  }
}