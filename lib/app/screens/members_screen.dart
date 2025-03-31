import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_trell_app/app/widgets/header.dart';
import 'package:flutter_trell_app/app/widgets/sidebar.dart';
import 'package:http/http.dart' as http;

/// API KEYS
final String apiKey = dotenv.env['NEXT_PUBLIC_API_KEY'] ?? '';

/// API TOKEN
final String apiToken = dotenv.env['NEXT_PUBLIC_API_TOKEN'] ?? '';

/// Class MembersScreen
class MembersScreen extends StatefulWidget {
  /// Constructor
  const MembersScreen({super.key, required String curentPage});

  @override
  // ignore: library_private_types_in_public_api
  _MembersScreenState createState() => _MembersScreenState();
}


class _MembersScreenState extends State<MembersScreen> {
  final String userId = '5e31418954e5fd1a91bd6ae5';
  final String workspaceId = '672b2d9a2083a0e3c28a3212';
  final String inviteRequest =
      'https://trello.com/invite/672b2d9a2083a0e3c28a3212/ATTIf9ff463c55e9322a1b0ec205120380fc4A4FF39D';

  String curentWorkspace = '';

  List<dynamic> allMembers = [];
  bool isLoading = true; // Ajout d'un indicateur de chargement

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await getAllMembers();
    await getCurentWorkspace();
  }
  void updateBoardId(String newBoardId) {
    setState(() {
      // Tu peux stocker le boardId ici si nécessaire
      debugPrint('Board changé: $newBoardId');
    });
  }

  Future<dynamic> fetchApi(String apiRequest, String method) async {
    try {
      final http.Response response = await (method == 'POST'
          ? http.post(Uri.parse(apiRequest))
          : method == 'GET'
              ? http.get(Uri.parse(apiRequest))
              : method == 'PUT'
                  ? http.put(Uri.parse(apiRequest))
                  : method == 'DELETE'
                      ? http.delete(Uri.parse(apiRequest))
                      : http.get(Uri.parse(apiRequest)));

      if (response.statusCode != 200) {
        throw Exception('Erreur HTTP: ${response.statusCode} - ${response.body}');
      }

      return json.decode(response.body);
    } catch (error) {
      debugPrint('Erreur dans fetchApi: $error');
      return null;
    }
  }

  Future<void> getCurentWorkspace() async {
    final dynamic data = await fetchApi(
      'https://api.trello.com/1/organizations/$workspaceId?key=$apiKey&token=$apiToken',
      'GET',
    );
    if (data != null) {
      setState(() {
        curentWorkspace = data['displayName'];
      });
      // print(data);
    }
  }

  Future<void> getAllMembers() async {
    final dynamic members = await fetchApi(
      'https://api.trello.com/1/organizations/$workspaceId/members?key=$apiKey&token=$apiToken',
      'GET',
    );

    if (members == null || members is! List) {
      debugPrint('Erreur lors du chargement des membres');
      
      setState(() => isLoading = false);
      return;
    }

    setState(() {
      allMembers = members;
      isLoading = false;
    });
  }

  Future<void> addMember(member) async {
    if (member.contains('@')) {
      await addMemberWithMail(member);
    } else {
      await addMemberWithoutMail(member);
    }

    await getAllMembers();
  }

  Future<void> addMemberWithoutMail(member) async {
    final dynamic memberData = await fetchApi('https://api.trello.com/1/members/$member?key=$apiKey&token=$apiToken', 'PUT');
    // print(memberData);
    final String memberId = memberData['id'];
    final dynamic memberToAdd = await fetchApi('https://api.trello.com/1/organizations/$workspaceId/members/$memberId?type=normal&key=$apiKey&token=$apiToken',
        'PUT',);
  }

  Future<void> addMemberWithMail(member) async {
    final dynamic memberToAdd = await fetchApi('https://api.trello.com/1/organizations/$workspaceId/members?email=$member&key=$apiKey&token=$apiToken',
        'PUT',);
  }

  Future<void> supMember(member) async {
    final String memberId = member['id'];
    final dynamic memberToSup = await fetchApi('https://api.trello.com/1/organizations/$workspaceId/members/$memberId?key=$apiKey&token=$apiToken',
        'DELETE',);
    await getAllMembers();
  }

  Future<void> _modalAddMember(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a members to your workspace'),
          content: TextField(
            onSubmitted: (String str) {
              debugPrint(str);
              addMember(str);
            },
            decoration: const InputDecoration(
              labelText: 'Add with email or with username',
            ),
          ),
          actions: <Widget>[
            const Text('Invite people to your workspace with a link'),
            TextButton(
              style: TextButton.styleFrom(textStyle: Theme.of(context).textTheme.labelLarge),
              child: const Text('Copy link'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: inviteRequest));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to Clipboard!')),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 208, 151, 102),
      body: Column(
        children: <Widget>[
          /*SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
            child: const Header(),
          ),*/
          Expanded(
            child: Row(
              children: <Widget>[
                
              //Sidebar(onBoardChanged: updateBoardId),
                //Contenu de la page members

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            // Avatar + Info Workspace
                            Row(
                              children: <Widget>[
                                const CircleAvatar(child: Text('Z')),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(curentWorkspace),
                                    const Text('Visibility'),
                                  ],
                                ),
                              ],
                            ),
                            // Bouton "Add members"
                            ElevatedButton(
                              onPressed: () => _modalAddMember(context),
                              child: const Text('Add members'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Border entre les divisions
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueAccent),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Liste des membres
                        if (isLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          Expanded(
                            child: ListView.builder(
                              itemCount: allMembers.length,
                              itemBuilder: (BuildContext context, int index) {
                                final dynamic member = allMembers[index];
                                return Row(
                                  children: <Widget>[
                                    CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      child: Text(
                                        (member['username'] ?? '?')
                                            .substring(0, 1)
                                            .toUpperCase(),
                                      ),
                                    ),
                                    const SizedBox(width: 10),

                                    Row(
                                      children: <Widget>[
                                        Text(
                                          member['fullName'] ?? 'No Name',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        ElevatedButton(
                                          child: const Text('Boards'),
                                          onPressed: () {},
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton(
                                          child: const Text('Delete from workspace'),
                                          onPressed: () {
                                            showModalBottomSheet<void>(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return SizedBox(
                                                  height: 200,
                                                  child: Center(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: <Widget>[
                                                        const Text('Are you sure?'),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: <Widget>[
                                                            ElevatedButton(
                                                              child: const Text('YES'),
                                                              onPressed: () async {
                                                                Navigator.pop(context);
                                                                await supMember(member);
                                                              },
                                                            ),
                                                            ElevatedButton(
                                                              child: const Text('No'),
                                                              onPressed: () => Navigator.pop(context),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
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
