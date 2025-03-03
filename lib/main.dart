import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/components/getList.dart'; // Assurez-vous du bon chemin d'importation

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    print("✅ Fichier .env chargé avec succès !");
  } catch (e) {
    print("❌ Erreur lors du chargement du fichier .env : $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GetListWidget(boardId: "XuEuw84e"), // Remplacez par un vrai Board ID
      ),
    );
  }
}