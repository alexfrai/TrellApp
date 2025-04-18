// ignore_for_file: public_member_api_docs, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_trell_app/app/components/workspace.dart';
import 'package:flutter_trell_app/app/screens/getlists_screen.dart';
import 'package:flutter_trell_app/app/screens/members_screen.dart';
import 'package:flutter_trell_app/app/services/board_service.dart';
import 'package:flutter_trell_app/app/services/workspace_service.dart';
import 'package:flutter_trell_app/app/widgets/header.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(); // Charge les variables d'environnement

  runApp(const MyApp()); // Lance l'application
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static String currentPage = '';

  static String newWorkspaceName = '';
  static String newWorkspaceVis = '';
  static String newWorkspaceDesc = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => const HomeScreen(),
        '/getlist': (BuildContext context) =>
            const GetListWidget(boardId: '67b31302370bb706da4fa2cd'),
        '/workspace': (BuildContext context) => Workspace(curentPage: currentPage),
        '/members': (BuildContext content) => Workspace(curentPage: currentPage),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String userId = '5e31418954e5fd1a91bd6ae5';

  List<String> workspaces = <String>[];
  List<dynamic>? workspaceData = <dynamic>[];
  List<dynamic> favoriteBoards = <dynamic>[];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> updateWorkspace(String newWorkspaceId) async {
   
  setState(() {
    Workspace.workspaceId = newWorkspaceId;
  });

    //fetchData(); // Recharge les données
}

  Future<void> fetchData() async {
    try {
      final List<dynamic>? fetchedWorkspaces =
          await WorkspaceService.getAllWorkspaces();

      setState(() {
        workspaceData = fetchedWorkspaces;
        workspaces = fetchedWorkspaces
                ?.map((dynamic workspace) => workspace['displayName'].toString())
                .toList() ??
            <String>[];
        print(workspaces);
      });
    } catch (e) {

      // print('❌ Erreur lors du chargement des workspaces : $e');
    }

    try {
  final List<Map<String, dynamic>> fetchedFavBoards =
      await BoardService.getFavBoards();

  setState(() {
    favoriteBoards = fetchedFavBoards; 
    // print(favoriteBoards[1]['id']);
  });
  } catch (e) {
  // print('❌ Erreur lors du chargement des favoris : $e');
  }
}

Future<void> modalWorkspace(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create a new workspace'),
          content: Column(
            children:<Widget>[
              Text('Name of your new Workspace'),
              TextField(onChanged: (String value) =>  MyApp.newWorkspaceName = value,),
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
      appBar: AppBar(title: const Text('Accueil')),
      body: ColoredBox(
        color: Colors.grey,
        child: Column(
          children: <Widget>[
            Header(onWorkspaceChanged: updateWorkspace),
            Expanded(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Center(
                  child: Row(
                    children: <Widget>[
                      // Barre latérale gauche
                      Expanded(
                        flex: 2,
                        child: ColoredBox(
                          color: const Color.fromARGB(255, 62, 62, 62),
                          child: Column(
                            children: <Widget>[
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () async {
                                  MyApp.currentPage = 'board';
                                  await Navigator.pushNamed(context, '/workspace');
                                },
                                child: const Text('Voir les cartes'),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () async {
                                  await Navigator.pushNamed(context, '/getlist');
                                },
                                child: const Text('Voir les listes'),
                              ),
                              const SizedBox(height: 30),
                              TextButton(
                                onPressed: () async {
                                  await Navigator.pushNamed(context, '/boards');
                                },
                                child: const Text('Boards'),
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: () async {
                                  MyApp.currentPage = 'member';
                                  await Navigator.pushNamed(context, '/members');
                                },
                                child: const Text('Members'),
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: () async {
                                  await Navigator.pushNamed(context, '/parameter');
                                },
                                child: const Text('Parameters'),
                              ),
                              const SizedBox(height: 20),

                              // Workspaces
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  const Text(
                                    'Your workspaces',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await modalWorkspace(context);
                                    },
                                    child: const Text(
                                      '+',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),

                              // Liste des workspaces
                              Expanded(
                                child: workspaces.isEmpty
                                    ? const Center(child: CircularProgressIndicator())
                                    : ListView.builder(
                                        itemCount: workspaces.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          return ListTile(
                                            title: TextButton(
                                              onPressed: () async {
                                                MyApp.currentPage = 'board';
                                                Workspace.workspaceId = workspaceData?[index]['id'];
                                                await Navigator.pushNamed(context, '/workspace');
                                              },
                                              child : Text(workspaces[index]),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Section Favorite Boards
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: <Widget>[
                            const SizedBox(height: 20),

                            // Titre
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const <Widget>[
                                Icon(Icons.star_border_outlined, color: Colors.yellowAccent),
                                SizedBox(width: 8), // Correction ici
                                Text('Favorite boards'),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Liste des boards favoris
                            SizedBox(
                              height: 150,
                              child: favoriteBoards.isEmpty
                                  ? const Center(child: CircularProgressIndicator())
                                  : ListView.builder(
                                      itemCount: favoriteBoards.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        return Card(
                                          color: Colors.blueAccent,
                                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                          child: ListTile(
                                            title: Text(
                                              favoriteBoards[index]['name'] ?? 'Unnamed Board',
                                              style: const TextStyle(color: Colors.white),
                                            ),
                                            leading: const Icon(Icons.dashboard, color: Colors.white),
                                            onTap: () {
                                              // Action lorsqu'on clique sur un board
                                              // print('Board sélectionné : ${favoriteBoards[index]['name']}');
                                            },
                                          ),
                                        );
                                      },
                                    ),
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const <Widget>[
                                Text('Your Workspaces'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    
  }
}
