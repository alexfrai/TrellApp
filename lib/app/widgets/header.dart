import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/services/board_service.dart';
import 'package:flutter_trell_app/app/services/workspace_service.dart';
import 'package:flutter_trell_app/app/widgets/color_selector.dart';
import 'package:flutter_trell_app/app/widgets/searchbar.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  final String userId = '5e31418954e5fd1a91bd6ae5';
  final String workspaceId = '672b2d9a2083a0e3c28a3212';

  // Board Data
  String boardName = '';
  String backgroundColor = 'blue';
  String boardWorkspace = '';
  String boardVisibility = 'org';
  String colorSelected = '';
  bool isTemplate = false;

  List<String> colorsToSelect = <String>['blue', 'red', 'pink', 'green', 'orange'];

  Map<String, dynamic> templates = <String, dynamic>{
    'projectManagement': '5c3e2fdb0fa92e43b849d838',
    'Enseignement: planification hebdomadaire': '5ec98d97f98409568dd89dff',
    'Manuel des employés': '5994bf29195fa87fb9f27709',
    'Modèle Kanban': '5e6005043fbdb55d9781821e',
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
      final List<dynamic>? fetchedWorkspaces = await WorkspaceService.getAllWorkspaces();
      setState(() {
        workspaces = fetchedWorkspaces?.map((dynamic workspace) => workspace['name'].toString()).toList() ?? <String>[];
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> createBoard(String name) async {
    if (!isTemplate) {
      try {
        await BoardService.createBoard(name, boardWorkspace, backgroundColor, boardVisibility);
      } catch (e) {
        // Handle error
      }
    } else {
      try {
        await BoardService.createBoardWithTemplate(name, templates['projectManagement']);
      } catch (e) {
        // Handle error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.grey[800],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              TextButton(
                onPressed: () async {
                  await Navigator.pushNamed(context, '/');
                },
                child: const Text(
                  "Trell'Wish",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _buildDropdown('Workspace', workspaces),
              _buildDropdown('Favorite', favoriteBoards),
              _buildDropdown('Template', templates.keys.toList()),
              _buildDropdown('Create', <String>[
                'Create a board',
                'Create from a template',
              ], 'openModal'),
            ],
          ),
          Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: TrelloSearchDelegate(),
                  );
                },
              ),
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
    return DropdownButton<String>(
      dropdownColor: Colors.grey[900],
      elevation: 16,
      menuMaxHeight: 300,
      value: options.contains(dropdownValue) ? dropdownValue : null,
      hint: Text(dropdownValue, style: const TextStyle(color: Colors.white)),
      items: options.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: (String? value) async {
        setState(() {
          dropdownValue = value!;
        });
        switch (action) {
          case 'openModal':
            if (value == 'Create a board') {
              await modalBoard(context);
            } else {
              isTemplate = true;
              await modalTemplate(context);
            }
            break;
          case 'selectWorkspace':
            setState(() {
              boardWorkspace = value!;
            });
            break;
          case 'selectVisibility':
            setState(() {
              value == 'Workspace'
                  ? boardVisibility = 'org'
                  : value == 'Private'
                      ? boardVisibility = 'private'
                      : value == 'Public'
                          ? boardVisibility = 'public'
                          : '';
            });
            break;
        }
      },
    );
  }

  Future<void> modalBoard(BuildContext context) {
    colorSelected = colorsToSelect[0];
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create a new board', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Background color', style: TextStyle(color: Colors.white)),
              SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ColorSelector(),
                  ],
                ),
              ),
              const Text('Select a name for your board', style: TextStyle(color: Colors.white)),
              TextField(
                onChanged: (String value) => boardName = value,
                style: const TextStyle(color: Colors.white),
              ),
              const Text('Workspace', style: TextStyle(color: Colors.white)),
              _buildDropdown('Workspace', workspaces, 'selectWorkspace'),
              _buildDropdown('Visibility', <String>['Workspace', 'Private', 'Public'], 'selectVisibility'),
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
          title: const Text('Create a new board', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Choose a template', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 10),
              Column(
                children: templates.entries.map((entry) {
                  return OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(entry.key, style: const TextStyle(color: Colors.white)),
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
