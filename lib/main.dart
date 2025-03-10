// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_trell_app/app/components/workspace.dart';
import 'package:flutter_trell_app/app/screens/cards_screen.dart';
import 'package:flutter_trell_app/app/screens/getList_screen.dart';
import 'package:flutter_trell_app/app/screens/members_screen.dart';
import 'package:flutter_trell_app/app/widgets/header.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load();
  } catch (e) {
    // print('❌ Erreur lors du chargement du fichier .env : $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => const HomeScreen(),
        '/cards': (BuildContext context) => const CardsScreen(
              id: '67bc36eac821fc127236093a',
              boardId: '67b31302370bb706da4fa2cd', 
            ),
        '/getlist': (BuildContext context) => const GetListWidget(
              boardId: '67b31302370bb706da4fa2cd',
            ),
        '/workspace': (BuildContext context) => const Workspace(),
        '/members': (BuildContext content) => const MembersScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accueil')),
      body: Column(
        children: <Widget>[
          const Header(),
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: ColoredBox(
                    color: const Color.fromARGB(255, 62, 62, 62),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              'Boards list',
                              style: TextStyle(color: Colors.white),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                '+',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: ColoredBox(
                    color: const Color.fromARGB(255, 108, 108, 108),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(height: 10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.thumb_up),
                              label: const Text('Like'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {},
                              child: const Text('Next'),
                            ),
                          ],
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
