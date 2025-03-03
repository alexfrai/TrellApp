// ignore_for_file: library_private_types_in_public_api, public_member_api_docs

import 'package:flutter/material.dart';

/// header
class Header extends StatefulWidget {
  const Header({super.key});

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  final String userId = '5e31418954e5fd1a91bd6ae5';

  List<String> workspaces = <String>[];
  List<String> favoriteBoards = <String>[];

  @override
  Future<void> initState() async {
    super.initState();
    await fetchData();
  }

  Future<void> fetchData() async {
    try {
      final List<String> fetchedWorkspaces = await GetAllWorkspaces(userId);
      final List<String> fetchedFavoriteBoards = await GetBoardFromFavorite(
        userId,
      );

      setState(() {
        workspaces = fetchedWorkspaces;
        favoriteBoards = fetchedFavoriteBoards;
      });
    } catch (e) {
      // print('Erreur lors du chargement des données : $e');
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
              ]),
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

  Widget _buildDropdown(String label, List<String> options) {
    return DropdownButton<String>(
      dropdownColor: Colors.grey[900],
      hint: Text(label, style: const TextStyle(color: Colors.white)),
      items:
          options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
      onChanged: (String? value) {
        // Gérer la sélection
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
}
