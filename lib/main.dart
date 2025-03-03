import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './app/screens/cards_screen.dart';
import './app/screens/boards_screen.dart'

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); /// 📌 Assure l'initialisation avant tout

  try {
    await dotenv.load(fileName: ".env"); // Charge les variables d'environnement
    print("✅ Fichier .env chargé avec succès !");
    print("🔑 API Key: ${dotenv.env['NEXT_PUBLIC_API_KEY']}");
    print("🔒 API Token: ${dotenv.env['NEXT_PUBLIC_API_TOKEN']}");
  } catch (e) {
    print("❌ Erreur lors du chargement du fichier .env : $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Trello App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/', // Démarrage sur la page d'accueil
      routes: {
        '/': (context) => const HomeScreen(),
        '/cards':
            (context) => const CardsScreen(id: "67bc36eac821fc127236093a"),
        '/boards':
            (context) => const Board(boardId: )
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Accueil")),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Centrer les éléments horizontalement
          children: [
            ElevatedButton(
              onPressed: () {
                print("🟢 Navigation vers CardsScreen...");
                Navigator.pushNamed(context, '/cards');
              },
              child: const Text("Voir les cartes"),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                print("🟢 Navigation vers CardsScreen...");
                Navigator.pushNamed(context, '/cards');
              },
              child: const Text("Voir les cartes"),
            ),
            
          ],
        ),
      ),
    );
  }
}

