import 'package:flutter/material.dart';

class GetOneListWidget extends StatelessWidget {

  const GetOneListWidget({super.key, required this.list});
  final Map<String, dynamic> list;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        //leading: const Icon(Icons.list, color: Colors.blue),
        title: Text(
          list['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("ID: ${list['id']}"),
      ),
    );
  }
}
