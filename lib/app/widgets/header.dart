import 'package:flutter/material.dart';

class Header extends StatefulWidget {
  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  final String userId = "5e31418954e5fd1a91bd6ae5";

  List<String> workspaces = [];
  List<String> favoriteBoards = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      List<String> fetchedWorkspaces = await GetAllWorkspaces(userId);
      List<String> fetchedFavoriteBoards = await GetBoardFromFavorite(userId);

      setState(() {
        workspaces = fetchedWorkspaces;
        favoriteBoards = fetchedFavoriteBoards;
      });
    } catch (e) {
      print('Erreur lors du chargement des données : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      color: Colors.grey[800],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'Trell\'Wish',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(width: 16),
              _buildDropdown('Workspace', workspaces),
              _buildDropdown('Favorite', favoriteBoards),
              _buildDropdown('Template', ['q', 'zzzs']),
              _buildDropdown('Create', ['Create a board', 'Create from a template']),
            ],
          ),
          Row(
            children: [
              _buildSearchBar(),
              SizedBox(width: 10),
              CircleAvatar(
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
      hint: Text(label, style: TextStyle(color: Colors.white)),
      items: options.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: (value) {
        // Gérer la sélection
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: 200,
      child: TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Research',
          labelStyle: TextStyle(color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
      ),
    );
  }
}
