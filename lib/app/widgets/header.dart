// ignore_for_file: library_private_types_in_public_api, public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/services/board_service.dart';
import 'package:flutter_trell_app/app/services/workspace_service.dart';
import 'package:flutter_trell_app/app/widgets/color_selector.dart';

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
  String colorSelected = '';
  bool isTemplate = true;

  List<String> colorsToSelect = <String>['blue','red', 'pink' , 'green' , 'orange'];

  Map<String, dynamic> templates = <String, dynamic>{
    'projectManagement' : '5c3e2fdb0fa92e43b849d838' ,
    'Enseignement: planification hebdomadaire' : '5ec98d97f98409568dd89dff',
    'Manuel des employés' : '5994bf29195fa87fb9f27709',
    'Modèle Kanban' : '5e6005043fbdb55d9781821e',
  };

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
      
      //print(fetchedWorkspaces);
      setState(() {
        workspaces = fetchedWorkspaces?.map((dynamic workspace) => workspace['name'].toString()).toList() ?? <String>[];
      });
    } catch (e) {
      //print('❌ Erreur lors du chargement des données : $e');
    }
  }
  Future<void> createBoard(String name) async {
    if(!isTemplate){
      try {
      await BoardService.createBoard(name , boardWorkspace , backgroundColor , boardVisibility);
    } catch (e) {
      print('❌ Erreur lors du chargement des données : $e');
    }
    }
    else{ // with template
      try {
      await BoardService.createBoardWithTemplate(name , templates['projectManagement']);

    } catch (e) {
      print('❌ Erreur lors du chargement des données : $e');
    }
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
                  fontWeight: FontWeight.w900,//bold
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
    String dropdownValue = options.isNotEmpty ? label : '';
    return StatefulBuilder(
      builder: (BuildContext context , StateSetter stepState){
        return DropdownButton<String>(
      dropdownColor: Colors.grey[900],
      value: options.contains(dropdownValue) ? dropdownValue : null,
      hint: Text(dropdownValue, style: const TextStyle(color: Colors.white)),
      items: options.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: (String? value) async {
        stepState(() {
          dropdownValue = value!;
        });
        // Gérer la sélection
        switch(action){
          case 'openModal':
            if(value == 'Create a board') await modalBoard(context);
            else await modalTemplate(context);
            break;
          case 'selectWorkspace' : 
          setState(() {
              boardWorkspace = value!;
            });
            break;
            case 'selectVisibility' : 
              setState(() {
                value == 'Workspace' ? boardVisibility = 'org'
                : value == 'Private' ? boardVisibility = 'private'
                : value == 'Public' ? boardVisibility = 'public' : '';
              
              });
              break;
          }

        //await createBoard(':)');
      },
    );
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

  Future<void> modalBoard(BuildContext context) { 
    colorSelected = colorsToSelect[0];
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create a new board' , style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
          content: Column(
            spacing: 10,
            children: <Widget>[
              Text('Background color' , style: TextStyle(color: Colors.white)),
              Container(
                width: 300,
                child: Column(
                mainAxisSize: MainAxisSize.min, 
                spacing: 5,
                children: <Widget>[
                  
                  ColorSelector(),
                  
                ],
              ),
              ),
                  Text('Select a name for your board' , style: TextStyle(color: Colors.white)),
                  TextField(onChanged: (String value) => boardName = value , style: TextStyle(color: Colors.white)),
                  Text('Workspace' , style: TextStyle(color: Colors.white)),
                  _buildDropdown('Workspace', workspaces , 'selectWorkspace'),
                  _buildDropdown('Visibility', <String>['Workspace' , 'Private' , 'Public'] , 'selectVisibility'),
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

  Future<void> modalTemplate(BuildContext context) { 
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Create a new board',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        content: Column(
          mainAxisSize: MainAxisSize.min, // Empêche l'alerte de prendre trop de place
          children: <Widget>[
            const Text(
              'Choose a template',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            Column(
              spacing: 5,
  children: templates.entries.map((entry) {
    return OutlinedButton(
      onPressed: () {
        print('Template sélectionné : ${entry.value} (${entry.key})');
        Navigator.of(context).pop();
        //createBoardFromTemplate(boardName, entry.key);
      },
      child: Text(
        entry.key, 
        style: const TextStyle(color: Colors.white),
      ),
    );
  }).toList(),
),
          ],
        ),
      );
    },
  );
}

}
