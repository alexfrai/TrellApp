import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_trell_app/app/screens/cards_screen.dart';
import 'package:flutter_trell_app/app/screens/getList_screen.dart';
import 'app/widgets/header.dart';
import 'app/components/workspace.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 📌 Assure l'initialisation avant tout
  try {
    await dotenv.load();
    print('✅ Fichier .env chargé avec succès !');
  } catch (e) {
    print('❌ Erreur lors du chargement du fichier .env : $e');
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
      initialRoute: '/', // Démarrage sur la page d'accueil
      routes: {
        '/': (context) => const HomeScreen(),
        '/cards': (context) => const CardsScreen(id: '67bc36eac821fc127236093a'),
        '/getlist': (context) => const GetListWidget(boardId: '67b31302370bb706da4fa2cd'),
        '/workspace' : (BuildContext context) => const Workspace(),
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
        children: [
          // ✅ Le header prend uniquement sa hauteur naturelle
          const Header(),
        
          // ✅ La partie principale prend toute la hauteur restante
          Expanded(
            child: Row(
              children: <Widget>[
                // ✅ Colonne de gauche (Menu)
                Expanded(
                  flex: 3,
                  child: Container(
                        color: const Color.fromARGB(255, 62, 62, 62),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                print('🟢 Navigation vers CardsScreen...');
                                Navigator.pushNamed(context, '/workspace');
                              },
                              child: const Text('Voir les cartes'),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                print('🟢 Navigation vers GetList...');
                                Navigator.pushNamed(context, '/getlist');
                              },
                              child: const Text('Voir les listes'),
                            ),
                            const SizedBox(height: 30),
                            TextButton(
                              onPressed: () {
                                print('🟢 Navigation vers Tableaux...');
                                Navigator.pushNamed(context, '/boards');
                              },
                              child: const Text('Boards'),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: () {
                                print('🟢 Navigation vers Membres...');
                                Navigator.pushNamed(context, '/members');
                              },
                              child: const Text('Members'),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: () {
                                print('🟢 Navigation vers Paramètres...');
                                Navigator.pushNamed(context, '/parameter');
                              },
                              child: const Text('Parameters'),
                            ),
                            const SizedBox(height: 20),

                            // ✅ Section des Boards
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Boards list',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    '+',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  
               

                // ✅ Colonne de droite (Zone principale)
                Expanded(
                  flex: 7,
                  child: Container(
                    color: const Color.fromARGB(255, 108, 108, 108),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  print('🟢 Like button pressed');
                                },
                                icon: const Icon(Icons.thumb_up),
                                label: const Text('Like'),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  print('🟢 Next button pressed');
                                },
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
