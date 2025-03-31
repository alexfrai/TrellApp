import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_trell_app/app/components/workspace.dart';
import 'package:flutter_trell_app/app/screens/getlists_screen.dart';
import 'package:http/http.dart' as http;

final String apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'] ?? 'DEFAULT_KEY';
final String apiToken = dotenv.env['NEXT_PUBLIC_API_TOKEN'] ?? 'DEFAULT_TOKEN';

class TrelloSearchDelegate extends SearchDelegate {
  List<dynamic> _results = [];
  bool _isLoading = false;
  static String currentPage = ''; // Variable accessible partout

  Future<void> _search(String query) async {
    _isLoading = true;
    final response = await http.get(
      Uri.parse(
        'https://api.trello.com/1/search?query=$query&key=$apiKey&token=$apiToken',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _results = data['cards'] ?? [];
    }
    _isLoading = false;
  }

  @override
  String get searchFieldLabel => 'Search Trello cards...';

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(child: Text('Start typing to search...'));
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<void>(
      future: _search(query),
      builder: (context, snapshot) {
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_results.isEmpty) {
          return const Center(child: Text('No results found.'));
        }

        return ListView.builder(
          itemCount: _results.length,
          itemBuilder: (context, index) {
            final card = _results[index];
            return ListTile(
              title: Text(card['name'] ?? 'Unnamed Card'),
              subtitle: Text('List ID: ${card['idList'] ?? 'N/A'}'),
              onTap: () async {
                close(context, null);

                final response = await http.get(
                  Uri.parse(
                    'https://api.trello.com/1/boards/${card['idBoard']}?key=$apiKey&token=$apiToken',
                  ),
                );

                if (response.statusCode == 200) {
                  final data = json.decode(response.body);
                  final String? workspaceId = data['idOrganization'];

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => Workspace(
                            curentPage: 'board',
                            focusedBoardId: card['idBoard'],
                            focusedListId: card['idList'],
                            focusedCardId: card['id'],
                            focusedWorkspaceId: workspaceId,
                          ),
                    ),
                  );
                } else {
                  // Fallback sans workspace
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => Workspace(
                            curentPage: 'board',
                            focusedBoardId: card['idBoard'],
                            focusedListId: card['idList'],
                            focusedCardId: card['id'],
                          ),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }
}
