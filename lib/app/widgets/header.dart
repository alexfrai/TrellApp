// ignore_for_file: library_private_types_in_public_api, public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/services/board_service.dart';
import 'package:flutter_trell_app/app/services/workspace_service.dart';

/// Header
class Header extends StatefulWidget {
  const Header({super.key});

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  final String userId = '5e31418954e5fd1a91bd6ae5';
  final String workspaceId = '672b2d9a2083a0e3c28a3212';

  //Board Data
  String boardName = '';
  String backgroundColor = 'blue';
  String boardWorkspace = '';
  String boardVisibility = 'org';

  List<String> workspaces = <String>[];
  List<String> favoriteBoards = <String>[];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final List<dynamic>? fetchedWorkspaces = await WorkspaceService.getAllWorkspaces(userId);
      
      setState(() {
        workspaces = fetchedWorkspaces?.map((workspace) => workspace['name'].toString()).toList() ?? <String>[];
      });
    } catch (e) {
      //print('❌ Erreur lors du chargement des données : $e');
    }
  }
  Future<void> createBoard(String name) async {
    try {
      await BoardService.createBoard(name , workspaceId , backgroundColor , boardVisibility);
    } catch (e) {
      print('❌ Erreur lors du chargement des données : $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      //height: MediaQuery.of(context).size.height * 0.2,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.grey[800],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text(
                "Trell'Wish",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              _buildDropdown('Workspace', workspaces),
              _buildDropdown('Favorite', favoriteBoards),
              _buildDropdown('Template', <String>['q', 'zzzs']),
              _buildDropdown('Create', <String>[
                'Create a board',
                'Create from a template',
              ],
              'openModal',),
            ],
          ),
          Row(
            children: <Widget>[
              _buildSearchBar(),
              const SizedBox(width: 10),
              const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> options, [String action = 'none']) {
    return DropdownButton<String>(
      dropdownColor: Colors.grey[900],
      hint: Text(label, style: const TextStyle(color: Colors.white)),
      items: options.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: (String? value) async {
        // Gérer la sélection
        print('dropdown changed');

        switch(action){
          case 'openModal':
            await modal(context);
            break;
          }

        //await createBoard(':)');
      },
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      width: 200,
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Research',
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blue),
          ),
        ),
      ),
    );
  }
  Future<void> modal(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create a new board'),
          content: Column(
            spacing: 10,
            children: <Widget>[
              Text('Background color'),
              Row(
                spacing: 5,
                children: <Widget>[
                  OutlinedButton(onPressed: (){backgroundColor = 'blue';}, style: ButtonStyle(backgroundColor: WidgetStateProperty.all<Color>(Colors.blue)) , child: Text('')),
                  OutlinedButton(onPressed: (){backgroundColor = 'red';}, style: ButtonStyle(backgroundColor: WidgetStateProperty.all<Color>(Colors.red)) , child: Text('')),
                  OutlinedButton(onPressed: (){backgroundColor = 'pink';}, style: ButtonStyle(backgroundColor: WidgetStateProperty.all<Color>(Colors.pink)) , child: Text('')),
                  OutlinedButton(onPressed: (){backgroundColor = 'green';}, style: ButtonStyle(backgroundColor: WidgetStateProperty.all<Color>(Colors.green)) , child: Text('')),
                  OutlinedButton(onPressed: (){backgroundColor = 'orange';}, style: ButtonStyle(backgroundColor: WidgetStateProperty.all<Color>(Colors.orange)) , child: Text('')),
                ],
              ),
                  Text('Select a name for your board'),
                  TextField(onChanged: (String value) => boardName = value,),
                  Text('Workspace'),
                  _buildDropdown('Workspace', <String>['options', 'e']),
                  _buildDropdown('Visibility', <String>['Workspace' , 'Private' , 'Public']),
            ],
          ),
          
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(textStyle: Theme.of(context).textTheme.labelLarge),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(textStyle: Theme.of(context).textTheme.labelLarge),
              child: const Text('Create'),
              onPressed: () {
                createBoard(boardName);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
