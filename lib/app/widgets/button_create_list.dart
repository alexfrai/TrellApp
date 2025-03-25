import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/services/list_service.dart';

/// bouton pour creer les list
class Createlistbutton extends StatefulWidget {
  ///parametre d'entré
  const Createlistbutton({required this.boardId, super.key});
  ///BoardID
  ///pour l id du board
  final String boardId;

  @override
  // ignore: library_private_types_in_public_api
  _CreatelistbuttonState createState() => _CreatelistbuttonState();
}

class _CreatelistbuttonState extends State<Createlistbutton> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _createList() async {
    if (_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nom de la liste ne peut pas être vide')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      // ignore: always_specify_types
      final response = await ListService.createList(_controller.text, widget.boardId);
      final String listId = response['id'];
      unawaited(ListService.updateListPos(listId, 'bottom'));
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create list was succes!')),
      );
      _controller.clear();
    } catch (error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(113, 117, 104,1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Allow the column to take only the space it needs
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Name of list',
                border: InputBorder.none,
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _isLoading ? null : _createList,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(186, 203, 169, 1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Create List'),
          ),
        ],
      ),
    );
  }
}
