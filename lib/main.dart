import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './services/list_service.dart';

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
    return MaterialApp(
      title: 'Flutter Trello App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ListScreen(),
    );
  }
}

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<dynamic> lists = [];
  bool isLoading = true;
  String? errorMessage;
  final String boardId = "XuEuw84e"; // Remplace par un vrai Board ID

  @override
  void initState() {
    super.initState();
    fetchLists();
  }

  Future<void> fetchLists() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedLists = await ListService.getList(boardId);
      setState(() {
        lists = fetchedLists;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Erreur : Impossible de récupérer les listes.";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Listes Trello")),
      body: RefreshIndicator(
        onRefresh: fetchLists,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 48),
                          const SizedBox(height: 10),
                          Text(errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16, color: Colors.red)),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: fetchLists,
                            child: const Text("Réessayer"),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                itemCount: lists.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.list),
                    title: Text(lists[index]['name']),
                    subtitle: Text("ID: ${lists[index]['id']}"), // Ajout de l'ID sous le nom
                  );
                },
),
      ),
    );
  }
}
