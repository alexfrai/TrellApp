import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_trell_app/app/widgets/header.dart';
import 'package:flutter_trell_app/app/widgets/sidebar.dart';
import 'package:http/http.dart' as http;

/// Class
class MembersScreen extends StatefulWidget {
  /// Constructor
  const MembersScreen({super.key});

  @override
  _MembersScreenState createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final String userId = '5e31418954e5fd1a91bd6ae5';
  final String workspaceId = '672b2d9a2083a0e3c28a3212';

  List<dynamic> allMembers = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await getAllMembers();
  }

  Future<dynamic> fetchApi(String apiRequest, String method) async {
    try {

      final http.Response response =
          await (method == 'POST'
              ? http.post(Uri.parse(apiRequest))
              : http.get(Uri.parse(apiRequest)));

      if (response.statusCode != 200) {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }

      return json.decode(response.body);
    } catch (error) {
      debugPrint('Erreur dans fetchApi: $error');
      return null;
    }
  }

  Future<void> getAllMembers() async {

    final dynamic members = await fetchApi(
      'https://api.trello.com/1/organizations/$workspaceId/members?key=$apiKey&token=$apiToken',
      'GET',
    );
    if (members != null) {
      setState(() {
        allMembers = members;
        print(allMembers);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 208, 151, 102),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
            child: const Header(),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                const Sidebar(),
                //Contenu de la page members
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    //Column de la page a cote de la sideBar
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            // Avatar + Info Workspace
                            const Row(
                              children: <Widget>[
                                CircleAvatar(child: Text('Z')),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('Workspace'),
                                    Text('Visibility'),
                                  ],
                                ),
                              ],
                            ),

                            // Bouton "Add members"
                            ElevatedButton(
                              onPressed: () {
                                print('hello');
                              },
                              child: const Text('Add members to the board'),
                            ),
                          ],
                        ),
                        //Border between division
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueAccent),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: <Widget>[
                             Column(
                              children: <Widget>[
                                SizedBox(
                                  child: ListView.builder(
                          itemCount: allMembers.length,
                          itemBuilder: (BuildContext context, int index) {
                            final dynamic member = allMembers[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey,
                                child: Text(member['username'],),
                              ),
                              title: Text(
                                member['name'],
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          },
                        ),
                                ),
                                
                              ],
                             ),
                            ],
                          ),
                        ),
                       
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
