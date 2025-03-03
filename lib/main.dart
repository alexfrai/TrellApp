// ignore_for_file: public_member_api_docs, prefer_const_constructors, always_specify_types

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_trell_app/app/screens/cards_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 📌 Assure l'initialisation avant tout
  try {
    await dotenv.load();
    // print('✅ Fichier .env chargé avec succès !');
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
      initialRoute: '/', // Démarrage sur la page d'accueil
      routes: {
        '/': (context) => const HomeScreen(),
        '/cards': (context) => const CardsScreen(id: '67bc36eac821fc127236093a'),
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
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // print('🟢 Navigation vers CardsScreen...');
                Navigator.pushNamed(context, '/cards');
              },
              child: const Text('Voir les cartes'),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                // print('🟢 Navigation vers CardsScreen...');
                Navigator.pushNamed(context, '/cards');
              },
              child: const Text('Voir les cartes'),
            ),
          ],
        ),
      ),
    );
  }
}
